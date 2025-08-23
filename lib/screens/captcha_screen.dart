import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../home_screen.dart';
import '../data/providers/captcha_provider.dart';

class CaptchaScreen extends StatelessWidget {
  final String username;
  final String password;

  const CaptchaScreen({
    super.key,
    required this.username,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    final captchaSolutionController = TextEditingController();
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 50.0, 24.0, 24.0),
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

                    // --- TEXT INPUT FIELD (FIXED) ---
                    TextField(
                      controller: captchaSolutionController,
                      decoration: InputDecoration(
                        labelText: 'Captcha Solution',
                        // This makes the border visible before you click on it.
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        // This defines the border style when the field is focused.
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
                        onPressed: provider.isLoading
                            ? null
                            : () async {
                                final solution =
                                    captchaSolutionController.text.trim();
                                final success = await provider.performLogin(
                                  username: username,
                                  password: password,
                                  captchaSolution: solution,
                                );
                                if (success && context.mounted) {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const HomeScreen()),
                                    (Route<dynamic> route) => false,
                                  );
                                }
                              },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        child: provider.isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                    strokeWidth: 3.0),
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