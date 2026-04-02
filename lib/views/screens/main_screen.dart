// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:game_for_cats_2025/models/database/db_error.dart';
import 'package:game_for_cats_2025/models/app_settings.dart';
import 'package:game_for_cats_2025/models/enums/enum_functions.dart';
import 'package:game_for_cats_2025/models/enums/game_enums.dart';
import 'package:game_for_cats_2025/l10n/app_localizations.dart';
import 'package:game_for_cats_2025/routing/app_routes.dart';
import 'package:game_for_cats_2025/services/app_analytics.dart';
import 'package:game_for_cats_2025/state/app_state.dart';
import 'package:game_for_cats_2025/views/widgets/animated_gradient_background.dart';
import 'package:game_for_cats_2025/views/widgets/cool_animated_buttons.dart';
import 'package:game_for_cats_2025/views/theme/paw_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../components/main_app_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late AnimationController _buttonController;
  late AnimationController _ambientController;
  final List<_OrbConfig> _orbConfigs = const [
    _OrbConfig(
      alignment: Alignment(-0.9, -0.8),
      color: Color(0xFFFFD6E8),
      size: 190,
      travel: 0.08,
    ),
    _OrbConfig(
      alignment: Alignment(0.85, -0.6),
      color: Color(0xFFB8E1FF),
      size: 150,
      travel: 0.06,
      phase: 1.2,
    ),
    _OrbConfig(
      alignment: Alignment(-0.5, 0.75),
      color: Color(0xFFFFF5D7),
      size: 230,
      travel: 0.05,
      phase: 2.4,
    ),
  ];

  @override
  void initState() {
    super.initState();
    AppAnalytics.screenView('main_menu');
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5333),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _buttonController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    if (!appState.isReady) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: PawPalette.bubbleGum),
        ),
      );
    }

    final settings = appState.settings;
    if (appState.initError != null || settings == null) {
      return Scaffold(
        appBar: MainAppBar(
          title: AppLocalizations.of(context)!.game_name,
          hasBackButton: false,
        ),
        body: Center(child: dbError(context)),
      );
    }

    if (_buttonController.status != AnimationStatus.forward &&
        _buttonController.status != AnimationStatus.completed) {
      unawaited(_buttonController.forward());
    }

    return Scaffold(
      appBar: MainAppBar(
        title: AppLocalizations.of(context)!.game_name,
        hasBackButton: false,
      ),
      body: mainBody(context, settings),
    );
  }

  Widget mainBody(BuildContext context, AppSettings settings) {
    return AnimatedGradientBackground(
      child: Stack(
        children: [
          _buildAmbientOrbs(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding = constraints.maxWidth > 800
                    ? constraints.maxWidth * 0.25
                    : 24.0;
                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    20,
                    horizontalPadding,
                    32,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeroPanel(context),
                        const SizedBox(height: 18),
                        _buildSetupPanel(context, settings),
                        const SizedBox(height: 24),
                        Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 560),
                            child: _buildMenuButtons(constraints, settings),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _buildFooterLinks(context),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper function for staggered animation
  Widget _buildStaggeredAnimatedButton({
    required Widget child,
    required double delay,
  }) {
    final animation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _buttonController,
            curve: Interval(delay, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    return SlideTransition(
      position: animation,
      child: FadeTransition(
        opacity: _buttonController.drive(CurveTween(curve: Curves.easeIn)),
        child: child,
      ),
    );
  }

  Widget _buildHeroPanel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: PawPalette.midnight.withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: Colors.white.withValues(alpha: 0.12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Text(
                        l10n.home_kicker,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(l10n.home_headline, style: PawTextStyles.heading),
                    const SizedBox(height: 10),
                    Text(
                      l10n.home_subheadline,
                      style: PawTextStyles.subheading,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 112,
                height: 148,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/mainscreenbg.png'),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: PawPalette.midnight.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Icon(
                      Icons.pets_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSetupPanel(BuildContext context, AppSettings settings) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.home_setup_title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.home_setup_subtitle,
            style: const TextStyle(color: Color(0xFFD7D5F5), height: 1.35),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _SetupChip(
                icon: Icons.timer_outlined,
                label: _timeLabel(l10n, settings.time),
              ),
              _SetupChip(
                icon: Icons.track_changes_rounded,
                label: _difficultyLabel(l10n, settings.difficulty),
              ),
              _SetupChip(
                icon: Icons.image_outlined,
                label: settings.backgroundPath.isEmpty
                    ? l10n.home_default_playmat
                    : l10n.home_custom_playmat_ready,
              ),
              _SetupChip(
                icon: settings.muted
                    ? Icons.volume_off_rounded
                    : Icons.volume_up_rounded,
                label: settings.muted ? l10n.home_muted : l10n.home_sound_on,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButtons(BoxConstraints constraints, AppSettings settings) {
    final spacing = math.max(constraints.maxHeight * 0.018, 14.0);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        //! Game Start Button
        _buildStaggeredAnimatedButton(
          delay: 0.0,
          child: CoolAnimatedButton(
            text: AppLocalizations.of(context)!.start_button,
            icon: const Icon(Icons.arrow_right_alt_sharp),
            onPressed: () {
              AppAnalytics.track(
                AnalyticsEvent.gameStarted,
                parameters: <String, Object?>{
                  'difficulty': settings.difficulty,
                  'time': settings.time,
                },
              );
              context.go(AppRoutes.game, extra: settings);
            },
          ),
        ),
        SizedBox(height: spacing),
        Row(
          children: [
            Expanded(
              child: _buildStaggeredAnimatedButton(
                delay: 0.18,
                child: _SecondaryActionCard(
                  title: AppLocalizations.of(context)!.settings_button,
                  subtitle: AppLocalizations.of(
                    context,
                  )!.home_customize_subtitle,
                  icon: Icons.tune_rounded,
                  gradient: const [Color(0xFF4FACFE), Color(0xFF00C6A7)],
                  onTap: () => context.go(AppRoutes.settings),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStaggeredAnimatedButton(
                delay: 0.3,
                child: _SecondaryActionCard(
                  title: AppLocalizations.of(context)!.activity_button,
                  subtitle: AppLocalizations.of(context)!.home_journal_subtitle,
                  icon: Icons.insights_rounded,
                  gradient: const [Color(0xFFFF5D8F), Color(0xFFFF8C42)],
                  onTap: () => context.go(AppRoutes.activity),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooterLinks(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: [
        TextButton.icon(
          onPressed: () => context.go(AppRoutes.howToPlay),
          icon: const Icon(Icons.menu_book_rounded),
          label: Text(l10n.howtoplay_button),
        ),
        TextButton.icon(
          onPressed: () => context.go(AppRoutes.about),
          icon: const Icon(Icons.info_outline_rounded),
          label: Text(l10n.about_button),
        ),
      ],
    );
  }

  String _difficultyLabel(AppLocalizations l10n, int value) {
    return switch (getDifficultyFromValue(value)) {
      Difficulty.easy => l10n.difficulty_easy,
      Difficulty.medium => l10n.difficulty_medium,
      Difficulty.hard => l10n.difficulty_hard,
      Difficulty.sandbox => l10n.difficulty_sandbox,
    };
  }

  String _timeLabel(AppLocalizations l10n, int value) {
    final current = getTimeFromValue(value);
    if (current == Time.sandbox) {
      return l10n.difficulty_sandbox;
    }
    return '${current.value}s';
  }

  Widget _buildAmbientOrbs() {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ambientController,
        builder: (context, _) {
          return Stack(
            children: _orbConfigs.map((orb) {
              final oscillation =
                  math.sin(
                    (_ambientController.value * 2 * math.pi) + orb.phase,
                  ) *
                  orb.travel;
              final alignment = Alignment(
                (orb.alignment.x + oscillation).clamp(-1.0, 1.0),
                (orb.alignment.y + oscillation).clamp(-1.0, 1.0),
              );
              return Align(
                alignment: alignment,
                child: Container(
                  width: orb.size,
                  height: orb.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        orb.color.withValues(alpha: 0.45),
                        orb.color.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _SetupChip extends StatelessWidget {
  const _SetupChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SecondaryActionCard extends StatelessWidget {
  const _SecondaryActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: LinearGradient(colors: gradient),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withValues(alpha: 0.28),
                blurRadius: 18,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.16),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFFF6F4FF), height: 1.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrbConfig {
  const _OrbConfig({
    required this.alignment,
    required this.color,
    required this.size,
    required this.travel,
    this.phase = 0,
  });

  final Alignment alignment;
  final Color color;
  final double size;
  final double travel;
  final double phase;
}
