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
import 'package:game_for_cats_2025/views/widgets/paw_print.dart';
import 'package:game_for_cats_2025/views/theme/paw_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../components/main_app_bar.dart';

//* Main menu / first impression screen.
//! This screen carries a lot of App Review weight, so it is intentionally game-first and not utility-first.
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
          //* Ambient orbs keep the menu from feeling like a flat settings shell.
          _buildAmbientOrbs(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding = constraints.maxWidth > 800
                    ? constraints.maxWidth * 0.25
                    : 20.0;
                final topPadding = constraints.maxHeight < 780 ? 12.0 : 16.0;
                final bottomPadding = constraints.maxHeight < 780 ? 20.0 : 28.0;
                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    topPadding,
                    horizontalPadding,
                    bottomPadding,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 560),
                            child: _buildMenuStage(constraints, settings),
                          ),
                        ),
                        const SizedBox(height: 14),
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

  Widget _buildMenuStage(BoxConstraints constraints, AppSettings settings) {
    final isCompact = constraints.maxWidth < 470;
    //! The first fold is intentionally sparse now: no bulky hero card, only setup chips, paws, and actions.
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 6,
          top: 10,
          child: PawPrint(
            size: isCompact ? 14 : 16,
            color: Colors.white.withValues(alpha: 0.16),
            rotation: -0.14,
          ),
        ),
        Positioned(
          left: 34,
          top: 24,
          child: PawPrint(
            size: isCompact ? 10 : 12,
            color: Colors.white.withValues(alpha: 0.1),
            rotation: 0.08,
          ),
        ),
        Positioned(
          right: 18,
          top: 6,
          child: PawPrint(
            size: isCompact ? 15 : 17,
            color: Colors.white.withValues(alpha: 0.14),
            rotation: 0.12,
          ),
        ),
        Positioned(
          right: 44,
          top: 32,
          child: PawPrint(
            size: isCompact ? 11 : 13,
            color: Colors.white.withValues(alpha: 0.09),
            rotation: -0.1,
          ),
        ),
        Positioned(
          left: -2,
          bottom: 112,
          child: PawPrint(
            size: isCompact ? 13 : 15,
            color: Colors.white.withValues(alpha: 0.1),
            rotation: -0.16,
          ),
        ),
        Positioned(
          right: 4,
          bottom: 138,
          child: PawPrint(
            size: isCompact ? 13 : 15,
            color: Colors.white.withValues(alpha: 0.1),
            rotation: 0.2,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 6),
            Text(
              AppLocalizations.of(context)!.home_setup_title,
              textAlign: TextAlign.center,
              style: PawTextStyles.heading.copyWith(
                color: Colors.white,
                fontSize: isCompact ? 17 : 20,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _DeckInfoChip(
                      compact: isCompact,
                      icon: Icons.timer_outlined,
                      label: describeTimeLabel(
                        AppLocalizations.of(context)!,
                        settings.time,
                      ),
                    ),
                    _DeckInfoChip(
                      compact: isCompact,
                      icon: Icons.track_changes_rounded,
                      label: describeDifficultyLabel(
                        AppLocalizations.of(context)!,
                        settings.difficulty,
                      ),
                    ),
                    _DeckInfoChip(
                      compact: isCompact,
                      icon: settings.muted
                          ? Icons.volume_off_rounded
                          : Icons.volume_up_rounded,
                      label: settings.muted
                          ? AppLocalizations.of(context)!.home_muted
                          : AppLocalizations.of(context)!.home_sound_on,
                    ),
                    _DeckInfoChip(
                      compact: isCompact,
                      icon: Icons.image_outlined,
                      label: settings.backgroundPath.isEmpty
                          ? AppLocalizations.of(context)!.home_default_playmat
                          : AppLocalizations.of(
                              context,
                            )!.home_custom_playmat_ready,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            _buildMenuButtons(constraints, settings),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuButtons(BoxConstraints constraints, AppSettings settings) {
    final spacing = math.max(constraints.maxHeight * 0.012, 10.0);
    final isCompact = constraints.maxWidth < 470;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        //! Primary CTA comes first on purpose; secondary destinations should never outrank the hunt itself.
        _buildStaggeredAnimatedButton(
          delay: 0.0,
          child: CoolAnimatedButton(
            text: AppLocalizations.of(context)!.start_button,
            icon: const Icon(Icons.arrow_right_alt_sharp),
            compact: isCompact,
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
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: isCompact ? 0.92 : 1.0,
          children: [
            _buildStaggeredAnimatedButton(
              delay: 0.18,
              child: _SecondaryActionCard(
                motion: _ambientController,
                motionPhase: 0.0,
                compact: isCompact,
                title: AppLocalizations.of(context)!.settings_button,
                subtitle: AppLocalizations.of(context)!.home_customize_subtitle,
                icon: Icons.tune_rounded,
                gradient: const [Color(0xFF54A6FF), Color(0xFF00D1A7)],
                pawColor: const Color(0xFFB8F3FF),
                onTap: () => context.go(AppRoutes.settings),
              ),
            ),
            _buildStaggeredAnimatedButton(
              delay: 0.26,
              child: _SecondaryActionCard(
                motion: _ambientController,
                motionPhase: 0.9,
                compact: isCompact,
                title: AppLocalizations.of(context)!.activity_button,
                subtitle: AppLocalizations.of(context)!.home_journal_subtitle,
                icon: Icons.auto_graph_rounded,
                gradient: const [Color(0xFFFF5D8F), Color(0xFFFF974A)],
                pawColor: const Color(0xFFFFD3E2),
                onTap: () => context.go(AppRoutes.activity),
              ),
            ),
            _buildStaggeredAnimatedButton(
              delay: 0.34,
              child: _SecondaryActionCard(
                motion: _ambientController,
                motionPhase: 1.7,
                compact: isCompact,
                title: AppLocalizations.of(context)!.howtoplay_button,
                subtitle: AppLocalizations.of(context)!.home_guide_subtitle,
                icon: Icons.menu_book_rounded,
                gradient: const [Color(0xFF8A6BFF), Color(0xFF4C8DFF)],
                pawColor: const Color(0xFFD9D2FF),
                onTap: () => context.go(AppRoutes.howToPlay),
              ),
            ),
            _buildStaggeredAnimatedButton(
              delay: 0.42,
              child: _SecondaryActionCard(
                motion: _ambientController,
                motionPhase: 2.3,
                compact: isCompact,
                title: AppLocalizations.of(context)!.home_onboarding_button,
                subtitle: AppLocalizations.of(
                  context,
                )!.home_onboarding_subtitle,
                icon: Icons.celebration_rounded,
                gradient: const [Color(0xFFFFA63D), Color(0xFFFF5DB1)],
                pawColor: const Color(0xFFFFE0AE),
                onTap: () => context.go(AppRoutes.onboarding),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooterLinks(BuildContext context) {
    //? Informational routes are visually demoted to footer chips so the menu still reads as a game menu.
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 10,
      children: [
        _FooterChipButton(
          icon: Icons.info_outline_rounded,
          label: l10n.about_button,
          onTap: () => context.go(AppRoutes.about),
        ),
      ],
    );
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

class _DeckInfoChip extends StatelessWidget {
  const _DeckInfoChip({
    required this.icon,
    required this.label,
    required this.compact,
  });

  final IconData icon;
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: compact ? 138 : 180),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 11,
          vertical: compact ? 7 : 8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withValues(alpha: 0.08),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: compact ? 15 : 16),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: compact ? 11.5 : 12.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryActionCard extends StatelessWidget {
  const _SecondaryActionCard({
    required this.motion,
    required this.motionPhase,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.pawColor,
    required this.onTap,
    this.compact = false,
  });

  final Animation<double> motion;
  final double motionPhase;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final Color pawColor;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    //? Asymmetric corners and overlays help these cards feel custom instead of dashboard-like.
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: compact ? 150 : 164),
      child: AnimatedBuilder(
        animation: motion,
        builder: (context, child) {
          final wave = math.sin((motion.value * math.pi * 2) + motionPhase);
          return Transform.translate(
            offset: Offset(0, wave * 4),
            child: Transform.rotate(angle: wave * 0.01, child: child),
          );
        },
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(32),
            onTap: onTap,
            child: Ink(
              padding: EdgeInsets.all(compact ? 14 : 16),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(38),
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(46),
                ),
                gradient: LinearGradient(
                  colors: [
                    gradient.first.withValues(alpha: 0.94),
                    gradient.last.withValues(alpha: 0.98),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                boxShadow: [
                  BoxShadow(
                    color: gradient.first.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -14,
                    top: -10,
                    child: Container(
                      width: compact ? 52 : 58,
                      height: compact ? 52 : 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: pawColor.withValues(alpha: 0.2),
                        boxShadow: [
                          BoxShadow(
                            color: pawColor.withValues(alpha: 0.26),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                      child: Center(
                        child: PawPrint(
                          size: compact ? 18 : 20,
                          color: pawColor.withValues(alpha: 0.94),
                          rotation: -0.16,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -12,
                    bottom: -20,
                    child: Transform.rotate(
                      angle: -0.22,
                      child: Container(
                        width: 110,
                        height: 74,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 18,
                    bottom: 18,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: Colors.white.withValues(alpha: 0.14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.16),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PawPrint(
                            size: compact ? 13 : 15,
                            color: pawColor.withValues(alpha: 0.98),
                            rotation: -0.12,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            AppLocalizations.of(context)!.home_play_chip,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.96),
                              fontWeight: FontWeight.w800,
                              fontSize: compact ? 11.5 : 12.5,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: compact ? 40 : 44,
                        height: compact ? 40 : 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.32),
                              Colors.white.withValues(alpha: 0.14),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: compact ? 20 : 22,
                        ),
                      ),
                      SizedBox(height: compact ? 12 : 16),
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: compact ? 16 : 17,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFFF6F4FF),
                          height: 1.25,
                          fontSize: compact ? 12.0 : 13.0,
                        ),
                      ),
                      const SizedBox(height: 28),
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

class _FooterChipButton extends StatelessWidget {
  const _FooterChipButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: PawPalette.midnight.withValues(alpha: 0.42),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
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

String describeDifficultyLabel(AppLocalizations l10n, int value) {
  return switch (getDifficultyFromValue(value)) {
    Difficulty.easy => l10n.difficulty_easy,
    Difficulty.medium => l10n.difficulty_medium,
    Difficulty.hard => l10n.difficulty_hard,
    Difficulty.sandbox => l10n.difficulty_sandbox,
  };
}

String describeTimeLabel(AppLocalizations l10n, int value) {
  final current = getTimeFromValue(value);
  if (current == Time.sandbox) {
    return l10n.difficulty_sandbox;
  }
  return '${current.value}s';
}
