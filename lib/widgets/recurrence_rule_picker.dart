import 'package:flutter/material.dart';
import 'package:fam_planner/models/recurrence_rule.dart';

class RecurrenceRulePicker extends StatefulWidget {
  final RecurrenceRule? initialRule;
  final ValueChanged<RecurrenceRule?> onChanged;

  const RecurrenceRulePicker({
    Key? key,
    this.initialRule,
    required this.onChanged,
  }) : super(key: key);

  @override
  _RecurrenceRulePickerState createState() => _RecurrenceRulePickerState();
}

class _RecurrenceRulePickerState extends State<RecurrenceRulePicker> {
  RecurrenceFrequency? _frequency;
  int _interval = 1;
  DateTime? _endDate;
  int? _occurrenceCount;
  final Set<int> _selectedDays = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialRule != null) {
      _frequency = widget.initialRule!.frequency;
      _interval = widget.initialRule!.interval;
      _endDate = widget.initialRule!.until;
      _occurrenceCount = widget.initialRule!.count;
      _selectedDays.addAll(widget.initialRule!.byWeekDays ?? {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Frequency selection
        DropdownButtonFormField<RecurrenceFrequency>(
          value: _frequency,
          decoration: const InputDecoration(
            labelText: 'Repeat',
            border: OutlineInputBorder(),
          ),
          items: RecurrenceFrequency.values.map((frequency) {
            return DropdownMenuItem(
              value: frequency,
              child: Text(frequency.displayName),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _frequency = value;
              _updateRule();
            });
          },
        ),
        const SizedBox(height: 16),

        // Interval
        if (_frequency != null) ...[
          TextFormField(
            initialValue: _interval.toString(),
            decoration: InputDecoration(
              labelText: 'Every (${_getIntervalSuffix()})',
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final interval = int.tryParse(value) ?? 1;
              setState(() {
                _interval = interval > 0 ? interval : 1;
                _updateRule();
              });
            },
          ),
          const SizedBox(height: 16),
        ],

        // Day selection for weekly
        if (_frequency == RecurrenceFrequency.weekly) ...[
          const Text('Repeat on:'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: List.generate(7, (index) {
              final day = index + 1; // 1 = Monday, 7 = Sunday
              final isSelected = _selectedDays.contains(day);
              final dayName = _getDayName(day);
              
              return FilterChip(
                label: Text(dayName),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedDays.add(day);
                    } else {
                      _selectedDays.remove(day);
                    }
                    _updateRule();
                  });
                },
              );
            }),
          ),
          const SizedBox(height: 16),
        ],

        // End condition
        DropdownButtonFormField<String>(
          value: _occurrenceCount != null ? 'count' : _endDate != null ? 'until' : 'never',
          decoration: const InputDecoration(
            labelText: 'Ends',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: 'never',
              child: Text('Never'),
            ),
            DropdownMenuItem(
              value: 'until',
              child: Text('On date'),
            ),
            DropdownMenuItem(
              value: 'count',
              child: Text('After number of occurrences'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              if (value == 'count') {
                _occurrenceCount = _occurrenceCount ?? 10;
                _endDate = null;
              } else if (value == 'until') {
                _endDate = _endDate ?? DateTime.now().add(const Duration(days: 30));
                _occurrenceCount = null;
              } else {
                _endDate = null;
                _occurrenceCount = null;
              }
              _updateRule();
            });
          },
        ),

        if (_occurrenceCount != null) ...[
          const SizedBox(height: 8),
          TextFormField(
            initialValue: _occurrenceCount.toString(),
            decoration: const InputDecoration(
              labelText: 'Number of occurrences',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final count = int.tryParse(value) ?? 1;
              setState(() {
                _occurrenceCount = count > 0 ? count : 1;
                _updateRule();
              });
            },
          ),
        ],

        if (_endDate != null) ...[
          const SizedBox(height: 8),
          TextFormField(
            readOnly: true,
            controller: TextEditingController(
              text: '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
            ),
            decoration: const InputDecoration(
              labelText: 'End date',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _endDate!,
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                setState(() {
                  _endDate = date;
                  _updateRule();
                });
              }
            },
          ),
        ],
      ],
    );
  }

  String _getIntervalSuffix() {
    if (_frequency == null) return '';
    switch (_frequency!) {
      case RecurrenceFrequency.daily:
        return _interval == 1 ? 'day' : 'days';
      case RecurrenceFrequency.weekly:
        return _interval == 1 ? 'week' : 'weeks';
      case RecurrenceFrequency.monthly:
        return _interval == 1 ? 'month' : 'months';
      case RecurrenceFrequency.yearly:
        return _interval == 1 ? 'year' : 'years';
    }
  }

  String _getDayName(int day) {
    switch (day) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  void _updateRule() {
    if (_frequency == null) {
      widget.onChanged(null);
      return;
    }

    final rule = RecurrenceRule(
      frequency: _frequency!,
      interval: _interval,
      count: _occurrenceCount,
      until: _endDate,
      byWeekDays: _selectedDays.isNotEmpty ? _selectedDays.toList() : null,
    );

    widget.onChanged(rule);
  }
}
