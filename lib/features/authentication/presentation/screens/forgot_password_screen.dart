import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.sendPasswordReset(_emailCtrl.text.trim());
    if (mounted) setState(() => _sent = ok);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: context.colorBackground,
      appBar: AppBar(
        title: const Text('Reset Password'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space24),
          child: _sent
              ? _SuccessState(email: _emailCtrl.text)
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppDimensions.space16),
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.space16),
                        decoration: BoxDecoration(
                          color: AppColors.signalCyan.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusFull,
                          ),
                        ),
                        child: const Icon(
                          Icons.lock_reset_rounded,
                          size: 32,
                          color: AppColors.signalCyan,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space24),
                      Text(
                        'Forgot your password?',
                        style: AppTypography.displayMedium(
                          color: context.colorText,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space8),
                      Text(
                        'Enter your registered email address and we\'ll send you instructions to reset your password.',
                        style: AppTypography.bodyMedium(
                          color: context.colorMuted,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space32),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: const InputDecoration(
                          labelText: 'Email address',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Please enter your email address.';
                          }
                          if (!v.contains('@')) {
                            return 'Please enter a valid email address.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.space24),
                      SrButton(
                        label: 'Send Reset Instructions',
                        onPressed: _submit,
                        isLoading: auth.isLoading,
                        icon: Icons.send_rounded,
                      ),
                      const SizedBox(height: AppDimensions.space16),
                      Center(
                        child: TextButton(
                          onPressed: () => context.pop(),
                          child: Text(
                            'Back to sign in',
                            style: AppTypography.labelMedium(
                              color: context.colorMuted,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _SuccessState extends StatelessWidget {
  const _SuccessState({required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppDimensions.space32),
        Container(
          padding: const EdgeInsets.all(AppDimensions.space24),
          decoration: BoxDecoration(
            color: AppColors.successGreen.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            size: 48,
            color: AppColors.successGreen,
          ),
        ),
        const SizedBox(height: AppDimensions.space24),
        Text(
          'Instructions sent',
          style: AppTypography.headingLarge(color: context.colorText),
        ),
        const SizedBox(height: AppDimensions.space12),
        Text(
          'If an account exists for $email, you will receive password reset instructions shortly.',
          style: AppTypography.bodyMedium(color: context.colorMuted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.space8),
        Text(
          'Note: This is a demo — no actual email is sent.',
          style: AppTypography.caption(color: AppColors.cautionAmber),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.space32),
        SrButton(
          label: 'Back to Sign In',
          onPressed: () => context.go('/login'),
          icon: Icons.arrow_back_rounded,
        ),
      ],
    );
  }
}
