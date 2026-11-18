import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _showPassword = false;
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.signIn(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      rememberMe: _rememberMe,
    );
    if (!ok && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(auth.error ?? 'Sign-in failed.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: context.colorBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space24,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.sizeOf(context).height -
                  MediaQuery.paddingOf(context).vertical,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const SizedBox(height: AppDimensions.space48),

                  // ─── Logo ────────────────────────────────────────────────
                  _LogoSection()
                      .animate()
                      .fadeIn(duration: const Duration(milliseconds: 500))
                      .scale(
                        begin: const Offset(0.88, 0.88),
                        end: const Offset(1.0, 1.0),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutBack,
                      ),

                  const SizedBox(height: AppDimensions.space40),

                  // ─── Heading ──────────────────────────────────────────────
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back',
                          style: AppTypography.displayMedium(
                            color: context.colorText,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.space8),
                        Text(
                          'Sign in to continue your smarter journey.',
                          style: AppTypography.bodyMedium(
                            color: context.colorMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate(delay: const Duration(milliseconds: 100))
                      .fadeIn(duration: const Duration(milliseconds: 400))
                      .slideY(
                        begin: 0.06,
                        end: 0,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                      ),

                  const SizedBox(height: AppDimensions.space32),

                  // ─── Demo notice ──────────────────────────────────────────
                  _DemoNotice()
                      .animate(delay: const Duration(milliseconds: 150))
                      .fadeIn(duration: const Duration(milliseconds: 400)),

                  const SizedBox(height: AppDimensions.space24),

                  // ─── Form ─────────────────────────────────────────────────
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Email address',
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: context.colorMuted,
                            ),
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
                        const SizedBox(height: AppDimensions.space16),
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: !_showPassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(
                              Icons.lock_outlined,
                              color: context.colorMuted,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: context.colorMuted,
                              ),
                              onPressed: () => setState(
                                () => _showPassword = !_showPassword,
                              ),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Please enter your password.';
                            }
                            if (v.length < 6) {
                              return 'Password must be at least 6 characters.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppDimensions.space8),
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (v) =>
                                  setState(() => _rememberMe = v ?? true),
                            ),
                            Text(
                              'Remember me',
                              style: AppTypography.bodySmall(
                                color: context.colorMuted,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () =>
                                  context.push('/forgot-password'),
                              child: Text(
                                'Forgot password?',
                                style: AppTypography.labelMedium(
                                  color: AppColors.electricLime,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                      .animate(delay: const Duration(milliseconds: 200))
                      .fadeIn(duration: const Duration(milliseconds: 400))
                      .slideY(
                        begin: 0.04,
                        end: 0,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                      ),

                  const SizedBox(height: AppDimensions.space24),

                  // ─── Sign-in button ───────────────────────────────────────
                  SrButton(
                    label: 'Sign In',
                    onPressed: _submit,
                    isLoading: auth.isLoading,
                    icon: Icons.arrow_forward_rounded,
                  )
                      .animate(delay: const Duration(milliseconds: 280))
                      .fadeIn(duration: const Duration(milliseconds: 400)),

                  const SizedBox(height: AppDimensions.space16),

                  SrButton(
                    label: 'Continue as Guest (Demo)',
                    onPressed: auth.isLoading
                        ? null
                        : () =>
                            context.read<AuthProvider>().continueAsGuest(),
                    isSecondary: true,
                    icon: Icons.explore_outlined,
                  )
                      .animate(delay: const Duration(milliseconds: 320))
                      .fadeIn(duration: const Duration(milliseconds: 400)),

                  const Spacer(),

                  // ─── Sign-up link ─────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppDimensions.space24,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: AppTypography.bodySmall(
                            color: context.colorMuted,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/signup'),
                          child: Text(
                            'Create account',
                            style: AppTypography.labelMedium(
                              color: AppColors.electricLime,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate(delay: const Duration(milliseconds: 400))
                      .fadeIn(duration: const Duration(milliseconds: 400)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Reusable auth widgets ────────────────────────────────────────────────────

class _LogoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 72,
          child: Image.asset(
            'assets/brand/smartroute_original.png.png',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: AppDimensions.space12),
        Text(
          'SmartRoute Uganda',
          style: AppTypography.labelLarge(
            color: context.isDark
                ? AppColors.cloudWhite.withValues(alpha: 0.5)
                : AppColors.graphite.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class _DemoNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space16,
        vertical: AppDimensions.space12,
      ),
      decoration: BoxDecoration(
        color: AppColors.electricLime.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: AppColors.electricLime.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            size: 16,
            color: AppColors.electricLime,
          ),
          const SizedBox(width: AppDimensions.space8),
          Expanded(
            child: Text(
              'Demo mode: use any email and a password of 6+ characters.',
              style: AppTypography.caption(color: AppColors.electricLime),
            ),
          ),
        ],
      ),
    );
  }
}
