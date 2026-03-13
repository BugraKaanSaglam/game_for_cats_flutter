// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:game_for_cats_2025/models/database/db_error.dart';
import 'package:game_for_cats_2025/models/app_settings.dart';
import 'package:game_for_cats_2025/l10n/app_localizations.dart';
import 'package:game_for_cats_2025/routing/app_routes.dart';
import 'package:game_for_cats_2025/services/app_analytics.dart';
import 'package:game_for_cats_2025/services/connectivity_service.dart';
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
                        const SizedBox(height: 24),
                        Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 560),
                            child: _buildMenuButtons(constraints, settings),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _buildStaggeredAnimatedButton(
                          delay: 0.6,
                          child: CoolAnimatedButton(
                            text: AppLocalizations.of(context)!.exit_button,
                            icon: const Icon(Icons.exit_to_app_outlined),
                            onPressed: () => exit(0),
                            startColor: const Color(0xFFEF476F),
                            endColor: const Color(0xFFFF6B6B),
                          ),
                        ),
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
    final connectivity = context.watch<ConnectivityController>().status;
    final isOnline = connectivity == ConnectionStateStatus.online;
    final statusLabel = switch (connectivity) {
      ConnectionStateStatus.online => l10n.connectivity_status_online,
      ConnectionStateStatus.offline => l10n.connectivity_status_offline,
      ConnectionStateStatus.unknown => l10n.connectivity_status_unknown,
    };

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: const LinearGradient(
          colors: [Color(0x66FFFFFF), Color(0x1AFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: PawPalette.midnight.withValues(alpha: 0.26),
            blurRadius: 28,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF8C42), Color(0xFFFF5D8F)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: PawPalette.bubbleGum.withValues(alpha: 0.35),
                      blurRadius: 22,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.pets_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.game_name, style: PawTextStyles.heading),
                    const SizedBox(height: 8),
                    Text(l10n.main_tagline, style: PawTextStyles.subheading),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroPill(
                icon: isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                label: statusLabel,
                color: isOnline ? PawPalette.teal : PawPalette.tangerine,
              ),
              _HeroPill(
                icon: Icons.track_changes_rounded,
                label: l10n.activity_button,
                color: PawPalette.lemon,
              ),
              _HeroPill(
                icon: Icons.tune_rounded,
                label: l10n.settings_button,
                color: PawPalette.grape,
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
        //! Settings Button
        _buildStaggeredAnimatedButton(
          delay: 0.15,
          child: CoolAnimatedButton(
            text: AppLocalizations.of(context)!.settings_button,
            icon: const Icon(Icons.settings),
            onPressed: () => context.go(AppRoutes.settings),
          ),
        ),
        SizedBox(height: spacing),
        //! How to Play Button
        _buildStaggeredAnimatedButton(
          delay: 0.30,
          child: CoolAnimatedButton(
            text: AppLocalizations.of(context)!.howtoplay_button,
            icon: const Icon(Icons.menu_book),
            onPressed: () => context.go(AppRoutes.howToPlay),
          ),
        ),
        SizedBox(height: spacing),
        //! Credits Button
        _buildStaggeredAnimatedButton(
          delay: 0.45,
          child: CoolAnimatedButton(
            text: AppLocalizations.of(context)!.credits_button,
            icon: const Icon(Icons.pest_control_rodent_sharp),
            onPressed: () => context.go(AppRoutes.credits),
          ),
        ),
        SizedBox(height: spacing),
        //! About Button
        _buildStaggeredAnimatedButton(
          delay: 0.50,
          child: CoolAnimatedButton(
            text: AppLocalizations.of(context)!.about_button,
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => context.go(AppRoutes.about),
            startColor: const Color(0xFF6D597A),
            endColor: const Color(0xFF355070),
          ),
        ),
        SizedBox(height: spacing),
        //! Activity Button
        _buildStaggeredAnimatedButton(
          delay: 0.55,
          child: CoolAnimatedButton(
            text: AppLocalizations.of(context)!.activity_button,
            icon: const Icon(Icons.show_chart_rounded),
            onPressed: () => context.go(AppRoutes.activity),
            startColor: const Color(0xFF4FACFE),
            endColor: const Color(0xFF00F2FE),
          ),
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

class _HeroPill extends StatelessWidget {
  const _HeroPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.18),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
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
