import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../models/planners_models.dart';
import '../models/staff_member.dart';
import '../widgets/glass_card.dart';

class PlannersPage extends StatefulWidget {
  const PlannersPage({super.key});

  @override
  State<PlannersPage> createState() => _PlannersPageState();
}

class _PlannersPageState extends State<PlannersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isRtl = appState.isRtl;

    return Scaffold(
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isRtl ? 'ڕێکخستن و پلاندانان' : 'Agendas & Projections',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white.withOpacity(0.4),
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isRtl ? 'ستۆدیۆی پلانەکان' : 'Planners Studio',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.next_plan_rounded, color: Color(0xFF10B981), size: 22),
                    ),
                  ],
                ),
              ),

              // Tab selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.04)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withOpacity(0.4),
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    tabs: [
                      Tab(text: isRtl ? 'پلانی کار (ئەرکەکان)' : 'Work Plan (Tasks)'),
                      Tab(text: isRtl ? 'پلانی بازرگانی' : 'Business Plan'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Tab contents
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildWorkPlanTab(context, appState, isRtl),
                    _buildBusinessPlanTab(context, appState, isRtl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // WORK PLAN TAB
  // ----------------------------------------------------
  Widget _buildWorkPlanTab(BuildContext context, AppState appState, bool isRtl) {
    final tasks = appState.workTasks;
    final total = tasks.length;
    final completed = tasks.where((t) => t.status == 'done').length;
    final double completionRatio = total > 0 ? completed / total : 0.0;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        // Agenda Summary Card
        GlassCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isRtl ? 'بارودۆخی گشتی ئەرکەکان' : 'WORK AGENDA PROGRESS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withOpacity(0.4),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 52,
                        height: 52,
                        child: CircularProgressIndicator(
                          value: completionRatio,
                          backgroundColor: Colors.white.withOpacity(0.04),
                          color: const Color(0xFF10B981),
                          strokeWidth: 5,
                        ),
                      ),
                      Text(
                        '${(completionRatio * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isRtl 
                              ? '$completed ئەرک لە کۆی $total تەواوکراون' 
                              : '$completed of $total tasks completed',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isRtl 
                              ? 'ئەرکی کارمەندەکان و خشتەی ئیشوکارەکان ڕێکبخە.'
                              : 'Keep your employees productive and manage deadlines.',
                          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Action header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isRtl ? 'لیستی ئەرکەکان' : 'Tasks List',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white.withOpacity(0.4),
                letterSpacing: 1.5,
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981).withOpacity(0.12),
                foregroundColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: const Color(0xFF10B981).withOpacity(0.2)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onPressed: () => _showAddTaskDialog(context, appState, isRtl),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: Text(isRtl ? 'ئەرکی نوێ' : 'New Task', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
            ),
          ],
        ),

        const SizedBox(height: 8),

        if (tasks.isEmpty)
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                Icon(Icons.assignment_turned_in_rounded, size: 40, color: Colors.white.withOpacity(0.2)),
                const SizedBox(height: 12),
                Text(
                  isRtl ? 'هیچ ئەرکێک تۆمار نەکراوە' : 'No tasks created yet',
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  isRtl ? 'دوگمەی زیادکردن دابگرە بۆ دەستپێکردن' : 'Tap New Task to organize your agenda',
                  style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11),
                ),
              ],
            ),
          )
        else
          ...tasks.map((task) => _buildTaskItem(context, appState, task, isRtl)),

        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildTaskItem(BuildContext context, AppState appState, WorkTask task, bool isRtl) {
    final isDone = task.status == 'done';
    final dateStr = DateFormat.yMMMd().format(task.dueDate);

    Color priorityColor;
    String priorityText;
    switch (task.priority) {
      case 'high':
        priorityColor = const Color(0xFFEF4444);
        priorityText = isRtl ? 'بەرز' : 'High';
        break;
      case 'medium':
        priorityColor = Colors.orangeAccent;
        priorityText = isRtl ? 'مامناوەند' : 'Medium';
        break;
      default:
        priorityColor = Colors.blueAccent;
        priorityText = isRtl ? 'نزم' : 'Low';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status checkbox
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: isDone,
                  activeColor: const Color(0xFF10B981),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  side: BorderSide(color: Colors.white.withOpacity(0.2)),
                  onChanged: (val) {
                    appState.toggleWorkTaskStatus(task.id);
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Task content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDone ? Colors.white.withOpacity(0.4) : Colors.white,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDone ? Colors.white.withOpacity(0.25) : Colors.white.withOpacity(0.5),
                        height: 1.3,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Due Date chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_month_rounded, size: 10, color: Colors.white.withOpacity(0.4)),
                            const SizedBox(width: 4),
                            Text(
                              dateStr,
                              style: TextStyle(fontSize: 9.5, color: Colors.white.withOpacity(0.5)),
                            ),
                          ],
                        ),
                      ),
                      // Priority Chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: priorityColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          priorityText,
                          style: TextStyle(fontSize: 9.5, color: priorityColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                      // Assignee Chip
                      if (task.assignedStaffName.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.person_rounded, size: 10, color: Colors.blueAccent),
                              const SizedBox(width: 4),
                              Text(
                                task.assignedStaffName,
                                style: const TextStyle(fontSize: 9.5, color: Colors.blueAccent, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Delete action button
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: Colors.white.withOpacity(0.3), size: 18),
              onPressed: () {
                appState.deleteWorkTask(task.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, AppState appState, bool isRtl) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String? selectedStaffId;
    String selectedPriority = 'medium';
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF111422),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                isRtl ? 'زیادکردنی ئەرکی نوێ' : 'Add New Task',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: isRtl ? 'ناونیشانی ئەرک' : 'Task Title',
                        labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.03),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: isRtl ? 'ڕوونکردنەوە / وەسف' : 'Description',
                        labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.03),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Assign worker dropdown
                    DropdownButtonFormField<String>(
                      dropdownColor: const Color(0xFF111422),
                      value: selectedStaffId,
                      decoration: InputDecoration(
                        labelText: isRtl ? 'سپاردن بە کارمەند' : 'Assign Employee',
                        labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.03),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text(isRtl ? 'دیاری نەکراوە (کۆمپانیا)' : 'Unassigned (General)', style: const TextStyle(color: Colors.white54)),
                        ),
                        ...appState.staffMembers.map((staff) {
                          return DropdownMenuItem<String>(
                            value: staff.id,
                            child: Text(staff.name, style: const TextStyle(color: Colors.white)),
                          );
                        }),
                      ],
                      onChanged: (val) {
                        setDialogState(() => selectedStaffId = val);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Priority dropdown
                    DropdownButtonFormField<String>(
                      dropdownColor: const Color(0xFF111422),
                      value: selectedPriority,
                      decoration: InputDecoration(
                        labelText: isRtl ? 'ئاستی گرنگی' : 'Priority Level',
                        labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.03),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: [
                        DropdownMenuItem(value: 'low', child: Text(isRtl ? 'نزم' : 'Low', style: const TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 'medium', child: Text(isRtl ? 'مامناوەند' : 'Medium', style: const TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 'high', child: Text(isRtl ? 'بەرز' : 'High', style: const TextStyle(color: Colors.white))),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedPriority = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Due Date Picker
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isRtl ? 'کاتی جێبەجێکردن:' : 'Due Date:',
                          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final d = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (d != null) {
                              setDialogState(() => selectedDate = d);
                            }
                          },
                          icon: const Icon(Icons.date_range_rounded, color: Color(0xFF10B981), size: 16),
                          label: Text(
                            DateFormat.yMMMd().format(selectedDate),
                            style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(isRtl ? 'پاشگەزبوونەوە' : 'Cancel', style: TextStyle(color: Colors.white.withOpacity(0.6))),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) return;

                    String staffName = '';
                    if (selectedStaffId != null) {
                      final staff = appState.staffMembers.firstWhere((s) => s.id == selectedStaffId);
                      staffName = staff.name;
                    }

                    final task = WorkTask(
                      id: 'task_${DateTime.now().millisecondsSinceEpoch}',
                      title: titleController.text.trim(),
                      description: descController.text.trim(),
                      assignedStaffId: selectedStaffId ?? '',
                      assignedStaffName: staffName,
                      dueDate: selectedDate,
                      priority: selectedPriority,
                      status: 'todo',
                    );

                    appState.addWorkTask(task);
                    Navigator.pop(context);
                  },
                  child: Text(isRtl ? 'زيادکردن' : 'Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ----------------------------------------------------
  // BUSINESS PLAN TAB
  // ----------------------------------------------------
  Widget _buildBusinessPlanTab(BuildContext context, AppState appState, bool isRtl) {
    // Determine active wallet and targets
    final activeWallet = appState.transactions.isNotEmpty 
        ? appState.transactions.first.currency // fallback to last transaction currency
        : 'USD';
    final isUsd = activeWallet == 'USD';
    final targetRevenue = isUsd ? appState.targetMonthlyRevenueUSD : appState.targetMonthlyRevenueIQD;
    final currencySymbol = isUsd ? '\$' : 'د.ع';

    // Calculate actual monthly business revenue logged in this month's ledger
    final now = DateTime.now();
    final actualRevenue = appState.allTransactions
        .where((tx) => tx.isIncome && 
                       tx.scope == 'business' && 
                       tx.currency == activeWallet && 
                       tx.date.year == now.year && 
                       tx.date.month == now.month)
        .fold(0.0, (sum, tx) => sum + tx.amount);

    final double progressRatio = targetRevenue > 0 ? (actualRevenue / targetRevenue).clamp(0.0, 1.0) : 0.0;
    final progressPercent = (progressRatio * 100).toStringAsFixed(0);

    final currencyFormat = NumberFormat.currency(
      symbol: currencySymbol,
      decimalDigits: isUsd ? 2 : 0,
    );

    final milestones = appState.businessMilestones;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        // Target Monthly Revenue Gauge Card
        GlassCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isRtl ? 'بودجەی داهاتی بازرگانی مانگانە' : 'MONTHLY BUSINESS GOALS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withOpacity(0.4),
                      letterSpacing: 1.2,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF10B981), size: 22),
                    onPressed: () => _showEditRevenueTargetDialog(context, appState, isUsd, targetRevenue, isRtl),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isRtl ? 'کۆکراوەی داهاتی مانگ:' : 'Logged Sales This Month:',
                          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currencyFormat.format(actualRevenue),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isRtl 
                              ? 'ئامانج: ${currencyFormat.format(targetRevenue)}'
                              : 'Target: ${currencyFormat.format(targetRevenue)}',
                          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.4), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 68,
                        height: 68,
                        child: CircularProgressIndicator(
                          value: progressRatio,
                          backgroundColor: Colors.white.withOpacity(0.04),
                          color: const Color(0xFF10B981),
                          strokeWidth: 6,
                        ),
                      ),
                      Text(
                        '$progressPercent%',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progressRatio,
                  backgroundColor: Colors.white.withOpacity(0.05),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isRtl 
                    ? 'ڕێژەی گەیشتن بە ئامانج بەپێی تۆمارەکانی ئەم مانگە.'
                    : 'Target completion rate calculated from active business logs.',
                style: TextStyle(fontSize: 10.5, color: Colors.white.withOpacity(0.4), fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Milestones Agenda Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isRtl ? 'ئاڕاستەی ئامانج و هیواکان' : 'Milestones Roadmap',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white.withOpacity(0.4),
                letterSpacing: 1.5,
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981).withOpacity(0.12),
                foregroundColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: const Color(0xFF10B981).withOpacity(0.2)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onPressed: () => _showAddMilestoneDialog(context, appState, isRtl),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: Text(isRtl ? 'ئامانجی نوێ' : 'New Milestone', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
            ),
          ],
        ),

        const SizedBox(height: 10),

        if (milestones.isEmpty)
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                Icon(Icons.flag_rounded, size: 40, color: Colors.white.withOpacity(0.2)),
                const SizedBox(height: 12),
                Text(
                  isRtl ? 'هیچ ئامانجێک لێرە نییە' : 'No milestones defined yet',
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  isRtl ? 'ڕێگا و مۆڵەتەکانی کارەکەت نووسە' : 'Define milestones to structure your roadmap',
                  style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11),
                ),
              ],
            ),
          )
        else
          ...milestones.map((m) => _buildMilestoneItem(context, appState, m, isRtl)),

        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildMilestoneItem(BuildContext context, AppState appState, BusinessMilestone milestone, bool isRtl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: milestone.isCompleted,
                  activeColor: const Color(0xFF10B981),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  side: BorderSide(color: Colors.white.withOpacity(0.2)),
                  onChanged: (val) {
                    appState.toggleMilestoneStatus(milestone.id);
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    milestone.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: milestone.isCompleted ? Colors.white.withOpacity(0.4) : Colors.white,
                      decoration: milestone.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (milestone.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      milestone.description,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: milestone.isCompleted ? Colors.white.withOpacity(0.25) : Colors.white.withOpacity(0.5),
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: Colors.white.withOpacity(0.3), size: 18),
              onPressed: () {
                appState.deleteBusinessMilestone(milestone.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditRevenueTargetDialog(BuildContext context, AppState appState, bool isUsd, double currentVal, bool isRtl) {
    final controller = TextEditingController(text: currentVal.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111422),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            isRtl ? 'ڕێکخستنی ئامانجی مانگانە' : 'Monthly Income Target',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isRtl 
                    ? 'ئەم نرخە بەکار دێت بۆ پێشبینیکردنی گەشەی کارەکەت و ڕێژەی داهات.'
                    : 'Set target monthly business income for progress comparisons.',
                style: TextStyle(fontSize: 11.5, color: Colors.white.withOpacity(0.5)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: false),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  suffixText: isUsd ? 'USD (\\\$)' : 'IQD (د.ع)',
                  suffixStyle: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.04),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isRtl ? 'پاشگەزبوونەوە' : 'Cancel', style: TextStyle(color: Colors.white.withOpacity(0.6))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final double? val = double.tryParse(controller.text);
                if (val != null && val >= 0) {
                  if (isUsd) {
                    appState.setTargetMonthlyRevenueUSD(val);
                  } else {
                    appState.setTargetMonthlyRevenueIQD(val);
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(isRtl ? 'پاشەکەوتکردن' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  void _showAddMilestoneDialog(BuildContext context, AppState appState, bool isRtl) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111422),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            isRtl ? ' زیادکردنی ئامانج/ڕێچکە' : 'Add Roadmap Milestone',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: isRtl ? 'ئامانج چییە؟' : 'Milestone Title',
                  labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.03),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: isRtl ? 'ڕوونکردنەوە / لایەنەکان' : 'Context / Description',
                  labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.03),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isRtl ? 'پاشگەزبوونەوە' : 'Cancel', style: TextStyle(color: Colors.white.withOpacity(0.6))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;

                final milestone = BusinessMilestone(
                  id: 'milestone_${DateTime.now().millisecondsSinceEpoch}',
                  title: titleController.text.trim(),
                  description: descController.text.trim(),
                  isCompleted: false,
                );

                appState.addBusinessMilestone(milestone);
                Navigator.pop(context);
              },
              child: Text(isRtl ? 'زیادکردن' : 'Add'),
            ),
          ],
        );
      },
    );
  }
}
