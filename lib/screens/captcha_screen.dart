import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../home_screen.dart';
import '../data/providers/captcha_provider.dart';
import '../data/services/auth_service.dart'; // ✨ 1. Import AuthService for the custom exception

// ✨ 2. Converted to a StatefulWidget
class CaptchaScreen extends StatefulWidget {
  final String username;
  final String password;

  const CaptchaScreen({
    super.key,
    required this.username,
    required this.password,
  });

  @override
  State<CaptchaScreen> createState() => _CaptchaScreenState();
}

class _CaptchaScreenState extends State<CaptchaScreen> {
  // ✨ 3. Manage the controller and loading state within the State class
  final _captchaSolutionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _captchaSolutionController.dispose();
    super.dispose();
  }

  // ✨ 4. The core logic with proper error handling
  void _verifyAndLogin() async {
    // Prevent multiple submissions
    if (_isLoading) return;

    final solution = _captchaSolutionController.text.trim();
    if (solution.isEmpty) {
      // Optional: Show a snackbar for empty field
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the captcha solution.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final provider = context.read<CaptchaProvider>();

    try {
      // The login call is now wrapped in a try block
      final success = await provider.performLogin(
        username: widget.username,
        password: widget.password,
        captchaSolution: solution,
      );

      if (success && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } on InvalidCredentialsException catch (e) {
      if (kDebugMode){
        print("exception caught $e" );
      }
      // --- THIS IS THE KEY CHANGE ---
      // If we catch the specific invalid credentials error...
      if (mounted) {
        // Pop this screen and send the error message back to the LoginScreen
        Navigator.of(context).pop(e.toString());
      }
    } on InvalidCaptchaException catch(e){
      // Catch any other general errors (like network issues)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      // Ensure the loading indicator is always turned off
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 50.0, 24.0, 24.0),
            // Use a Consumer for the UI parts that depend on the provider's state
            child: Consumer<CaptchaProvider>(
              builder: (context, provider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    Text(
                      "Hey,",
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                    Text(
                      "are you a machine?",
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 48),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _buildCaptchaContent(provider, theme),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _captchaSolutionController,
                      decoration: InputDecoration(
                        labelText: 'Captcha Solution',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        // ✨ 5. Call the new function and use the local loading state
                        onPressed: _isLoading ? null : _verifyAndLogin,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                    strokeWidth: 3.0, color: Colors.white),
                              )
                            : const Text("VERIFY"),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCaptchaContent(CaptchaProvider provider, ThemeData theme) {
    // This part remains the same as it correctly reads from the provider
    if (provider.isLoading && provider.captchaImageBytes == null) {
      return const Center(
        key: ValueKey('loader'),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (provider.captchaImageBytes != null) {
      return Container(
        key: const ValueKey('captcha_image'),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Image.memory(
          provider.captchaImageBytes!,
          gaplessPlayback: true,
          fit: BoxFit.contain,
        ),
      );
    }

    return Center(
      key: const ValueKey('error_message'),
      child: Text(
        provider.errorMessage ?? "An unknown error occurred.",
        textAlign: TextAlign.center,
        style:
            theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
      ),
    );
  }
}
