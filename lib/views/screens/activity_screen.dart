import 'dart:math';

import 'package:flutter/material.dart';
import 'package:game_for_cats_2025/controllers/activity_controller.dart';
import 'package:game_for_cats_2025/l10n/app_localizations.dart';
import 'package:game_for_cats_2025/models/database/session_log.dart';
import 'package:game_for_cats_2025/views/components/main_app_bar.dart';
import 'package:game_for_cats_2025/views/theme/paw_theme.dart';
import 'package:game_for_cats_2025/views/widgets/animated_gradient_background.dart';
import 'package:game_for_cats_2025/views/widgets/glassy_panel.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  late final ActivityController _controller;
  late Future<List<SessionLog>> _historyFuture;

  static const int _daysWindow = 7;

  @override
  void initState() {
    super.initState();
    _controller = ActivityController();
    _historyFuture = _load();
  }

  Future<List<SessionLog>> _load() => _controller.loadRecentHistory(limit: 60);

  Future<void> _refresh() async {
    setState(() {
      _historyFuture = _load();
    });
    await _historyFuture;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: mainAppBar(l10n.activity_title, context),
      body: AnimatedGradientBackground(
        overlayOpacity: 0.12,
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: FutureBuilder<List<SessionLog>>(
              future: _historyFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }

                if (snapshot.hasError) return _buildMessage(l10n.activity_error);

                final history = snapshot.data ?? [];
                if (history.isEmpty) return _buildMessage(l10n.activity_empty);

                final aggregates = _aggregate(history);
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    GlassyPanel(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.activity_title, style: PawTextStyles.cardTitle.copyWith(fontSize: 20)),
                          const SizedBox(height: 6),
                          Text(l10n.activity_subtitle, style: PawTextStyles.cardSubtitle),
                          const SizedBox(height: 14),
                          _buildLegend(l10n),
                          const SizedBox(height: 10),
                          _ActivityChart(buckets: aggregates),
                          const SizedBox(height: 12),
                          _buildStatsRow(l10n, aggregates),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(AppLocalizations l10n) {
    return Row(
      children: const [_LegendDot(color: Color(0xFF4FACFE), labelKey: 'total'), SizedBox(width: 12), _LegendDot(color: Color(0xFFFF6B6B), labelKey: 'miss')].map((w) => w).toList(),
    );
  }

  Widget _buildStatsRow(AppLocalizations l10n, List<_DailyAggregate> aggregates) {
    final totalTaps = aggregates.fold<int>(0, (sum, e) => sum + e.total);
    final wrongTaps = aggregates.fold<int>(0, (sum, e) => sum + e.wrong);
    final accuracy = totalTaps == 0 ? 0 : (((totalTaps - wrongTaps) / totalTaps) * 100).clamp(0, 100);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _StatPill(label: l10n.activity_total_label, value: '$totalTaps'),
        _StatPill(label: l10n.activity_miss_label, value: '$wrongTaps'),
        _StatPill(label: l10n.activity_accuracy_label, value: '${accuracy.toStringAsFixed(0)}%'),
      ],
    );
  }

  List<_DailyAggregate> _aggregate(List<SessionLog> logs) {
    final now = DateTime.now();
    final aggregates = <String, _DailyAggregate>{};

    for (final log in logs) {
      final key = log.dateKey;
      aggregates.putIfAbsent(key, () => _DailyAggregate(label: _labelFromDateKey(key)));
      aggregates[key]!.total += log.totalTaps;
      aggregates[key]!.wrong += log.wrongTaps;
    }

    final List<_DailyAggregate> ordered = [];
    for (int i = _daysWindow - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = _dateKey(date);
      ordered.add(aggregates[key] ?? _DailyAggregate(label: _labelFromDate(date)));
    }
    return ordered;
  }

  Widget _buildMessage(String text) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GlassyPanel(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                const Icon(Icons.pets, color: Colors.white, size: 36),
                const SizedBox(height: 10),
                Text(text, textAlign: TextAlign.center, style: PawTextStyles.cardSubtitle),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _dateKey(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
  }

  String _labelFromDate(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '$dd.$mm';
  }

  String _labelFromDateKey(String key) {
    final parts = key.split('-');
    if (parts.length == 3) {
      return '${parts[2]}.${parts[1]}';
    }
    return key;
  }
}

class _ActivityChart extends StatelessWidget {
  const _ActivityChart({required this.buckets});

  final List<_DailyAggregate> buckets;

  @override
  Widget build(BuildContext context) {
    final maxTotal = buckets.fold<int>(0, (prev, e) => e.total > prev ? e.total : prev);
    final safeMax = max(maxTotal, 1);
    final barGradient = const [Color(0xFF4FACFE), Color(0xFF00F2FE)];

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (int i = 0; i < buckets.length; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: _AnimatedBar(
                      total: buckets[i].total,
                      wrong: buckets[i].wrong,
                      maxTotal: safeMax,
                      gradient: barGradient,
                      delay: Duration(milliseconds: 120 * i),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: buckets
              .map(
                (bucket) => Expanded(
                  child: Text(bucket.label, textAlign: TextAlign.center, style: PawTextStyles.cardSubtitle.copyWith(fontSize: 12)),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _AnimatedBar extends StatefulWidget {
  const _AnimatedBar({required this.total, required this.wrong, required this.maxTotal, required this.gradient, required this.delay});

  final int total;
  final int wrong;
  final int maxTotal;
  final List<Color> gradient;
  final Duration delay;

  @override
  State<_AnimatedBar> createState() => _AnimatedBarState();
}

class _AnimatedBarState extends State<_AnimatedBar> with SingleTickerProviderStateMixin {
  static const double _barHeight = 150;
  late final AnimationController _controller;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 720));
    _configureTween();
    _startWithDelay();
  }

  @override
  void didUpdateWidget(covariant _AnimatedBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.total != widget.total || oldWidget.maxTotal != widget.maxTotal || oldWidget.wrong != widget.wrong) {
      _configureTween();
      _startWithDelay();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _configureTween() {
    final targetHeight = _targetHeight();
    _heightAnimation = Tween<double>(begin: 0, end: targetHeight).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
  }

  void _startWithDelay() {
    _controller.stop();
    _controller.reset();
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  double _targetHeight() {
    final safeMax = max(widget.maxTotal, 1);
    return (widget.total / safeMax) * _barHeight;
  }

  @override
  Widget build(BuildContext context) {
    final double wrongHeight = widget.total == 0 ? 0 : (widget.wrong / widget.total) * _targetHeight();

    return AnimatedBuilder(
      animation: _heightAnimation,
      builder: (context, _) {
        final double value = _heightAnimation.value;
        final double wrongValue = widget.total == 0 ? 0 : min(wrongHeight, value).toDouble();

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: _barHeight,
              alignment: Alignment.bottomCenter,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    height: value,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(colors: widget.gradient, begin: Alignment.topCenter, end: Alignment.bottomCenter),
                      boxShadow: [
                        BoxShadow(
                          color: widget.gradient.last.withValues(alpha: 0.3 * 255),
                          blurRadius: 14,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                  ),
                  if (wrongValue > 0)
                    Container(
                      height: wrongValue.toDouble(),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                        color: Colors.redAccent.withValues(alpha: 0.75 * 255),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text('${widget.total}', style: PawTextStyles.cardSubtitle.copyWith(fontWeight: FontWeight.bold)),
          ],
        );
      },
    );
  }
}

class _DailyAggregate {
  _DailyAggregate({required this.label}) : total = 0, wrong = 0;

  final String label;
  int total;
  int wrong;
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.labelKey});

  final Color color;
  final String labelKey;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = labelKey == 'miss' ? l10n.activity_legend_miss : l10n.activity_legend_total;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: PawTextStyles.cardSubtitle.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.1 * 255),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2 * 255)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: PawTextStyles.cardSubtitle.copyWith(fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: PawTextStyles.cardTitle.copyWith(fontSize: 18, color: Colors.white)),
        ],
      ),
    );
  }
}
