import 'package:flutter/material.dart';
import 'package:lotto_vision/presentation/screens/camera/camera_screen.dart';
import 'package:lotto_vision/presentation/screens/history/history_screen.dart';
import 'package:lotto_vision/presentation/screens/notifications/notification_screen.dart';
import 'package:lotto_vision/presentation/screens/prediction/prediction_screen.dart';
import 'package:lotto_vision/presentation/screens/results/results_screen.dart';
import 'package:lotto_vision/presentation/screens/settings/settings_screen.dart';
import 'package:lotto_vision/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeTab(),
    ResultsScreen(),
    HistoryScreen(),
    PredictionScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final navItems = _buildNavItems(l10n);

    return Scaffold(
      extendBody: true,
      body: _screens[_currentIndex],
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0B0D12),
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: List.generate(navItems.length, (index) {
              final item = navItems[index];
              final selected = _currentIndex == index;

                return Expanded(
                  child: _buildNavItem(
                    item: item,
                    selected: selected,
                    onTap: () {
                      if (_currentIndex == index) return;
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
              );
            }),
          ),
        ),
      ),
    );
  }

  List<_BottomNavItem> _buildNavItems(AppLocalizations l10n) {
    return [
      _BottomNavItem(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
        label: l10n.home,
      ),
      _BottomNavItem(
        icon: Icons.emoji_events_outlined,
        selectedIcon: Icons.emoji_events,
        label: l10n.results,
      ),
      _BottomNavItem(
        icon: Icons.history,
        selectedIcon: Icons.history,
        label: l10n.history,
      ),
      _BottomNavItem(
        icon: Icons.show_chart,
        selectedIcon: Icons.show_chart,
        label: 'Prediction',
      ),
      _BottomNavItem(
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings,
        label: l10n.settings,
      ),
    ];
  }

  Widget _buildNavItem({
    required _BottomNavItem item,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
                children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    selected ? item.selectedIcon : item.icon,
                    color: selected
                        ? const Color(0xFF101218)
                        : Colors.white.withOpacity(0.78),
                    size: selected ? 26 : 21,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(selected ? 1 : 0.82),
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 11,
                    letterSpacing: 0.1,
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

class _BottomNavItem {
  const _BottomNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                'assets/images/New_Logo.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                l10n.appName,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontFamily: 'serif',
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: colorScheme.surface,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeroCard(context, l10n),
                const SizedBox(height: 20),
                Text(
                  'Quick Actions',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _buildQuickActionCard(
                  context: context,
                  title: l10n.results,
                  subtitle: 'Check latest draw results',
                  icon: Icons.emoji_events_outlined,
                  onTap: () => _navigateTo(context, const ResultsScreen()),
                  isPrimary: true,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        context: context,
                        title: l10n.history,
                        subtitle: 'Review scanned tickets',
                        icon: Icons.history,
                        onTap: () => _navigateTo(context, const HistoryScreen()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionCard(
                        context: context,
                        title: 'Prediction',
                        subtitle: 'View smart number insights',
                        icon: Icons.show_chart,
                        onTap: () =>
                            _navigateTo(context, const PredictionScreen()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildHowItWorksCard(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Widget _buildHeroCard(BuildContext context, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withOpacity(0.9),
            colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -10,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: colorScheme.onPrimary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: colorScheme.onPrimary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 18,
                      color: colorScheme.onPrimary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Smart Ticket Scanner',
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.scanTicket,
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${l10n.takePhoto}. Results are verified in seconds.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimary.withOpacity(0.92),
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.onPrimary,
                    foregroundColor: colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () => _navigateTo(context, const CameraScreen()),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: Text(l10n.scan),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (isPrimary) {
      return Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.primary.withOpacity(0.88),
                colorScheme.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: colorScheme.onPrimary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onPrimary.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: colorScheme.onPrimary,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: colorScheme.surface.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.45),
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHowItWorksCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.lightbulb_outline,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'How it works',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _buildStep(context, 1, 'Take a clear photo of your lottery ticket'),
            _buildStep(context, 2, 'We extract the numbers using OCR technology'),
            _buildStep(context, 3, 'Check against official results'),
            _buildStep(context, 4, 'Get instant winning notifications'),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, int stepNumber, String text) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$stepNumber',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
