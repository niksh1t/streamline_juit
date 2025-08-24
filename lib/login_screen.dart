import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/screens/captcha_screen.dart';
import '../data/providers/captcha_provider.dart';
import '../data/services/secure_storage_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _storageService = SecureStorageService();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  
  // ✨ 1. ADDED: State variable to track loading process
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }
  
  // ✨ 2. ADDED: Dispose controllers to prevent memory leaks
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _loadCredentials() async {
    final credentials = await _storageService.getCredentials();
    if (credentials['username'] != null && credentials['username']!.isNotEmpty) {
      setState(() {
        _usernameController.text = credentials['username']!;
        _passwordController.text = credentials['password']!;
        _rememberMe = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 100, 12, 0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- The "Welcome Back" Row ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome Back',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to continue',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: Image.asset('assets/tuturu.png', fit: BoxFit.contain),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Roll Number',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Remember Me'),
                  value: _rememberMe,
                  onChanged: (bool value) {
                    setState(() {
                      _rememberMe = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  // ✨ 3. MODIFIED: Disable button and show indicator when loading
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text('LOGIN'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


void _login() async {
  final username = _usernameController.text.trim();
  final password = _passwordController.text.trim();

  if (username.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill out all fields.')),
    );
    return;
  }
  
  setState(() { _isLoading = true; });

  try {
    if (_rememberMe) {
      await _storageService.saveCredentials(username, password);
    } else {
      await _storageService.deleteAll();
    }
    
    // Fetch the captcha initially
    await context.read<CaptchaProvider>().fetchCaptcha();

    if (mounted) {
      // AWAIT the result from CaptchaScreen
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CaptchaScreen(
            username: username,
            password: password,
          ),
        ),
      );

      // AFTER CaptchaScreen is popped, check if it sent back an error message
      if (result != null && result is String) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load login screen: ${e.toString()}')),
      );
    }
  } finally {
    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }
 }
}