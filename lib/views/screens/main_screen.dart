import 'package:flutter/material.dart';
import 'package:mice_and_paws_cat_game/l10n/app_localizations.dart';
import 'package:mice_and_paws_cat_game/routing/app_routes.dart';
import 'package:mice_and_paws_cat_game/services/app_analytics.dart';
import 'package:mice_and_paws_cat_game/state/app_state.dart';
import 'package:mice_and_paws_cat_game/views/components/hunt_ui.dart';
import 'package:mice_and_paws_cat_game/views/theme/paw_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Main navigation hub for starting a hunt and opening supporting screens.
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
      return HuntCorePage(showAppBar: false, child: const HuntLoadingState());
    }
    final settings = appState.settings;
    if (settings == null || appState.initError != null) {
      return HuntCorePage(
        title: l10n.game_name,
        hasBackButton: false,
        child: HuntStateCard(
          title: l10n.error,
          message: l10n.state_error_subtitle,
          actionLabel: l10n.state_retry,
          onAction: () => context.read<AppState>().initialize(),
          icon: Icons.warning_amber_rounded,
        ),
      );
    }
    return HuntCorePage(
      showAppBar: false,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(HuntSpacing.md),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                HuntSurface(
                  tone: HuntSurfaceTone.field,
                  child: _GameLogo(title: l10n.game_name),
                ),
                const SizedBox(height: HuntSpacing.lg),
                HuntMenuButton(
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
                    final width = (constraints.maxWidth - HuntSpacing.sm) / 2;
                    return Wrap(
                      alignment: WrapAlignment.center,
                      spacing: HuntSpacing.sm,
                      runSpacing: HuntSpacing.sm,
                      children: [
                        SizedBox(
                          width: width,
                          child: HuntMenuButton(
                            label: l10n.activity_button,
                            icon: Icons.menu_book_rounded,
                            color: HuntColors.sky,
                            onPressed: () => context.go(AppRoutes.activity),
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: HuntMenuButton(
                            label: l10n.settings_button,
                            icon: Icons.tune_rounded,
                            color: HuntColors.coral,
                            onPressed: () => context.go(AppRoutes.settings),
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: HuntMenuButton(
                            label: l10n.howtoplay_button,
                            icon: Icons.lightbulb_rounded,
                            color: HuntColors.field,
                            foreground: HuntColors.ink,
                            onPressed: () => context.go(AppRoutes.howToPlay),
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: HuntMenuButton(
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
