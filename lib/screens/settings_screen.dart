import 'package:flutter/material.dart';
import '../utils/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationOn = false;
  TimeOfDay _time = const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Load the saved on/off state and time.
  Future<void> _load() async {
    try {
      final service = NotificationService.instance;
      final enabled = await service.isReminderEnabled();
      final t = await service.getReminderTime();
      if (!mounted) return;
      setState(() {
        _notificationOn = enabled;
        _time = TimeOfDay(hour: t.hour, minute: t.minute);
      });
    } catch (_) {
      // ignore: keep the defaults
    }
  }

  // Called when the switch is tapped. No error message is shown.
  Future<void> _toggle(bool value) async {
    // The switch always changes right away.
    setState(() => _notificationOn = value);
    try {
      final service = NotificationService.instance;
      if (value) {
        await service.requestPermission();
        await service.scheduleReminder(_time.hour, _time.minute);
      } else {
        await service.cancelReminder();
      }
    } catch (_) {
      // ignore: no error message for the user
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) {
      setState(() => _time = picked);
      try {
        await NotificationService.instance
            .scheduleReminder(picked.hour, picked.minute);
      } catch (_) {
        // ignore: no error message for the user
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('Notification'),
            subtitle: Text(
              _notificationOn ? 'On, ${_time.format(context)}' : 'Off',
            ),
            value: _notificationOn,
            onChanged: _toggle,
          ),
          if (_notificationOn)
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Time'),
              subtitle: Text(_time.format(context)),
              onTap: _pickTime,
            ),
        ],
      ),
    );
  }
}
