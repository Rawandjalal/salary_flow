import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../models/staff_member.dart';
import '../widgets/glass_card.dart';

class PayrollPage extends StatefulWidget {
  const PayrollPage({super.key});

  @override
  State<PayrollPage> createState() => _PayrollPageState();
}

class _PayrollPageState extends State<PayrollPage> {
  DateTime _selectedDate = DateTime.now();
  final Map<String, String> _statuses = {}; // staffId -> status ('present', 'half', 'absent', 'custom')
  final Map<String, TextEditingController> _customControllers = {}; // staffId -> controller

  @override
  void initState() {
    super.initState();
    _initializeDayLogs();
  }

  void _initializeDayLogs() {
    final appState = Provider.of<AppState>(context, listen: false);
    final dateStr = _selectedDate.toIso8601String().substring(0, 10);
    
    // Clear and reload
    _statuses.clear();
    for (var controller in _customControllers.values) {
      controller.dispose();
    }
    _customControllers.clear();

    // Look for existing records for this day
    final dailyRecords = appState.payrollRecords.where(
      (r) => r.date.toIso8601String().substring(0, 10) == dateStr
    ).toList();

    for (final staff in appState.staffMembers) {
      final existing = dailyRecords.firstWhere(
        (r) => r.staffId == staff.id,
        orElse: () => PayrollRecord(
          id: '',
          staffId: staff.id,
          staffName: staff.name,
          date: _selectedDate,
          amount: staff.baseSalary,
          status: 'present',
          currency: staff.currency,
        ),
      );
      _statuses[staff.id] = existing.status;
      _customControllers[staff.id] = TextEditingController(
        text: existing.status == 'custom' 
            ? existing.amount.toStringAsFixed(0) 
            : staff.baseSalary.toStringAsFixed(0),
      );
    }
  }

  void _changeDate(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
      _initializeDayLogs();
    });
  }

  double _calculatePayout(StaffMember staff) {
    final status = _statuses[staff.id] ?? 'present';
    if (status == 'present') return staff.baseSalary;
    if (status == 'half') return staff.baseSalary * 0.5;
    if (status == 'absent') return 0.0;
    
    // Custom status
    final val = double.tryParse(_customControllers[staff.id]?.text ?? '') ?? 0.0;
    return val;
  }

  void _commitPayroll() async {
    final appState = Provider.of<AppState>(context, listen: false);
    final List<PayrollRecord> records = [];

    for (final staff in appState.staffMembers) {
      final status = _statuses[staff.id] ?? 'present';
      final payout = _calculatePayout(staff);
      records.add(PayrollRecord(
        id: 'pr_${staff.id}_${_selectedDate.millisecondsSinceEpoch}',
        staffId: staff.id,
        staffName: staff.name,
        date: _selectedDate,
        amount: payout,
        status: status,
        currency: staff.currency,
      ));
    }

    await appState.logDailyPayroll(_selectedDate, records);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appState.t('payroll_submitted')),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    }
  }

  void _showStaffManagerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _StaffManagerSheet(),
    ).then((_) {
      setState(() {
        _initializeDayLogs();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isRtl = appState.isRtl;
    final staff = appState.staffMembers;

    double totalUsd = 0;
    double totalIqd = 0;
    for (final member in staff) {
      final amt = _calculatePayout(member);
      if (member.currency == 'USD') {
        totalUsd += amt;
      } else {
        totalIqd += amt;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF07080F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111422),
        title: Text(
          appState.t('staff_payroll'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton.icon(
            onPressed: _showStaffManagerSheet,
            icon: const Icon(Icons.people_alt_rounded, color: Color(0xFF10B981), size: 18),
            label: Text(
              appState.t('staff_list'),
              style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F111E), Color(0xFF07080F)],
          ),
        ),
        child: Column(
          children: [
            // Date selector banner
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              color: const Color(0xFF111422).withOpacity(0.4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 16, color: Colors.white70),
                    onPressed: () => _changeDate(_selectedDate.subtract(const Duration(days: 1))),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2025),
                        lastDate: DateTime(2030),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: Color(0xFF10B981),
                                onPrimary: Colors.white,
                                surface: Color(0xFF111422),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        _changeDate(picked);
                      }
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF10B981)),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('yyyy-MM-dd').format(_selectedDate),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white70),
                    onPressed: () => _changeDate(_selectedDate.add(const Duration(days: 1))),
                  ),
                ],
              ),
            ),

            Expanded(
              child: staff.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.02),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.people_outline_rounded, size: 64, color: Colors.white24),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              isRtl ? 'هیچ کارمەندێک تۆمار نەکراوە' : 'No staff members configured',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isRtl 
                                  ? 'تکایە کارمەندان زیاد بکە بۆ دەستپێکردنی تۆمارکردنی مووچەی ڕۆژانە.'
                                  : 'Add employee names and base salary rates to build the worksheet table.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.4)),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _showStaffManagerSheet,
                              icon: const Icon(Icons.add_rounded),
                              label: Text(appState.t('add_staff')),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Worksheet Table Card
                          GlassCard(
                            padding: const EdgeInsets.all(0),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(Colors.white.withOpacity(0.02)),
                                columnSpacing: 24,
                                columns: [
                                  DataColumn(
                                    label: Text(
                                      appState.t('staff_name'),
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      appState.t('base_salary'),
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      appState.t('daily_log'),
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      appState.t('amount'),
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70),
                                    ),
                                  ),
                                ],
                                rows: staff.map((member) {
                                  final status = _statuses[member.id] ?? 'present';
                                  final isCustom = status == 'custom';
                                  final symbol = member.currency == 'USD' ? '\$' : 'د.ع';

                                  return DataRow(
                                    cells: [
                                      // 1. Staff Name & Role
                                      DataCell(
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                member.name,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                                              ),
                                              Text(
                                                member.role,
                                                style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.4)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // 2. Base salary display
                                      DataCell(
                                        Text(
                                          '${member.baseSalary.toStringAsFixed(0)} $symbol',
                                          style: const TextStyle(fontSize: 13, color: Colors.white70),
                                        ),
                                      ),
                                      // 3. Daily Status select buttons
                                      DataCell(
                                        Row(
                                          children: [
                                            _buildStatusButton(member.id, 'present', appState.t('present'), const Color(0xFF10B981)),
                                            const SizedBox(width: 4),
                                            _buildStatusButton(member.id, 'half', appState.t('half_day'), const Color(0xFFF59E0B)),
                                            const SizedBox(width: 4),
                                            _buildStatusButton(member.id, 'absent', appState.t('absent'), const Color(0xFFEF4444)),
                                            const SizedBox(width: 4),
                                            _buildStatusButton(member.id, 'custom', appState.t('custom'), const Color(0xFF8B5CF6)),
                                          ],
                                        ),
                                      ),
                                      // 4. Final log salary cell
                                      DataCell(
                                        isCustom
                                            ? SizedBox(
                                                width: 80,
                                                child: TextFormField(
                                                  controller: _customControllers[member.id],
                                                  keyboardType: TextInputType.number,
                                                  style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold),
                                                  decoration: const InputDecoration(
                                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    border: OutlineInputBorder(),
                                                  ),
                                                  onChanged: (_) {
                                                    setState(() {});
                                                  },
                                                ),
                                              )
                                            : Text(
                                                '${_calculatePayout(member).toStringAsFixed(0)} $symbol',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13.5,
                                                  color: status == 'absent' 
                                                      ? Colors.white.withOpacity(0.3) 
                                                      : Colors.white,
                                                ),
                                              ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Payroll Summary Card
                          GlassCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  isRtl ? 'کورتەی خەرجییەکانی ئەمڕۆ' : 'Worksheet Total Expenditure',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      isRtl ? 'کۆی گشتی دۆلار (\$)' : 'Total USD Payout',
                                      style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5)),
                                    ),
                                    Text(
                                      '\$${totalUsd.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      isRtl ? 'کۆی گشتی دینار (د.ع)' : 'Total IQD Payout',
                                      style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5)),
                                    ),
                                    Text(
                                      '${NumberFormat.decimalPattern().format(totalIqd)} د.ع',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _commitPayroll,
                                  icon: const Icon(Icons.check_circle_rounded),
                                  label: Text(
                                    appState.t('commit_payroll'),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF10B981),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(String staffId, String value, String label, Color color) {
    final isSelected = _statuses[staffId] == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _statuses[staffId] = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? color : Colors.white.withOpacity(0.08),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isSelected ? color : Colors.white.withOpacity(0.4),
          ),
        ),
      ),
    );
  }
}

// Bottom sheet class to manage staff list
class _StaffManagerSheet extends StatefulWidget {
  const _StaffManagerSheet();

  @override
  State<_StaffManagerSheet> createState() => _StaffManagerSheetState();
}

class _StaffManagerSheetState extends State<_StaffManagerSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _roleController = TextEditingController();
  final _salaryController = TextEditingController();
  String _currency = 'USD';

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  void _addStaff() {
    if (!_formKey.currentState!.validate()) return;
    
    final appState = Provider.of<AppState>(context, listen: false);
    final newMember = StaffMember(
      id: 'staff_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      role: _roleController.text.trim(),
      baseSalary: double.tryParse(_salaryController.text.trim()) ?? 0.0,
      currency: _currency,
    );

    appState.addStaffMember(newMember);

    // Reset fields
    _nameController.clear();
    _roleController.clear();
    _salaryController.clear();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(appState.isRtl ? 'کارمەند بە سەرکەوتوویی زیادکرا!' : 'Employee added to staff roster!'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isRtl = appState.isRtl;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF111422),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  appState.t('staff_list'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close_rounded, color: Colors.white70),
                ),
              ],
            ),
            const Divider(color: Colors.white12, height: 24),
            
            // Add Staff Form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Enter name' : null,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(fontSize: 13, color: Colors.white),
                    decoration: InputDecoration(
                      hintText: appState.t('staff_name'),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.04),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _roleController,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Enter role' : null,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(fontSize: 13, color: Colors.white),
                    decoration: InputDecoration(
                      hintText: appState.t('role') + ' (e.g. Accountant, Driver)',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.04),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _salaryController,
                          keyboardType: TextInputType.number,
                          validator: (v) => v == null || double.tryParse(v) == null ? 'Enter number' : null,
                          textInputAction: TextInputAction.done,
                          style: const TextStyle(fontSize: 13, color: Colors.white),
                          decoration: InputDecoration(
                            hintText: appState.t('base_salary'),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.04),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Currency Toggle selector
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButton<String>(
                          value: _currency,
                          dropdownColor: const Color(0xFF161B2E),
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: 'USD', child: Text('USD (\$)', style: TextStyle(fontSize: 12))),
                            DropdownMenuItem(value: 'IQD', child: Text('IQD (د.ع)', style: TextStyle(fontSize: 12))),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _currency = val;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _addStaff,
                    icon: const Icon(Icons.person_add_rounded, size: 18),
                    label: Text(
                      appState.t('add_staff'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Text(
              isRtl ? 'کارمەندانی ئێستا' : 'Active Staff Roster',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white60),
            ),
            const SizedBox(height: 8),

            // Scrollable list of existing staff members
            Container(
              height: 250,
              margin: const EdgeInsets.only(bottom: 24),
              child: ListView.builder(
                itemCount: appState.staffMembers.length,
                itemBuilder: (context, index) {
                  final member = appState.staffMembers[index];
                  final symbol = member.currency == 'USD' ? '\$' : 'د.ع';

                  return Card(
                    color: Colors.white.withOpacity(0.02),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      dense: true,
                      title: Text(
                        member.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                      ),
                      subtitle: Text(
                        '${member.role} • ${member.baseSalary.toStringAsFixed(0)} $symbol/Day',
                        style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.4)),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                        onPressed: () {
                          appState.deleteStaffMember(member.id);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
