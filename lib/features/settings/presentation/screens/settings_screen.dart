import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../features/authentication/presentation/auth_provider.dart';
import '../../../../shared/widgets/shared_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: context.colorBackground,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.space16),
        children: [
          // ── Appearance ─────────────────────────────────────────────
          _SectionHeader('Appearance'),
          SrCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _ThemeRadio(
                  label: 'System Default',
                  subtitle: 'Follow device theme',
                  icon: Icons.brightness_auto_rounded,
                  value: ThemeMode.system,
                  groupValue: themeProvider.themeMode,
                  onChanged: themeProvider.setThemeMode,
                ),
                _Divider(),
                _ThemeRadio(
                  label: 'Light Mode',
                  subtitle: 'Always use light theme',
                  icon: Icons.light_mode_rounded,
                  value: ThemeMode.light,
                  groupValue: themeProvider.themeMode,
                  onChanged: themeProvider.setThemeMode,
                ),
                _Divider(),
                _ThemeRadio(
                  label: 'Dark Mode',
                  subtitle: 'Always use dark theme',
                  icon: Icons.dark_mode_rounded,
                  value: ThemeMode.dark,
                  groupValue: themeProvider.themeMode,
                  onChanged: themeProvider.setThemeMode,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space24),

          // ── Navigation & travel ────────────────────────────────────
          _SectionHeader('Navigation & Travel'),
          SrCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.directions_car_rounded,
                  label: 'Preferred Vehicle',
                  subtitle: 'Toyota Premio (Demo)',
                  onTap: () => context.push('/vehicles'),
                ),
                _Divider(),
                _SettingsTile(
                  icon: Icons.attach_money_rounded,
                  label: 'Currency',
                  subtitle: 'UGX — Ugandan Shilling',
                  onTap: null,
                ),
                _Divider(),
                _SettingsTile(
                  icon: Icons.local_gas_station_rounded,
                  label: 'Default Fuel Price',
                  subtitle: 'UGX 5,600 / litre (editable in fuel calculator)',
                  onTap: () => context.push('/fuel'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space24),

          // ── Notifications ──────────────────────────────────────────
          _SectionHeader('Notifications'),
          SrCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsSwitchTile(
                  icon: Icons.traffic_rounded,
                  label: 'Road Condition Alerts',
                  subtitle: 'Get notified of nearby road conditions',
                  value: true,
                  onChanged: (_) {},
                ),
                _Divider(),
                _SettingsSwitchTile(
                  icon: Icons.report_rounded,
                  label: 'Report Confirmations',
                  subtitle: 'When your reports are confirmed',
                  value: true,
                  onChanged: (_) {},
                ),
                _Divider(),
                _SettingsSwitchTile(
                  icon: Icons.campaign_rounded,
                  label: 'Product Updates',
                  subtitle: 'SmartRoute news and announcements',
                  value: false,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space24),

          // ── Privacy ────────────────────────────────────────────────
          _SectionHeader('Privacy'),
          SrCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.location_on_outlined,
                  label: 'Location Permissions',
                  subtitle: 'Manage how SmartRoute uses your location',
                  onTap: () => _showLocationInfo(context),
                ),
                _Divider(),
                _SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy Policy',
                  subtitle: 'How we handle your information',
                  onTap: () => context.push('/help'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space24),

          // ── Account ────────────────────────────────────────────────
          _SectionHeader('Account'),
          SrCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.person_outlined,
                  label: 'Account Type',
                  subtitle: (auth.user?.isBusiness ?? false)
                      ? 'Transport Business'
                      : 'Individual Driver',
                  onTap: null,
                ),
                _Divider(),
                _SettingsTile(
                  icon: Icons.info_outline_rounded,
                  label: 'About SmartRoute Uganda',
                  subtitle: 'Version 1.0.0 · Demo build',
                  onTap: () => context.push('/help'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space24),

          SrButton(
            label: 'Sign Out',
            onPressed: () => auth.signOut(),
            isSecondary: true,
            icon: Icons.logout_rounded,
          ),
          const SizedBox(height: AppDimensions.space32),
        ],
      ),
    );
  }

  void _showLocationInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Location Permissions'),
        content: Text(
          'SmartRoute uses your location to:\n\n'
          '• Show nearby road conditions\n'
          '• Set your starting point for route planning\n'
          '• Improve route accuracy\n\n'
          'Location is only accessed when you are actively using navigation features. '
          'In this demo version, no location data is stored or transmitted.',
          style: AppTypography.bodyMedium(color: context.colorText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppDimensions.space8,
        left: AppDimensions.space4,
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.labelSmall(color: context.colorMuted)
            .copyWith(letterSpacing: 1.0),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: AppDimensions.space56,
      color: context.colorCardBorder,
    );
  }
}

class _ThemeRadio extends StatelessWidget {
  const _ThemeRadio({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });
  final String label;
  final String subtitle;
  final IconData icon;
  final ThemeMode value;
  final ThemeMode groupValue;
  final void Function(ThemeMode) onChanged;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.electricLime : context.colorMuted,
      ),
      title: Text(
        label,
        style: AppTypography.labelLarge(color: context.colorText),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall(color: context.colorMuted),
      ),
      trailing: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: value == groupValue
                ? AppColors.electricLime
                : context.colorMuted,
            width: 2,
          ),
        ),
        child: value == groupValue
            ? Center(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: AppColors.electricLime,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            : null,
      ),
      onTap: () => onChanged(value),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: context.colorMuted),
      title: Text(
        label,
        style: AppTypography.labelLarge(color: context.colorText),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall(color: context.colorMuted),
      ),
      trailing: onTap != null
          ? Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: context.colorMuted,
            )
          : null,
      onTap: onTap,
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: context.colorMuted),
      title: Text(
        label,
        style: AppTypography.labelLarge(color: context.colorText),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall(color: context.colorMuted),
      ),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}
