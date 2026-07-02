import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../state/app_state.dart';
import '../services/notification_service.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Refresh countdown every second
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    // Request notification permission on first view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.instance.requestPermission();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _showAddTaskSheet({FinancialTask? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddTaskSheet(existing: existing),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final tasks = appState.financialTasks;
    final theme = Theme.of(context);

    final pending = tasks.where((t) => !t.isCompleted).toList()
      ..sort((a, b) => a.dueDateTime.compareTo(b.dueDateTime));
    final completed = tasks.where((t) => t.isCompleted).toList()
      ..sort((a, b) => b.dueDateTime.compareTo(a.dueDateTime));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            title: Text(
              appState.t('tasks_title'),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
            ),
            actions: [
              if (tasks.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Chip(
                    label: Text(
                      '${pending.length} ${appState.t('tasks_pending')}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    backgroundColor: const Color(0xFF10B981).withOpacity(0.15),
                    side: BorderSide.none,
                  ),
                ),
            ],
          ),
          if (tasks.isEmpty)
            SliverFillRemaining(
              child: _EmptyState(onAdd: _showAddTaskSheet),
            )
          else ...[
            if (pending.isNotEmpty) ...[
              _SectionHeader(
                title: appState.t('upcoming_tasks'),
                icon: Icons.schedule_rounded,
                color: const Color(0xFF10B981),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _TaskCard(
                      task: pending[i],
                      onEdit: () => _showAddTaskSheet(existing: pending[i]),
                    ),
                    childCount: pending.length,
                  ),
                ),
              ),
            ],
            if (completed.isNotEmpty) ...[
              _SectionHeader(
                title: appState.t('completed_tasks'),
                icon: Icons.check_circle_rounded,
                color: Colors.grey,
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _TaskCard(
                      task: completed[i],
                      onEdit: () => _showAddTaskSheet(existing: completed[i]),
                    ),
                    childCount: completed.length,
                  ),
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 76),
        child: FloatingActionButton.extended(
          onPressed: _showAddTaskSheet,
          backgroundColor: const Color(0xFF10B981),
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_task_rounded),
          label: Text(
            appState.t('add_task'),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

// ─── Task Card ───────────────────────────────────────────────────────────────

class _TaskCard extends StatelessWidget {
  final FinancialTask task;
  final VoidCallback onEdit;

  const _TaskCard({required this.task, required this.onEdit});

  Color _statusColor() {
    if (task.isCompleted) return Colors.grey;
    if (task.isOverdue) return const Color(0xFFEF4444);
    if (task.isDueSoon) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  String _getTimeRemainingLabel(AppState appState) {
    if (task.isCompleted) return appState.t('task_done');
    final diff = task.dueDateTime.difference(DateTime.now());
    if (diff.isNegative) {
      final abs = diff.abs();
      if (abs.inDays > 0) return '${abs.inDays}${appState.t('d_overdue')}';
      if (abs.inHours > 0) return '${abs.inHours}${appState.t('h_overdue')}';
      return '${abs.inMinutes}${appState.t('m_overdue')}';
    }
    if (diff.inDays > 0) return '${appState.t('in_prefix')}${diff.inDays}d ${diff.inHours % 24}h';
    if (diff.inHours > 0) return '${appState.t('in_prefix')}${diff.inHours}h ${diff.inMinutes % 60}m';
    if (diff.inMinutes > 0) return '${appState.t('in_prefix')}${diff.inMinutes}m';
    return appState.t('due_now');
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final color = _statusColor();
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444).withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_rounded, color: Color(0xFFEF4444)),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(appState.t('delete_task')),
            content: Text('${appState.t('delete_confirm_prefix')} "${task.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(appState.t('cancel')),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(appState.t('delete'),
                    style: const TextStyle(color: Color(0xFFEF4444))),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (_) {
        NotificationService.instance.cancelTaskNotification(task.id);
        appState.deleteFinancialTask(task.id);
      },
      child: GestureDetector(
        onTap: onEdit,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.25), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Category emoji + checkbox
              GestureDetector(
                onTap: () {
                  appState.toggleFinancialTask(task.id);
                  if (!task.isCompleted) {
                    NotificationService.instance
                        .cancelTaskNotification(task.id);
                  }
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: task.isCompleted
                      ? Icon(Icons.check_circle_rounded, color: color, size: 24)
                      : Center(
                          child: Text(
                            task.category.emoji,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              // Title + info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.isCompleted
                            ? Colors.grey
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        task.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded,
                            size: 12, color: color.withOpacity(0.8)),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM d, h:mm a').format(task.dueDateTime),
                          style: TextStyle(
                            fontSize: 11,
                            color: color.withOpacity(0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Right: amount + countdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (task.amount != null)
                    Text(
                      '\$${task.amount!.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: color,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getTimeRemainingLabel(appState),
                      style: TextStyle(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Add/Edit Task Sheet ──────────────────────────────────────────────────────

class _AddTaskSheet extends StatefulWidget {
  final FinancialTask? existing;
  const _AddTaskSheet({this.existing});

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  TaskCategory _category = TaskCategory.shopping;
  DateTime _dueDate = DateTime.now().add(const Duration(hours: 1));

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final t = widget.existing!;
      _titleCtrl.text = t.title;
      _descCtrl.text = t.description;
      _amountCtrl.text = t.amount?.toString() ?? '';
      _category = t.category;
      _dueDate = t.dueDateTime;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueDate),
    );
    if (time == null || !mounted) return;
    setState(() {
      _dueDate = DateTime(
          date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _save() {
    final appState = context.read<AppState>();
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appState.t('enter_title_error'))),
      );
      return;
    }

    final amount = double.tryParse(_amountCtrl.text.trim());

    if (widget.existing != null) {
      final updated = widget.existing!.copyWith(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        amount: amount,
        dueDateTime: _dueDate,
        category: _category,
      );
      appState.updateFinancialTask(updated);
      NotificationService.instance.scheduleTaskNotification(updated);
    } else {
      final task = FinancialTask(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        amount: amount,
        dueDateTime: _dueDate,
        category: _category,
      );
      appState.addFinancialTask(task);
      NotificationService.instance.scheduleTaskNotification(task);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.existing != null
            ? appState.t('task_updated_msg')
            : appState.t('task_added_msg')),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);
    final isEditing = widget.existing != null;

    return Container(
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isEditing ? appState.t('edit_task') : appState.t('new_task'),
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 20),

            // Title
            _Field(
              controller: _titleCtrl,
              label: appState.t('task_title_lbl'),
              hint: appState.t('task_title_hint'),
              icon: Icons.title_rounded,
            ),
            const SizedBox(height: 14),

            // Description
            _Field(
              controller: _descCtrl,
              label: appState.t('notes_lbl'),
              hint: appState.t('notes_hint'),
              icon: Icons.notes_rounded,
              maxLines: 2,
            ),
            const SizedBox(height: 14),

            // Amount
            _Field(
              controller: _amountCtrl,
              label: appState.t('estimated_cost'),
              hint: '0.00',
              icon: Icons.attach_money_rounded,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),

            // Category picker
            Text(
              appState.t('task_category'),
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: TaskCategory.values.map((cat) {
                  final selected = _category == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _category = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF10B981)
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF10B981)
                              : Colors.grey.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        '${cat.emoji} ${appState.t('task_cat_${cat.name}')}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : theme.colorScheme.onSurface
                                  .withOpacity(0.8),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Due date/time picker
            Text(
              appState.t('due_date_time'),
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickDateTime,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFF10B981).withOpacity(0.4),
                      width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event_rounded,
                        color: Color(0xFF10B981), size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEEE, MMMM d').format(_dueDate),
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                          Text(
                            DateFormat('h:mm a').format(_dueDate),
                            style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.w600,
                                fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: Colors.grey, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick time presets
            Row(
              children: [
                _Preset('30m', () => _setIn(const Duration(minutes: 30))),
                const SizedBox(width: 8),
                _Preset('1h', () => _setIn(const Duration(hours: 1))),
                const SizedBox(width: 8),
                _Preset('3h', () => _setIn(const Duration(hours: 3))),
                const SizedBox(width: 8),
                _Preset(appState.t('preset_tomorrow'), () => _setIn(const Duration(days: 1))),
              ],
            ),
            const SizedBox(height: 28),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  isEditing ? appState.t('update_task') : appState.t('add_task_reminder'),
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setIn(Duration d) {
    setState(() => _dueDate = DateTime.now().add(d));
  }

  Widget _Preset(String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: const Color(0xFF10B981).withOpacity(0.3)),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF10B981),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  const _SectionHeader(
      {required this.title, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: color,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      );
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📋', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            appState.t('no_tasks_yet'),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            appState.t('no_tasks_desc'),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.grey.shade500, height: 1.5),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: onAdd,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.add_task_rounded),
            label: Text(
              appState.t('create_first_task'),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType keyboardType;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 18, color: Colors.grey),
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: Color(0xFF10B981), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}
