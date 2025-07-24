import 'package:aware_plus/controllers/auth_controller.dart';
import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final AuthController _authController = AuthController();
  String _email = '';
  String _password = '';
  bool _isLoading = false;

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Reset Password'),
          content: TextField(
            controller: emailController,
            decoration: InputDecoration(labelText: 'Enter your email'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                try {
                  await _authController.resetPassword(
                    emailController.text.trim(),
                  );

                  if (!mounted) return; // ✅ Safeguard
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Password reset link sent!')),
                  );
                } catch (e) {
                  if (!mounted) return; // ✅ Safeguard
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              },
              child: Text('Send'),
            ),
          ],
        );
      },
    );
  }

  void _submitLogin() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      final success = await _authController.login(_email, _password);

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (success) {
        Navigator.pushReplacementNamed(
          context,
          '/home',
        ); // Change to your home route
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed. Please check your credentials.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Image.asset('assets/img/awareplus-logo.png', height: 150),
              SizedBox(height: 30),
              Text(
                'Welcome Back!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextFormField(
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    final emailRegex = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    );
                    return emailRegex.hasMatch(value)
                        ? null
                        : 'Enter a valid email';
                  },
                  onSaved: (value) => _email = value!,
                ),
              ),
              SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator:
                      (value) => value!.isEmpty ? 'Password is required' : null,
                  onSaved: (value) => _password = value!,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _showForgotPasswordDialog,
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 231, 99, 110),
                      padding: EdgeInsets.all(20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child:
                        _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don’t have an account?',
                    style: TextStyle(fontSize: 16),
                  ),
                  TextButton(
                    onPressed:
                        () =>
                            Navigator.pushReplacementNamed(context, '/signup'),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
