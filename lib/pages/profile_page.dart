import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/settings_page.dart';
import '../login_screen.dart';
import '../data/providers/attendance_provider.dart';
import '../data/services/secure_storage_service.dart';
import '../data/services/preferences_service.dart';
import '../utils/debug_helpers.dart'; // ✨ 1. Import the new helper file

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // ✨ 2. The _exportStorageData function has been removed from here.

  @override
  Widget build(BuildContext context) {
    final prefsService = PreferencesService();
    final secureStorage = SecureStorageService();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            FutureBuilder(
              future: Future.wait([
                prefsService.getUserName(),
                prefsService.getEnrollmentNumber(),
              ]),
              builder: (context, AsyncSnapshot<List<String?>> snapshot) {
                String studentName = 'Loading...';
                String rollNumber = '...';

                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  studentName = snapshot.data![0] ?? 'Student';
                  rollNumber = snapshot.data![1] ?? 'No roll number';
                } else if (snapshot.hasError) {
                  studentName = 'Error';
                  rollNumber = 'Could not load data';
                }

                return Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      studentName,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rollNumber,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 40),
            _buildProfileMenu(
              context,
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
            _buildProfileMenu(
              context,
              icon: Icons.favorite_border,
              title: 'Support the Dev',
              onTap: () {},
            ),
            _buildProfileMenu(
              context,
              icon: Icons.description_outlined,
              title: 'Export Debug Logs',
              // ✨ 3. Call the imported helper function
              onTap: () => exportStorageData(context),
            ),
            _buildProfileMenu(
              context,
              icon: Icons.logout,
              title: 'Logout',
              textColor: Theme.of(context).colorScheme.error,
              onTap: () async {
                context.read<AttendanceProvider>().clearAttendance();
                await secureStorage.deleteAll();
                await prefsService.clearUserSession();

                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'beta 1.0.1',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenu(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap,
      Color? textColor}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon,
            color: textColor ?? Theme.of(context).colorScheme.primary),
        title: Text(title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: textColor, fontWeight: FontWeight.w500)),
        trailing: Icon(Icons.arrow_forward_ios,
            size: 16,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
        onTap: onTap,
      ),
    );
  }
}