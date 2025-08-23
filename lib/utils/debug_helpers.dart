import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 1. Add this import
import '../data/services/secure_storage_service.dart';
// Note: We don't need PreferencesService anymore since we get the instance directly.

/// Gathers all data from storage and saves it to a `log.txt` file for debugging.
Future<void> exportStorageData(BuildContext context) async {
  try {
    final secureStorage = SecureStorageService();
    final logContent = StringBuffer();
    logContent.writeln('--- App Storage Log @ ${DateTime.now()} ---');
    logContent.writeln();

    // --- 2. Fetch SharedPreferences Data using a specific key list ---
    logContent.writeln('--- SharedPreferences Data ---');
    final prefs = await SharedPreferences.getInstance();
    
    // The list of keys you provided
    final keysToLog= prefs.getKeys();  

    // Loop through the keys and log their values
    for (final key in keysToLog) {
      final value = prefs.get(key); // .get() fetches any type (String, bool, etc.)
      logContent.writeln('$key: ${value ?? 'N/A'}');
    }
    logContent.writeln('--------------------------');
    logContent.writeln();

    // --- Fetch SecureStorage Data (this part remains the same) ---
    logContent.writeln('--- Secure Storage Data ---');
    final allSecureData = await secureStorage.readAll();
    if (allSecureData.isEmpty) {
      logContent.writeln('No data found in secure storage.');
    } else {
      allSecureData.forEach((key, value) {
        logContent.writeln('$key: $value');
      });
    }
    logContent.writeln('--------------------------');

    // --- Write to File (this part remains the same) ---
    final directory = await getApplicationDocumentsDirectory();
    final logFile = File('${directory.path}/log.txt');
    await logFile.writeAsString(logContent.toString());

    // --- Show Confirmation (this part remains the same) ---
    final filePath = logFile.path;
    debugPrint('✅ Logs successfully exported to: $filePath');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Log file saved to: $filePath'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  } catch (e) {
    debugPrint('❌ Error exporting logs: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting logs: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}