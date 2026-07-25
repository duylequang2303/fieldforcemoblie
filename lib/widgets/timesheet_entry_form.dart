import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimesheetEntryForm extends StatefulWidget {
  final VoidCallback onSaved;

  const TimesheetEntryForm({super.key, required this.onSaved});

  @override
  State<TimesheetEntryForm> createState() => _TimesheetEntryFormState();
}

class _TimesheetEntryFormState extends State<TimesheetEntryForm> {
  final List<String> _employeeOptions = ['Just Me', 'Crew'];
  final List<String> _selectedEmployees = ['Just Me'];
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  int _breakMinutes = 0;
  
  final TextEditingController _noteController = TextEditingController();

  final List<Map<String, dynamic>> _breakOptions = [
    {'label': 'No Break', 'value': 0},
    {'label': '15 min', 'value': 15},
    {'label': '30 min', 'value': 30},
    {'label': '1 hour', 'value': 60},
  ];

  double get _calculatedHours {
    if (_startTime == null || _endTime == null) return 0.0;
    
    final start = DateTime(2000, 1, 1, _startTime!.hour, _startTime!.minute);
    var end = DateTime(2000, 1, 1, _endTime!.hour, _endTime!.minute);
    
    if (end.isBefore(start)) {
      end = end.add(const Duration(days: 1));
    }
    
    final diffMinutes = end.difference(start).inMinutes;
    final totalMinutes = diffMinutes - _breakMinutes;
    
    return totalMinutes > 0 ? totalMinutes / 60.0 : 0.0;
  }

  void _save() {
    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Start and End time')),
      );
      return;
    }
    if (_calculatedHours <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hours must be greater than 0')),
      );
      return;
    }
    if (_selectedEmployees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one employee')),
      );
      return;
    }
    widget.onSaved();
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return 'Select';
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('h:mma').format(dt).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      color: theme.colorScheme.background,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              color: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    key: const Key('btn_close_timesheet'),
                    icon: Icon(Icons.close, color: theme.colorScheme.onPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(
                    'Add Time Entry',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    key: const Key('btn_save_timesheet'),
                    onPressed: _save,
                    child: Text(
                      'Save',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Form Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // EMPLOYEE(S)
                    Text('EMPLOYEE(S)', style: _labelStyle(theme)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _employeeOptions.map((emp) {
                        final isSelected = _selectedEmployees.contains(emp);
                        return FilterChip(
                          key: Key('chip_employee_$emp'),
                          label: Text(emp),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedEmployees.add(emp);
                              } else {
                                _selectedEmployees.remove(emp);
                              }
                            });
                          },
                          selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                          checkmarkColor: theme.colorScheme.primary,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    
                    // DATE
                    Text('DATE', style: _labelStyle(theme)),
                    const SizedBox(height: 8),
                    InkWell(
                      key: const Key('btn_select_date'),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) setState(() => _selectedDate = date);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.dividerColor),
                          borderRadius: BorderRadius.circular(4),
                          color: theme.colorScheme.surface,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
                            const Icon(Icons.calendar_today, size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // TIME ROWS
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('START TIME', style: _labelStyle(theme)),
                              const SizedBox(height: 8),
                              _buildTimePicker(
                                key: const Key('btn_start_time'),
                                theme: theme,
                                time: _startTime,
                                onChanged: (t) => setState(() => _startTime = t),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('END TIME', style: _labelStyle(theme)),
                              const SizedBox(height: 8),
                              _buildTimePicker(
                                key: const Key('btn_end_time'),
                                theme: theme,
                                time: _endTime,
                                onChanged: (t) => setState(() => _endTime = t),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // BREAK & HOURS
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('BREAK', style: _labelStyle(theme)),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  border: Border.all(color: theme.dividerColor),
                                  borderRadius: BorderRadius.circular(4),
                                  color: theme.colorScheme.surface,
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    key: const Key('dropdown_break'),
                                    isExpanded: true,
                                    value: _breakMinutes,
                                    items: _breakOptions.map((opt) {
                                      return DropdownMenuItem<int>(
                                        value: opt['value'] as int,
                                        child: Text(opt['label'] as String),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) setState(() => _breakMinutes = val);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('HOURS', style: _labelStyle(theme)),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceVariant?.withOpacity(0.5) ?? Colors.grey[200],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _calculatedHours.toStringAsFixed(2),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // NOTE
                    Text('NOTE', style: _labelStyle(theme)),
                    const SizedBox(height: 8),
                    TextField(
                      key: const Key('input_note'),
                      controller: _noteController,
                      maxLines: 3,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText: 'Add note here...',
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker({
    required Key key,
    required ThemeData theme,
    required TimeOfDay? time,
    required ValueChanged<TimeOfDay> onChanged,
  }) {
    return InkWell(
      key: key,
      onTap: () async {
        final t = await showTimePicker(
          context: context,
          initialTime: time ?? TimeOfDay.now(),
        );
        if (t != null) onChanged(t);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(4),
          color: theme.colorScheme.surface,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_formatTimeOfDay(time)),
            const Icon(Icons.access_time, size: 20),
          ],
        ),
      ),
    );
  }

  TextStyle _labelStyle(ThemeData theme) {
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: theme.colorScheme.onSurface.withOpacity(0.6),
      letterSpacing: 0.5,
    );
  }
}
