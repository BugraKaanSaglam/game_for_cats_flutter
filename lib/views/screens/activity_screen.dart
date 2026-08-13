import 'package:flutter/material.dart';
import 'package:game_for_cats_2025/l10n/app_localizations.dart';
import 'package:game_for_cats_2025/controllers/activity_controller.dart';
import 'package:game_for_cats_2025/models/database/session_log.dart';
import 'package:game_for_cats_2025/models/enums/enum_functions.dart';
import 'package:game_for_cats_2025/models/enums/game_enums.dart';
import 'package:game_for_cats_2025/services/app_analytics.dart';
import 'package:game_for_cats_2025/views/components/hunt_ui.dart';
import 'package:game_for_cats_2025/views/theme/paw_theme.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:game_for_cats_2025/routing/app_routes.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  late Future<List<SessionLog>> _history;

  @override
  void initState() {
    super.initState();
    AppAnalytics.screenView('activity');
    _history = ActivityController().loadRecentHistory(limit: 60);
  }

  Future<void> _refresh() async {
    setState(
      () => _history = ActivityController().loadRecentHistory(limit: 60),
    );
    await _history;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return HuntCorePage(
      title: l10n.activity_title,
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<SessionLog>>(
          future: _history,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _StateMessage(
                title: l10n.activity_error,
                action: l10n.state_retry,
                onPressed: _refresh,
              );
            }
            final logs = snapshot.data ?? const <SessionLog>[];
            if (logs.isEmpty) {
              return _StateMessage(
                title: l10n.state_empty_title,
                action: l10n.start_button,
                onPressed: () => context.go(AppRoutes.main),
              );
            }
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(HuntSpacing.lg),
              children: [
                HuntCoreHeader(
                  eyebrow: l10n.activity_title,
                  title: l10n.journal_records_title,
                  subtitle: l10n.journal_records_subtitle,
                  tone: HuntSurfaceTone.accent,
                ),
                const SizedBox(height: HuntSpacing.lg),
                _PersonalBestCard(logs: logs),
                const SizedBox(height: HuntSpacing.md),
                _TrendCard(logs: logs),
                const SizedBox(height: HuntSpacing.lg),
                HuntSurface(
                  child: Text(
                    l10n.journal_records_title,
                    style: HuntTextStyles.sectionTitle,
                  ),
                ),
                const SizedBox(height: HuntSpacing.sm),
                for (final log in logs.take(10)) _RecordTile(log: log),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PersonalBestCard extends StatelessWidget {
  const _PersonalBestCard({required this.logs});

  final List<SessionLog> logs;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bestAccuracy = logs
        .map((log) => log.accuracy)
        .fold<int>(0, (best, value) => value > best ? value : best);
    final bestStreak = logs
        .map((log) => log.bestStreak)
        .fold<int>(0, (best, value) => value > best ? value : best);
    final totalHits = logs.fold<int>(0, (sum, log) => sum + log.successfulTaps);
    return HuntSurface(
      tone: HuntSurfaceTone.field,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.journal_personal_best, style: HuntTextStyles.sectionTitle),
          const SizedBox(height: HuntSpacing.md),
          Row(
            children: [
              HuntMetric(
                label: l10n.journal_best_accuracy,
                value: '$bestAccuracy%',
                accent: HuntColors.moss,
              ),
              const SizedBox(width: HuntSpacing.sm),
              HuntMetric(
                label: l10n.journal_best_streak,
                value: '$bestStreak',
                accent: HuntColors.coral,
              ),
              const SizedBox(width: HuntSpacing.sm),
              HuntMetric(
                label: l10n.journal_hunts_completed,
                value: '${logs.length}',
                accent: HuntColors.sky,
              ),
            ],
          ),
          const SizedBox(height: HuntSpacing.sm),
          Text(
            '${l10n.hunt_record_hits}: $totalHits',
            style: HuntTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.logs});

  final List<SessionLog> logs;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final points = logs
        .take(7)
        .toList()
        .reversed
        .map((log) => log.accuracy.toDouble())
        .toList();
    return HuntSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.activity_subtitle, style: HuntTextStyles.supporting),
          const SizedBox(height: HuntSpacing.md),
          SizedBox(
            height: 110,
            width: double.infinity,
            child: CustomPaint(painter: _TrendPainter(points)),
          ),
        ],
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.log});

  final SessionLog log;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final date = DateFormat.MMMd(locale).format(log.timestamp);
    final difficulty = switch (getDifficultyFromValue(log.difficulty)) {
      Difficulty.easy => l10n.difficulty_easy,
      Difficulty.medium => l10n.difficulty_medium,
      Difficulty.hard => l10n.difficulty_hard,
      Difficulty.sandbox => l10n.difficulty_sandbox,
    };
    return HuntSurface(
      margin: const EdgeInsets.only(bottom: HuntSpacing.sm),
      padding: const EdgeInsets.all(HuntSpacing.md),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: HuntColors.field,
              borderRadius: BorderRadius.circular(HuntRadii.sm),
            ),
            child: Center(
              child: Text(
                '${log.accuracy}%',
                style: HuntTextStyles.caption.copyWith(color: HuntColors.moss),
              ),
            ),
          ),
          const SizedBox(width: HuntSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: HuntTextStyles.sectionTitle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: HuntSpacing.xs),
                Text(
                  '$difficulty · ${log.successfulTaps} ${l10n.hunt_record_hits.toLowerCase()} · ${l10n.best_streak_label} ${log.bestStreak}',
                  style: HuntTextStyles.caption,
                ),
              ],
            ),
          ),
          Icon(
            log.completionReason.name == 'manual'
                ? Icons.stop_circle_outlined
                : Icons.flag_outlined,
            color: HuntColors.inkSoft,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.title,
    required this.action,
    required this.onPressed,
  });

  final String title;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(HuntSpacing.lg),
      children: [
        const SizedBox(height: 100),
        HuntSurface(
          tone: HuntSurfaceTone.field,
          child: Column(
            children: [
              const Icon(
                Icons.menu_book_outlined,
                color: HuntColors.moss,
                size: 38,
              ),
              const SizedBox(height: HuntSpacing.md),
              Text(
                title,
                textAlign: TextAlign.center,
                style: HuntTextStyles.sectionTitle,
              ),
              const SizedBox(height: HuntSpacing.md),
              HuntActionButton(label: action, onPressed: onPressed),
            ],
          ),
        ),
      ],
    );
  }
}

class _TrendPainter extends CustomPainter {
  const _TrendPainter(this.points);

  final List<double> points;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()..color = HuntColors.line;
    for (var i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    if (points.length < 2) return;
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = size.width * i / (points.length - 1);
      final y = size.height - (points[i] / 100 * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 4, Paint()..color = HuntColors.coral);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = HuntColors.moss
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) =>
      oldDelegate.points != points;
}
