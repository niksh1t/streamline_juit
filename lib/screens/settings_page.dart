// screens/settings_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 1. Import provider
import '../data/providers/theme_provider.dart';    

class SettingsPage extends StatelessWidget {

  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 3. Get access to the provider instance
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('Appearance', context),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle between light and dark themes'),
            // 4. Set the value based on the provider's state
            value: themeProvider.isDarkMode,
            // 5. Call the provider's method when the switch is toggled
            onChanged: (bool value) {
              // We use listen: false here because we're in a callback
              // and only want to call a method, not rebuild the whole page.
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
            secondary: const Icon(Icons.brightness_6_outlined),
          ),
          const Divider(),
          _buildSectionHeader('Notifications', context),
          SwitchListTile(
            title: const Text('Class Reminders'),
            subtitle: const Text('Get notified 15 minutes before a class'),
            value: false, // Dummy value
            onChanged: (bool value) {},
            secondary: const Icon(Icons.notifications_active_outlined),
          ),
          SwitchListTile(
            title: const Text('Attendance Alerts'),
            subtitle: const Text('Notify when attendance is marked'),
            value: false, // Dummy value
            onChanged: (bool value) {},
             secondary: const Icon(Icons.check_circle_outline),
          ),
          const Divider(),
          _buildSectionHeader('Data', context),
           ListTile(
            leading: const Icon(Icons.sync_outlined),
            title: const Text('Sync Data'),
            subtitle: const Text('Last synced: 10 Aug, 8:30 AM'),
            onTap: () {
              // TODO: Add manual sync logic
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

