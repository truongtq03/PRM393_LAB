import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Lab 7.1–7.4: paste this entire file into DartPad (Flutter mode).
void main() => runApp(const SignupApp());

class SignupApp extends StatelessWidget {
  const SignupApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Lab 7 • Signup',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF315BCE)),
          scaffoldBackgroundColor: const Color(0xFFF4F6FB),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
            errorMaxLines: 3,
          ),
        ),
        home: const SignupScreen(),
      );
}

// Lab 7.2: reusable synchronous validators; null means valid.
class SignupValidators {
  static String? fullName(String? value) =>
      value == null || value.trim().isEmpty ? 'Full name is required.' : null;

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required.';
    if (!RegExp(r'^[^\s@]+@[^\s@.]+(?:\.[^\s@.]+)+$').hasMatch(email)) {
      return 'Enter a valid email, for example name@example.com.';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.trim().isEmpty) return 'Password is required.';
    if (value.length < 8) return 'Use at least 8 characters.';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Include at least one digit.';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Confirm your password.';
    if (value != password) return 'Passwords do not match.';
    return null;
  }
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Lab 7.1: FormState validates and saves the input together.
  final formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  // Lab 7.3: explicit keyboard traversal and lifecycle cleanup.
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _hidePassword = true;
  bool _hideConfirm = true;
  bool _isCheckingEmail = false;
  String? _emailAvailabilityError;
  String _savedName = '';
  String _savedEmail = '';

  @override
  void dispose() {
    for (final controller in [
      _nameController,
      _emailController,
      _passwordController,
      _confirmController,
    ]) {
      controller.dispose();
    }
    for (final node in [
      _nameFocus,
      _emailFocus,
      _passwordFocus,
      _confirmFocus,
    ]) {
      node.dispose();
    }
    super.dispose();
  }

  String? _validateEmail(String? value) =>
      SignupValidators.email(value) ?? _emailAvailabilityError;

  void _focusFirstError() {
    final checks = <(String?, FocusNode)>[
      (SignupValidators.fullName(_nameController.text), _nameFocus),
      (_validateEmail(_emailController.text), _emailFocus),
      (SignupValidators.password(_passwordController.text), _passwordFocus),
      (
        SignupValidators.confirmPassword(
          _confirmController.text,
          _passwordController.text,
        ),
        _confirmFocus,
      ),
    ];
    for (final (error, focus) in checks) {
      if (error != null) {
        FocusScope.of(context).requestFocus(focus);
        return;
      }
    }
  }

  Future<void> _submit() async {
    // Guard keyboard Done as well as button taps against duplicate requests.
    if (_isCheckingEmail) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (!formKey.currentState!.validate()) {
      _focusFirstError();
      return;
    }
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim().toLowerCase();
    setState(() => _isCheckingEmail = true);

    // Lab 7.4: simulated API; no real account is created or data sent.
    try {
      await Future<void>.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      if (email.startsWith('taken')) {
        setState(
          () => _emailAvailabilityError = 'This email is already taken.',
        );
        formKey.currentState!.validate();
        _emailFocus.requestFocus();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This email is already taken.')),
        );
        return;
      }
      formKey.currentState!.save();
      TextInput.finishAutofillContext();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Signup successful! Welcome, $_savedName. '
            'Email: $_savedEmail (demo).',
          ),
          duration: const Duration(seconds: 6),
          backgroundColor: const Color(0xFF176B45),
        ),
      );
    } finally {
      if (mounted) setState(() => _isCheckingEmail = false);
    }
  }

  Widget _visibilityButton({required bool confirm}) {
    final hidden = confirm ? _hideConfirm : _hidePassword;
    return IconButton(
      tooltip:
          '${hidden ? 'Show' : 'Hide'} ${confirm ? 'confirm password' : 'password'}',
      onPressed: _isCheckingEmail
          ? null
          : () => setState(() {
                if (confirm) {
                  _hideConfirm = !_hideConfirm;
                } else {
                  _hidePassword = !_hidePassword;
                }
              }),
      icon: Icon(
        hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      ),
    );
  }

  Widget _passwordStrength() {
    final password = _passwordController.text;
    final meetsRules = SignupValidators.password(password) == null;
    final strong = meetsRules &&
        password.length >= 12 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[^a-zA-Z0-9\s]').hasMatch(password);
    final label = password.isEmpty
        ? 'Not entered'
        : strong
            ? 'Strong'
            : meetsRules
                ? 'Medium'
                : 'Weak';
    final color = password.isEmpty
        ? Colors.blueGrey
        : strong
            ? const Color(0xFF176B45)
            : meetsRules
                ? const Color(0xFF916000)
                : Theme.of(context).colorScheme.error;
    return Semantics(
      liveRegion: true,
      label: 'Password strength: $label',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: password.isEmpty
                ? 0
                : strong
                    ? 1
                    : meetsRules
                        ? 0.65
                        : 0.3,
            color: color,
            backgroundColor: const Color(0xFFE3E7F0),
            borderRadius: BorderRadius.circular(4),
            minHeight: 5,
          ),
          const SizedBox(height: 6),
          Text('Password strength: $label', style: TextStyle(color: color)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Signup'),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          body: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: AutofillGroup(
                  child: Form(
                    key: formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      children: [
                        Icon(
                          Icons.person_add_alt_1_rounded,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Create your account',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Fill in your details to get started. All fields are required.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),
                        TextFormField(
                          controller: _nameController,
                          focusNode: _nameFocus,
                          readOnly: _isCheckingEmail,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.name],
                          decoration: const InputDecoration(
                            labelText: 'Full name',
                            hintText: 'Nguyen Van An',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: SignupValidators.fullName,
                          onSaved: (value) => _savedName = value!.trim(),
                          onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _emailController,
                          focusNode: _emailFocus,
                          readOnly: _isCheckingEmail,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          autocorrect: false,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'an@example.com',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: _validateEmail,
                          onChanged: (_) =>
                              setState(() => _emailAvailabilityError = null),
                          onSaved: (value) =>
                              _savedEmail = value!.trim().toLowerCase(),
                          onFieldSubmitted: (_) =>
                              _passwordFocus.requestFocus(),
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          readOnly: _isCheckingEmail,
                          obscureText: _hidePassword,
                          enableSuggestions: false,
                          autocorrect: false,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.newPassword],
                          decoration: InputDecoration(
                            labelText: 'Password',
                            helperText:
                                'At least 8 characters, including a digit.',
                            helperMaxLines: 2,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: _visibilityButton(confirm: false),
                          ),
                          validator: SignupValidators.password,
                          onChanged: (_) => setState(() {}),
                          onFieldSubmitted: (_) => _confirmFocus.requestFocus(),
                        ),
                        const SizedBox(height: 10),
                        _passwordStrength(),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _confirmController,
                          focusNode: _confirmFocus,
                          readOnly: _isCheckingEmail,
                          obscureText: _hideConfirm,
                          enableSuggestions: false,
                          autocorrect: false,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.newPassword],
                          decoration: InputDecoration(
                            labelText: 'Confirm password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: _visibilityButton(confirm: true),
                          ),
                          validator: (value) =>
                              SignupValidators.confirmPassword(
                            value,
                            _passwordController.text,
                          ),
                          onFieldSubmitted: (_) => _submit(),
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: _isCheckingEmail ? null : _submit,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                          ),
                          child: _isCheckingEmail
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text('Checking email…'),
                                  ],
                                )
                              : const Text('Create account'),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Lab 7 demo • Email check takes 2 seconds.\n'
                          'Emails starting with "taken" are unavailable.\n'
                          'No real account is created.',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: 12, color: Color(0xFF515C70)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
