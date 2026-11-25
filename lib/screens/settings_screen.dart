import 'package:flutter/material.dart';
import '../utils/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final service = NotificationService.instance;
    final enabled = await service.isReminderEnabled();
    final time = await service.getReminderTime();
    setState(() {
      _reminderEnabled = enabled;
      _reminderTime = TimeOfDay(hour: time.hour, minute: time.minute);
    });
  }

  Future<void> _toggleReminder(bool enabled) async {
    final service = NotificationService.instance;
    if (enabled) {
      // Android 13+ asks the user to allow notifications
      final allowed = await service.requestPermission();
      if (!allowed) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please allow notifications for this app.')),
        );
        return; // keep the switch off
      }
      await service.scheduleReminder(_reminderTime.hour, _reminderTime.minute);
    } else {
      await service.cancelReminder();
    }
    if (!mounted) return;
    setState(() => _reminderEnabled = enabled);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

// TODO: Build the UI below
}