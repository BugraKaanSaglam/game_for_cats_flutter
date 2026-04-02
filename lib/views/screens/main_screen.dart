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
                        _buildTopStrip(context, constraints.maxWidth),
                        const SizedBox(height: 14),
                        _buildSetupPanel(
                          context,
                          settings,
                          constraints.maxWidth,
                        ),
                        const SizedBox(height: 18),
                        Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 560),
                            child: _buildMenuButtons(constraints, settings),
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

  Widget _buildTopStrip(BuildContext context, double availableWidth) {
    final isCompact = availableWidth < 430;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 16 : 18,
        vertical: isCompact ? 14 : 16,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.05),
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
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _ambientController,
                builder: (context, _) {
                  final wave = math.sin(_ambientController.value * math.pi * 2);
                  return Stack(
                    children: [
                      Positioned(
                        right: 16 + (wave * 8),
                        top: 14,
                        child: _MiniPawStamp(
                          size: 16,
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      Positioned(
                        right: 44 - (wave * 6),
                        top: 34,
                        child: _MiniPawStamp(
                          size: 12,
                          color: Colors.white.withValues(alpha: 0.09),
                        ),
                      ),
                      Positioned(
                        left: 14,
                        bottom: 12 + (wave * 6),
                        child: _MiniPawStamp(
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.07),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          isCompact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: _PlayfieldPreviewCard(compact: true),
                    ),
                    const SizedBox(height: 10),
                    _TopStripCopy(compact: true),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(child: _TopStripCopy(compact: false)),
                    const SizedBox(width: 16),
                    _PlayfieldPreviewCard(compact: true),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildSetupPanel(
    BuildContext context,
    AppSettings settings,
    double availableWidth,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final isCompact = availableWidth < 430;
    return Container(
      padding: EdgeInsets.all(isCompact ? 16 : 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isCompact) ...[
            Text(
              l10n.home_setup_title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const _LiveBadge(),
          ] else
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.home_setup_title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const _LiveBadge(),
              ],
            ),
          const SizedBox(height: 6),
          Text(
            l10n.home_setup_subtitle,
            maxLines: isCompact ? 3 : 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFFD7D5F5),
              height: 1.35,
              fontSize: isCompact ? 14 : 15,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _SetupChip(
                compact: isCompact,
                icon: Icons.timer_outlined,
                label: _timeLabel(l10n, settings.time),
              ),
              _SetupChip(
                compact: isCompact,
                icon: Icons.track_changes_rounded,
                label: _difficultyLabel(l10n, settings.difficulty),
              ),
              _SetupChip(
                compact: isCompact,
                icon: Icons.image_outlined,
                label: settings.backgroundPath.isEmpty
                    ? l10n.home_default_playmat
                    : l10n.home_custom_playmat_ready,
              ),
              _SetupChip(
                compact: isCompact,
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
    final spacing = math.max(constraints.maxHeight * 0.014, 12.0);
    final isCompact = constraints.maxWidth < 430;
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
        Row(
          children: [
            Expanded(
              child: _buildStaggeredAnimatedButton(
                delay: 0.18,
                child: _SecondaryActionCard(
                  compact: isCompact,
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
                  compact: isCompact,
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
      spacing: 12,
      runSpacing: 10,
      children: [
        _FooterChipButton(
          icon: Icons.menu_book_rounded,
          label: l10n.howtoplay_button,
          onTap: () => context.go(AppRoutes.howToPlay),
        ),
        _FooterChipButton(
          icon: Icons.info_outline_rounded,
          label: l10n.about_button,
          onTap: () => context.go(AppRoutes.about),
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
  const _SetupChip({
    required this.icon,
    required this.label,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 11 : 12,
        vertical: compact ? 9 : 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: compact ? 16 : 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: compact ? 13 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopStripCopy extends StatelessWidget {
  const _TopStripCopy({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: Colors.white.withValues(alpha: 0.1),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Text(
            l10n.home_kicker,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 12 : 13,
            ),
          ),
        ),
        SizedBox(height: compact ? 10 : 12),
        Text(
          l10n.home_subheadline,
          maxLines: compact ? 3 : 2,
          overflow: TextOverflow.ellipsis,
          style: PawTextStyles.subheading.copyWith(
            fontSize: compact ? 15 : 16,
            height: 1.3,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _TinyFeaturePill(
              icon: Icons.pets_rounded,
              label: l10n.home_feature_paw_first,
            ),
            _TinyFeaturePill(
              icon: Icons.bolt_rounded,
              label: l10n.home_feature_quick_rounds,
            ),
          ],
        ),
      ],
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
    this.compact = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Ink(
          padding: EdgeInsets.all(compact ? 16 : 18),
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
          child: Stack(
            children: [
              Positioned(
                right: 0,
                top: 0,
                child: _MiniPawStamp(
                  size: compact ? 18 : 20,
                  color: Colors.white.withValues(alpha: 0.18),
                ),
              ),
              Positioned(
                left: -10,
                bottom: -16,
                child: Transform.rotate(
                  angle: -0.22,
                  child: Container(
                    width: 92,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: compact ? 40 : 42,
                    height: compact ? 40 : 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.16),
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
                    maxLines: compact ? 3 : 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFFF6F4FF),
                      height: 1.3,
                      fontSize: compact ? 12.5 : 14,
                    ),
                  ),
                ],
              ),
            ],
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

class _PlayfieldPreviewCard extends StatelessWidget {
  const _PlayfieldPreviewCard({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: compact ? 84 : 112,
          height: compact ? 108 : 148,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            image: const DecorationImage(
              image: AssetImage('assets/images/mainscreenbg.png'),
              fit: BoxFit.cover,
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
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
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
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
        const Positioned(top: -8, left: 6, child: _MiniPawStamp(size: 12)),
        const Positioned(top: -10, left: 26, child: _MiniPawStamp(size: 10)),
        const Positioned(top: -8, left: 44, child: _MiniPawStamp(size: 12)),
      ],
    );
  }
}

class _TinyFeaturePill extends StatelessWidget {
  const _TinyFeaturePill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.08),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _MiniPawStamp(size: 12, color: Colors.white70),
          const SizedBox(width: 6),
          Text(
            AppLocalizations.of(context)!.home_live_badge,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniPawStamp extends StatelessWidget {
  const _MiniPawStamp({required this.size, this.color = Colors.white});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final toe = size * 0.2;
    final padWidth = size * 0.5;
    final padHeight = size * 0.34;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned(
            left: size * 0.14,
            top: size * 0.06,
            child: _PawDot(size: toe, color: color),
          ),
          Positioned(
            left: size * 0.38,
            top: 0,
            child: _PawDot(size: toe, color: color),
          ),
          Positioned(
            right: size * 0.14,
            top: size * 0.06,
            child: _PawDot(size: toe, color: color),
          ),
          Positioned(
            left: size * 0.3,
            top: size * 0.2,
            child: _PawDot(size: toe * 0.92, color: color),
          ),
          Positioned(
            left: (size - padWidth) / 2,
            bottom: size * 0.1,
            child: Container(
              width: padWidth,
              height: padHeight,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(size * 0.22),
                  bottom: Radius.circular(size * 0.18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PawDot extends StatelessWidget {
  const _PawDot({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
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
