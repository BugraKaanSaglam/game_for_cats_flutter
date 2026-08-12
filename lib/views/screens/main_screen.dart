import 'package:flutter/material.dart';
import 'package:game_for_cats_2025/l10n/app_localizations.dart';
import 'package:game_for_cats_2025/routing/app_routes.dart';
import 'package:game_for_cats_2025/services/app_analytics.dart';
import 'package:game_for_cats_2025/state/app_state.dart';
import 'package:game_for_cats_2025/views/components/hunt_ui.dart';
import 'package:game_for_cats_2025/views/components/main_app_bar.dart';
import 'package:game_for_cats_2025/views/theme/paw_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    AppAnalytics.screenView('main_menu');
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final l10n = AppLocalizations.of(context)!;
    if (!appState.isReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final settings = appState.settings;
    if (settings == null || appState.initError != null) {
      return Scaffold(
        appBar: MainAppBar(title: l10n.game_name, hasBackButton: false),
        body: _StateCard(
          title: l10n.error,
          subtitle: l10n.state_retry,
          onPressed: () => context.read<AppState>().initialize(),
        ),
      );
    }
    return Scaffold(
      body: HuntPageBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(HuntSpacing.md),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _GameLogo(title: l10n.game_name),
                    const SizedBox(height: HuntSpacing.lg),
                    _MainMenuButton(
                      label: l10n.start_button,
                      icon: Icons.play_arrow_rounded,
                      color: HuntColors.sun,
                      foreground: HuntColors.ink,
                      large: true,
                      onPressed: () {
                        AppAnalytics.track(AnalyticsEvent.gameStarted);
                        context.go(AppRoutes.game, extra: settings);
                      },
                    ),
                    const SizedBox(height: HuntSpacing.md),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final width =
                            (constraints.maxWidth - HuntSpacing.sm) / 2;
                        return Wrap(
                          alignment: WrapAlignment.center,
                          spacing: HuntSpacing.sm,
                          runSpacing: HuntSpacing.sm,
                          children: [
                            SizedBox(
                              width: width,
                              child: _MainMenuButton(
                                label: l10n.activity_button,
                                icon: Icons.menu_book_rounded,
                                color: HuntColors.sky,
                                onPressed: () => context.go(AppRoutes.activity),
                              ),
                            ),
                            SizedBox(
                              width: width,
                              child: _MainMenuButton(
                                label: l10n.settings_button,
                                icon: Icons.tune_rounded,
                                color: HuntColors.coral,
                                onPressed: () => context.go(AppRoutes.settings),
                              ),
                            ),
                            SizedBox(
                              width: width,
                              child: _MainMenuButton(
                                label: l10n.howtoplay_button,
                                icon: Icons.lightbulb_rounded,
                                color: HuntColors.field,
                                foreground: HuntColors.ink,
                                onPressed: () =>
                                    context.go(AppRoutes.howToPlay),
                              ),
                            ),
                            SizedBox(
                              width: width,
                              child: _MainMenuButton(
                                label: l10n.about_button,
                                icon: Icons.info_rounded,
                                color: HuntColors.paper,
                                foreground: HuntColors.ink,
                                onPressed: () => context.go(AppRoutes.about),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GameLogo extends StatelessWidget {
  const _GameLogo({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: HuntColors.paper,
            shape: BoxShape.circle,
            border: Border.all(color: HuntColors.sun, width: 5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 14,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: const Icon(
            Icons.pets_rounded,
            color: HuntColors.coral,
            size: 44,
          ),
        ),
        const SizedBox(height: HuntSpacing.md),
        Text(
          title,
          textAlign: TextAlign.center,
          style: HuntTextStyles.display.copyWith(
            color: HuntColors.paper,
            shadows: const [
              Shadow(
                color: Colors.black54,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MainMenuButton extends StatelessWidget {
  const _MainMenuButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.foreground = HuntColors.paper,
    this.large = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color foreground;
  final bool large;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(HuntRadii.lg),
        elevation: 5,
        shadowColor: Colors.black45,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(HuntRadii.lg),
          child: SizedBox(
            height: large ? 68 : 58,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(HuntRadii.lg),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/button.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    opacity: const AlwaysStoppedAnimation(0.92),
                  ),
                  ColoredBox(color: color.withValues(alpha: 0.48)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: foreground, size: large ? 30 : 23),
                      const SizedBox(width: HuntSpacing.sm),
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: HuntTextStyles.action.copyWith(
                            color: foreground,
                            fontSize: large ? 19 : 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: HuntSurface(
        margin: const EdgeInsets.all(HuntSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: HuntTextStyles.sectionTitle),
            const SizedBox(height: HuntSpacing.sm),
            Text(subtitle, style: HuntTextStyles.supporting),
            const SizedBox(height: HuntSpacing.md),
            HuntActionButton(label: subtitle, onPressed: onPressed),
          ],
        ),
      ),
    );
  }
}
