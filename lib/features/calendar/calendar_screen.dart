import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/app_localizations.dart';
import '../../../models/calendar_event.dart';
import '../../../services/database_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final DatabaseService _databaseService = DatabaseService();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Calendar view will go here
          _buildCalendar(),
          const SizedBox(height: 8.0),
          _buildEventList(),
        ],
      ),
    );
  }
  
  Widget _buildCalendar() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
        calendarStyle: const CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
  
  Widget _buildEventList() {
    return Expanded(
      child: FutureBuilder<List<CalendarEvent>>(
        future: _databaseService.getEventsForDay(_selectedDay ?? DateTime.now()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          final events = snapshot.data ?? [];
          
          if (events.isEmpty) {
            return Center(
              child: Text(
                AppLocalizations.of(context)!.translate('no_events') ?? 'No events',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return _buildEventCard(event);
            },
          );
        },
      ),
    );
  }
  
  Widget _buildEventCard(CalendarEvent event) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0.0),
      child: ListTile(
        title: Text(event.title),
        subtitle: Text(
          '${DateFormat.jm().format(event.startTime)} - ${DateFormat.jm().format(event.endTime)}',
        ),
        trailing: event.isRecurring ? const Icon(Icons.repeat) : null,
        onTap: () => _showEventDetails(event),
      ),
    );
  }
  
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
  
  void _showEventDetails(CalendarEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.description?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(event.description!),
              ),
            Text(
              '${AppLocalizations.of(context)!.translate('start_time')}: ${_formatDateTime(event.startTime)}',
            ),
            Text(
              '${AppLocalizations.of(context)!.translate('end_time')}: ${_formatDateTime(event.endTime)}',
            ),
            if (event.location?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '${AppLocalizations.of(context)!.translate('location')}: ${event.location}',
                ),
              ),
            if (event.isRecurring)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  '${AppLocalizations.of(context)!.translate('recurring')}: ${event.recurrenceRule ?? AppLocalizations.of(context)!.translate('yes')}',
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.translate('close')),
          ),
        ],
      ),
    );
  }
  
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}.${dateTime.month}.${dateTime.year} ${_formatTime(dateTime)}';
  }
}

// Helper function to check if two dates are the same day
bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
