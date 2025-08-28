import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:streamline/data/services/course_cache_service.dart';
import 'splash_screen.dart';
// Providers
import 'data/providers/theme_provider.dart';
import 'data/providers/attendance_provider.dart';
import 'data/providers/course_details_provider.dart';
import 'data/providers/schedule_provider.dart';
import 'data/providers/schedule_details_provider.dart';
import 'data/providers/captcha_provider.dart';
// Services
import 'data/services/auth_service.dart';
import 'data/services/secure_storage_service.dart';
import 'data/services/preferences_service.dart';
import 'data/services/attendance_service.dart';
import 'data/services/crypto_service.dart';
// --- 1. IMPORT NEW EXAM FILES ---
import 'data/services/exam_service.dart';
import 'data/providers/exam_provider.dart';
import 'data/services/attendance_details_service.dart';
void main() {
  // Instantiate your services once, before the app starts.
  final authService = AuthService(PreferencesService());
  final secureStorage = SecureStorageService();
  final prefsService = PreferencesService();
  final attendanceService = AttendanceService(CryptoService(), SecureStorageService(), PreferencesService());
  // --- 2. INSTANTIATE THE NEW EXAM SERVICE ---
  final examService = ExamService(CryptoService(), PreferencesService(), SecureStorageService());
  final attendanceDetailsService = AttendanceDetailsService(CryptoService(), SecureStorageService(), PreferencesService());
  final courseCacheService= CourseCacheService();

  runApp(
    MultiProvider(
      providers: [
        // Existing providers
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => ScheduleDetailsProvider()),
        ChangeNotifierProvider(
          create: (_) => CaptchaProvider(authService, secureStorage),
        ),
        ChangeNotifierProvider(
          create: (_) => AttendanceProvider(attendanceService, prefsService),
        ),

        // --- 3. ADD THE NEW EXAM PROVIDER ---
        ChangeNotifierProvider(
          create: (_) => ExamProvider(examService),
        ),
         // Updated provider creation
        ChangeNotifierProxyProvider<AttendanceProvider, CourseDetailsProvider>(
      
        // 'create' is called only once to build the initial object.
          create: (context) => CourseDetailsProvider(
            service: attendanceDetailsService,
            // Use context.read to get the already-existing AttendanceProvider.
            attendanceProvider: context.read<AttendanceProvider>(),
            cacheService: courseCacheService
          ),
      
          // 'update' is called whenever AttendanceProvider notifies its listeners.
          // This is useful if CourseDetailsProvider needs to react to changes.
          update: (context, attendanceProvider, previousCourseDetailsProvider) {
            // In this specific case, you might not need to do anything in update,
            // but it's required by the constructor. You can return the existing
            // instance or a new one if needed.
            return previousCourseDetailsProvider!;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => ExamProvider(
             examService,
          )
       )
      ],
      child: const StreamlineApp(),
    ),
  );
}

class StreamlineApp extends StatelessWidget {
  const StreamlineApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Streamline',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: themeProvider.themeMode,
      home: const SplashScreen(),
    );
  }

  // Your _buildTheme method remains the same
  ThemeData _buildTheme(Brightness brightness) {
    var baseTheme = ThemeData(
      brightness: brightness,
      useMaterial3: true,
    );

    final ColorScheme colorScheme = brightness == Brightness.dark
        ? const ColorScheme.dark(
            primary: Color(0xFF4A90E2),
            secondary: Color(0xFF50E3C2),
            surface: Color(0xFF1E1E1E),
            onPrimary: Colors.white,
            onSecondary: Colors.black,
            onSurface: Color(0xFFEAEAEA),
            error: Colors.redAccent,
            onError: Colors.white,
          )
        : const ColorScheme.light(
            primary: Color(0xFF4A90E2),
            secondary: Color(0xFF50E3C2),
            surface: Colors.white,
            onPrimary: Colors.white,
            onSecondary: Colors.black,
            onSurface: Color(0xFF333333),
            error: Colors.redAccent,
            onError: Colors.white,
          );

    final textTheme = GoogleFonts.poppinsTextTheme(baseTheme.textTheme).apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );

    return baseTheme.copyWith(
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
        selectedLabelStyle: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: textTheme.bodySmall,
        elevation: 2,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
        ),
        labelStyle: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}