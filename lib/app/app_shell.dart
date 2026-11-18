import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/app_dimensions.dart';
import '../core/services/app_providers.dart';
import '../shared/widgets/shared_widgets.dart';

/// The main application shell providing adaptive navigation.
/// Mobile: bottom navigation bar.
/// Tablet/desktop: navigation rail or sidebar.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Home',
      path: '/home',
    ),
    _NavItem(
      icon: Icons.alt_route_outlined,
      selectedIcon: Icons.alt_route_rounded,
      label: 'Routes',
      path: '/routes',
    ),
    _NavItem(
      icon: Icons.report_outlined,
      selectedIcon: Icons.report_rounded,
      label: 'Reports',
      path: '/reports',
    ),
    _NavItem(
      icon: Icons.bookmark_border_rounded,
      selectedIcon: Icons.bookmark_rounded,
      label: 'Saved',
      path: '/saved',
    ),
    _NavItem(
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      label: 'Profile',
      path: '/profile',
    ),
  ];

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (var i = 0; i < _navItems.length; i++) {
      if (location.startsWith(_navItems[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final isWide = context.isWide;
    final unreadCount = context.watch<NotificationsProvider>().unreadCount;
    final selectedIndex = _selectedIndex(context);

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            _NavRail(
              items: _navItems,
              selectedIndex: selectedIndex,
              unreadCount: unreadCount,
            ),
            VerticalDivider(
              width: 1,
              color: context.colorCardBorder,
            ),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: _BottomNav(
        items: _navItems,
        selectedIndex: selectedIndex,
        unreadCount: unreadCount,
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.path,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String path;
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.items,
    required this.selectedIndex,
    required this.unreadCount,
  });

  final List<_NavItem> items;
  final int selectedIndex;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bg = isDark ? AppColors.darkCard : AppColors.pureWhite;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppDimensions.bottomNavHeight,
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isSelected = i == selectedIndex;
              final color = isSelected
                  ? AppColors.electricLime
                  : context.colorMuted;
              final showBadge = i == 0 && unreadCount > 0;

              return Expanded(
                child: _NavTile(
                  item: item,
                  isSelected: isSelected,
                  color: color,
                  showBadge: showBadge,
                  unreadCount: unreadCount,
                  onTap: () => context.go(item.path),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatefulWidget {
  const _NavTile({
    required this.item,
    required this.isSelected,
    required this.color,
    required this.showBadge,
    required this.unreadCount,
    required this.onTap,
  });

  final _NavItem item;
  final bool isSelected;
  final Color color;
  final bool showBadge;
  final int unreadCount;
  final VoidCallback onTap;

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 160),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (_, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Indicator dot above selected icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.isSelected ? 20 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.electricLime,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
            ),
            const SizedBox(height: 4),
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    widget.isSelected
                        ? widget.item.selectedIcon
                        : widget.item.icon,
                    key: ValueKey(widget.isSelected),
                    color: widget.color,
                    size: AppDimensions.iconMd,
                  ),
                ),
                if (widget.showBadge)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppColors.hazardRed,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          widget.unreadCount > 9
                              ? '9+'
                              : '${widget.unreadCount}',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ).animate().scale(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.elasticOut,
                        ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: AppTypography.labelSmall(color: widget.color),
              child: Text(widget.item.label),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavRail extends StatelessWidget {
  const _NavRail({
    required this.items,
    required this.selectedIndex,
    required this.unreadCount,
  });

  final List<_NavItem> items;
  final int selectedIndex;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bg = isDark ? AppColors.darkCard : AppColors.pureWhite;

    return Container(
      width: AppDimensions.sidebarWidth,
      color: bg,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppDimensions.space24),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space16,
              ),
              child: Image.asset(
                'assets/brand/smartroute_original.png.png',
                height: 40,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: AppDimensions.space32),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: items.length,
                itemBuilder: (ctx, i) {
                  final item = items[i];
                  final isSelected = i == selectedIndex;
                  final color = isSelected
                      ? AppColors.electricLime
                      : context.colorMuted;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.space12,
                      vertical: AppDimensions.space4,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.electricLime.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMd),
                        border: isSelected
                            ? Border.all(
                                color: AppColors.electricLime
                                    .withValues(alpha: 0.25),
                                width: 1,
                              )
                            : null,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => ctx.go(item.path),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMd,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.space12,
                              vertical: AppDimensions.space12,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected ? item.selectedIcon : item.icon,
                                  color: color,
                                  size: AppDimensions.iconMd,
                                ),
                                const SizedBox(width: AppDimensions.space12),
                                Text(
                                  item.label,
                                  style:
                                      AppTypography.labelLarge(color: color),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
