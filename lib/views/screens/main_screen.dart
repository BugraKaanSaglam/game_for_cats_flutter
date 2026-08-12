import 'package:flutter/material.dart';
import 'package:game_for_cats_2025/controllers/activity_controller.dart';
import 'package:game_for_cats_2025/l10n/app_localizations.dart';
import 'package:game_for_cats_2025/models/app_settings.dart';
import 'package:game_for_cats_2025/models/database/session_log.dart';
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
  late Future<List<SessionLog>> _history;

  @override
  void initState() {
    super.initState();
    AppAnalytics.screenView('main_menu');
    _history = ActivityController().loadRecentHistory(limit: 30);
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
      appBar: MainAppBar(title: l10n.game_name, hasBackButton: false),
      body: ColoredBox(
        color: HuntColors.paperWarm,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView(
                  padding: const EdgeInsets.all(HuntSpacing.lg),
                  children: [
                    HuntSectionHeading(
                      eyebrow: l10n.hunt_setup_title,
                      title: l10n.home_headline,
                      subtitle: l10n.hunt_setup_subtitle,
                    ),
                    const SizedBox(height: HuntSpacing.lg),
                    _NextHuntCard(settings: settings),
                    const SizedBox(height: HuntSpacing.md),
                    _RecentRecordCard(history: _history),
                    const SizedBox(height: HuntSpacing.lg),
                    _SecondaryDestinations(constraints: constraints),
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

class _NextHuntCard extends StatelessWidget {
  const _NextHuntCard({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final time = settings.time >= 100000
        ? l10n.difficulty_sandbox
        : '${settings.time}s';
    final difficulty = switch (settings.difficulty) {
      0 => l10n.difficulty_easy,
      1 => l10n.difficulty_medium,
      2 => l10n.difficulty_hard,
      _ => l10n.difficulty_sandbox,
    };
    return HuntSurface(
      tone: HuntSurfaceTone.field,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(HuntRadii.lg),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _FieldPatternPainter()),
            ),
            Padding(
              padding: const EdgeInsets.all(HuntSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: HuntColors.paper.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                          border: Border.all(color: HuntColors.fieldLine),
                        ),
                        child: const Icon(
                          Icons.track_changes,
                          color: HuntColors.moss,
                        ),
                      ),
                      const SizedBox(width: HuntSpacing.md),
                      Expanded(
                        child: Text(
                          l10n.hunt_setup_title,
                          style: HuntTextStyles.sectionTitle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: HuntSpacing.md),
                  Wrap(
                    spacing: HuntSpacing.sm,
                    runSpacing: HuntSpacing.sm,
                    children: [
                      HuntTag(label: time, icon: Icons.timer_outlined),
                      HuntTag(label: difficulty, icon: Icons.speed_rounded),
                      HuntTag(
                        label: settings.backgroundPath.isEmpty
                            ? l10n.home_default_playmat
                            : l10n.home_custom_playmat_ready,
                        icon: Icons.layers_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: HuntSpacing.lg),
                  HuntActionButton(
                    label: l10n.start_button,
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () {
                      AppAnalytics.track(AnalyticsEvent.gameStarted);
                      context.go(AppRoutes.game, extra: settings);
                    },
                  ),
                  const SizedBox(height: HuntSpacing.sm),
                  Center(
                    child: Text(
                      l10n.home_subheadline,
                      textAlign: TextAlign.center,
                      style: HuntTextStyles.caption,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentRecordCard extends StatelessWidget {
  const _RecentRecordCard({required this.history});

  final Future<List<SessionLog>> history;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<List<SessionLog>>(
      future: history,
      builder: (context, snapshot) {
        final logs = snapshot.data ?? const <SessionLog>[];
        final latest = logs.isEmpty ? null : logs.first;
        if (latest == null) {
          return HuntSurface(
            child: Row(
              children: [
                const Icon(
                  Icons.menu_book_outlined,
                  color: HuntColors.moss,
                  size: 30,
                ),
                const SizedBox(width: HuntSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.journal_records_title,
                        style: HuntTextStyles.sectionTitle,
                      ),
                      const SizedBox(height: HuntSpacing.xs),
                      Text(
                        l10n.state_empty_subtitle,
                        style: HuntTextStyles.supporting,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return HuntSurface(
          tone: HuntSurfaceTone.paper,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.journal_records_title,
                style: HuntTextStyles.sectionTitle,
              ),
              const SizedBox(height: HuntSpacing.xs),
              Text(
                l10n.journal_records_subtitle,
                style: HuntTextStyles.supporting,
              ),
              const SizedBox(height: HuntSpacing.md),
              Row(
                children: [
                  HuntMetric(
                    label: l10n.hunt_record_accuracy,
                    value: '${latest.accuracy}%',
                    accent: HuntColors.moss,
                  ),
                  const SizedBox(width: HuntSpacing.sm),
                  HuntMetric(
                    label: l10n.best_streak_label,
                    value: '${latest.bestStreak}',
                    accent: HuntColors.coral,
                  ),
                  const SizedBox(width: HuntSpacing.sm),
                  HuntMetric(
                    label: l10n.hunt_record_hits,
                    value: '${latest.successfulTaps}',
                    accent: HuntColors.sky,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SecondaryDestinations extends StatelessWidget {
  const _SecondaryDestinations({required this.constraints});

  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final destinations = [
      (
        l10n.activity_button,
        l10n.home_journal_subtitle,
        Icons.menu_book_outlined,
        AppRoutes.activity,
      ),
      (
        l10n.settings_button,
        l10n.home_customize_subtitle,
        Icons.tune_rounded,
        AppRoutes.settings,
      ),
      (
        l10n.howtoplay_button,
        l10n.home_guide_subtitle,
        Icons.route_outlined,
        AppRoutes.howToPlay,
      ),
      (
        l10n.about_button,
        l10n.about_local_note,
        Icons.info_outline_rounded,
        AppRoutes.about,
      ),
    ];
    final items = destinations
        .map(
          (item) => _DestinationTile(
            title: item.$1,
            subtitle: item.$2,
            icon: item.$3,
            onTap: () => context.go(item.$4),
          ),
        )
        .toList();
    return constraints.maxWidth > 540
        ? Row(
            children: [
              Expanded(child: items[0]),
              const SizedBox(width: HuntSpacing.sm),
              Expanded(child: items[1]),
              const SizedBox(width: HuntSpacing.sm),
              Expanded(child: items[2]),
              const SizedBox(width: HuntSpacing.sm),
              Expanded(child: items[3]),
            ],
          )
        : Column(
            children: [
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: HuntSpacing.sm),
                  child: item,
                ),
            ],
          );
  }
}

class _DestinationTile extends StatelessWidget {
  const _DestinationTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: title,
      child: Material(
        color: HuntColors.paper,
        borderRadius: BorderRadius.circular(HuntRadii.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(HuntRadii.md),
          child: Padding(
            padding: const EdgeInsets.all(HuntSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: HuntColors.moss, size: 24),
                const SizedBox(height: HuntSpacing.sm),
                Text(
                  title,
                  style: HuntTextStyles.sectionTitle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: HuntSpacing.xs),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: HuntTextStyles.caption,
                ),
              ],
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

class _FieldPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = HuntColors.fieldLine.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (var i = -2; i < 8; i++) {
      final path = Path()
        ..moveTo(i * 110, size.height)
        ..quadraticBezierTo(
          size.width * 0.45,
          size.height * 0.45,
          i * 110 + 130,
          0,
        );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FieldPatternPainter oldDelegate) => false;
}
