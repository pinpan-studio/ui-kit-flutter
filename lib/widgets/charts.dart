import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/format.dart';
import '../theme/kit_colors.dart';
import '../theme/tokens.dart';

/// Types de graphiques (`HzChartKind`) : ligne, aire, barres, barres horizontales,
/// empilé, anneau, secteurs, radar.
enum ChartKind { line, area, bar, hbar, stacked, doughnut, pie, radar }

class ChartSeries {
  const ChartSeries(this.label, this.data, {this.color});
  final String label;
  final List<double> data;
  final Color? color;
}

/// Palette catégorielle du kit : primaire, info, tertiaire, violet, success, warning, cyan.
List<Color> chartPalette(KitColors c) => [c.primary, c.info, c.tertiary, c.purple, c.success, c.warning, c.cyan, c.error];

/// Graphique du kit (remplace Chart.js / ng2-charts) : couleurs du thème,
/// grille discrète, info-bulles au toucher, légende en puces.
class KitChart extends StatelessWidget {
  const KitChart({
    super.key,
    required this.kind,
    required this.labels,
    required this.series,
    this.height = 220,
    this.unit = '',
    this.showLegend = true,
    this.compactValues = false,
  });

  final ChartKind kind;
  final List<String> labels;
  final List<ChartSeries> series;
  final double height;
  final String unit;
  final bool showLegend, compactValues;

  String _fmt(double v) => compactValues ? Fmt.compact(v) : (v == v.roundToDouble() ? Fmt.number(v) : Fmt.decimal1(v));

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    final pal = chartPalette(c);
    Color col(int i) => series[i].color ?? pal[i % pal.length];
    final legend = switch (kind) {
      ChartKind.doughnut || ChartKind.pie => [for (var i = 0; i < labels.length; i++) (labels[i], pal[i % pal.length], series.first.data[i])],
      _ => [for (var i = 0; i < series.length; i++) (series[i].label, col(i), null)],
    };
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
      SizedBox(height: height, child: _chart(context, c, col, pal)),
      if (showLegend && (legend.length > 1 || kind == ChartKind.doughnut || kind == ChartKind.pie)) ...[
        const SizedBox(height: 10),
        Wrap(spacing: 14, runSpacing: 6, alignment: WrapAlignment.center, children: [
          for (final (l, color, v) in legend)
            Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(Radii.xs))),
              const SizedBox(width: 6),
              Text(v == null ? l : '$l · ${_fmt(v)}$unit', style: TextStyle(fontSize: 12, color: c.textSecondary)),
            ]),
        ]),
      ],
    ]);
  }

  Widget _chart(BuildContext context, KitColors c, Color Function(int) col, List<Color> pal) {
    final grid = FlGridData(
      show: true,
      drawVerticalLine: false,
      getDrawingHorizontalLine: (_) => FlLine(color: c.border, strokeWidth: 1),
    );
    final tooltipBg = Theme.of(context).colorScheme.inverseSurface;
    final tipStyle = TextStyle(color: Theme.of(context).colorScheme.onInverseSurface, fontSize: 11.5, fontWeight: FontWeight.w600);
    final axisStyle = TextStyle(fontSize: 11, color: c.textMuted);
    final step = labels.length > 8 ? (labels.length / 6).ceil() : 1;

    AxisTitles bottom() => AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 24,
            interval: 1,
            getTitlesWidget: (v, meta) {
              final i = v.round();
              if (i < 0 || i >= labels.length || i % step != 0 || v != i.toDouble()) return const SizedBox.shrink();
              return SideTitleWidget(meta: meta, child: Text(labels[i], style: axisStyle));
            },
          ),
        );
    AxisTitles left() => AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 38,
            getTitlesWidget: (v, meta) => v == meta.max ? const SizedBox.shrink() : SideTitleWidget(meta: meta, child: Text(Fmt.compact(v), style: axisStyle)),
          ),
        );
    const none = AxisTitles(sideTitles: SideTitles(showTitles: false));

    switch (kind) {
      case ChartKind.line:
      case ChartKind.area:
        return LineChart(LineChartData(
          gridData: grid,
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(bottomTitles: bottom(), leftTitles: left(), topTitles: none, rightTitles: none),
          minY: 0,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => tooltipBg,
              getTooltipItems: (spots) => [
                for (final s in spots) LineTooltipItem('${series[s.barIndex].label} : ${_fmt(s.y)}$unit', tipStyle),
              ],
            ),
          ),
          lineBarsData: [
            for (var i = 0; i < series.length; i++)
              LineChartBarData(
                spots: [
                  for (var j = 0; j < series[i].data.length; j++)
                    if (series[i].data[j] > 0 || kind == ChartKind.line) FlSpot(j.toDouble(), series[i].data[j]),
                ],
                isCurved: true,
                curveSmoothness: 0.3,
                preventCurveOverShooting: true,
                color: col(i),
                barWidth: i == 0 ? 3 : 2,
                dashArray: i > 0 && kind == ChartKind.area ? [6, 4] : null,
                dotData: FlDotData(show: series[i].data.length <= 12 && i == 0, getDotPainter: (_, _, _, _) => FlDotCirclePainter(radius: 3, color: col(i), strokeWidth: 2, strokeColor: c.card)),
                belowBarData: BarAreaData(
                  show: kind == ChartKind.area && i == 0,
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [col(i).withValues(alpha: 0.28), col(i).withValues(alpha: 0.0)]),
                ),
              ),
          ],
        ));
      case ChartKind.bar:
      case ChartKind.stacked:
        final stacked = kind == ChartKind.stacked;
        final n = labels.length;
        final w = math.max(6.0, math.min(18.0, 220 / (n * (stacked ? 1 : series.length))));
        return BarChart(BarChartData(
          gridData: grid,
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(bottomTitles: bottom(), leftTitles: left(), topTitles: none, rightTitles: none),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => tooltipBg,
              getTooltipItem: (g, gi, rod, ri) => BarTooltipItem(
                stacked ? '${labels[g.x]} : ${_fmt(rod.toY)}$unit' : '${series[ri].label} : ${_fmt(rod.toY)}$unit',
                tipStyle,
              ),
            ),
          ),
          barGroups: [
            for (var j = 0; j < n; j++)
              BarChartGroupData(
                x: j,
                barsSpace: 3,
                barRods: stacked
                    ? [
                        () {
                          var acc = 0.0;
                          final items = <BarChartRodStackItem>[];
                          for (var i = 0; i < series.length; i++) {
                            final v = series[i].data[j];
                            items.add(BarChartRodStackItem(acc, acc + v, col(i)));
                            acc += v;
                          }
                          return BarChartRodData(toY: acc, width: w * 1.4, rodStackItems: items, borderRadius: BorderRadius.circular(Radii.xs), color: Colors.transparent);
                        }(),
                      ]
                    : [
                        for (var i = 0; i < series.length; i++)
                          BarChartRodData(toY: series[i].data[j], color: col(i), width: w, borderRadius: const BorderRadius.vertical(top: Radius.circular(5))),
                      ],
              ),
          ],
        ));
      case ChartKind.hbar:
        final data = series.first.data;
        final max = data.reduce(math.max);
        return ListView(physics: const NeverScrollableScrollPhysics(), padding: EdgeInsets.zero, children: [
          for (var i = 0; i < labels.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(children: [
                SizedBox(width: 92, child: Text(labels[i], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: c.textSecondary))),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, cons) => Stack(children: [
                      Container(height: 22, decoration: BoxDecoration(color: c.fieldBg, borderRadius: Radii.rs)),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: data[i] / max),
                        duration: Duration(milliseconds: 500 + i * 80),
                        curve: Curves.easeOutCubic,
                        builder: (_, v, _) => Container(
                          height: 22,
                          width: cons.maxWidth * v,
                          decoration: BoxDecoration(color: (series.first.color ?? pal[0]).withValues(alpha: 0.85 - i * 0.08), borderRadius: Radii.rs),
                        ),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(width: 56, child: Text('${_fmt(data[i])}$unit', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.textPrimary))),
              ]),
            ),
        ]);
      case ChartKind.doughnut:
      case ChartKind.pie:
        final data = series.first.data;
        final total = data.fold<double>(0, (a, b) => a + b);
        return Stack(alignment: Alignment.center, children: [
          PieChart(PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: kind == ChartKind.doughnut ? height * 0.27 : 0,
            sections: [
              for (var i = 0; i < data.length; i++)
                PieChartSectionData(
                  value: data[i],
                  color: pal[i % pal.length],
                  radius: kind == ChartKind.doughnut ? height * 0.16 : height * 0.42,
                  title: kind == ChartKind.pie ? '${(data[i] / total * 100).round()} %' : '',
                  titleStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                ),
            ],
          )),
          if (kind == ChartKind.doughnut)
            Column(mainAxisSize: MainAxisSize.min, children: [
              Text(_fmt(total) + unit, style: TextStyle(fontFamily: Fonts.heading, fontSize: 20, fontWeight: FontWeight.w700, color: c.textPrimary)),
              Text('Total', style: TextStyle(fontSize: 11, color: c.textMuted)),
            ]),
        ]);
      case ChartKind.radar:
        return RadarChart(RadarChartData(
          radarShape: RadarShape.polygon,
          radarBorderData: BorderSide(color: c.border),
          gridBorderData: BorderSide(color: c.border),
          tickBorderData: BorderSide(color: c.border),
          ticksTextStyle: const TextStyle(fontSize: 0, color: Colors.transparent),
          tickCount: 4,
          titleTextStyle: TextStyle(fontSize: 11, color: c.textSecondary),
          titlePositionPercentageOffset: 0.12,
          getTitle: (i, angle) => RadarChartTitle(text: labels[i]),
          dataSets: [
            for (var i = 0; i < series.length; i++)
              RadarDataSet(
                dataEntries: [for (final v in series[i].data) RadarEntry(value: v)],
                fillColor: col(i).withValues(alpha: 0.18),
                borderColor: col(i),
                borderWidth: 2,
                entryRadius: 2.5,
              ),
          ],
        ));
    }
  }
}

/// Mini-courbe de tendance (sparkline) des tuiles KPI.
class Sparkline extends StatelessWidget {
  const Sparkline(this.data, {super.key, this.color, this.height = 32, this.fill = true});
  final List<double> data;
  final Color? color;
  final double height;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    final col = color ?? context.kc.primary;
    final min = data.reduce(math.min), max = data.reduce(math.max);
    final pad = (max - min) * 0.15 + 0.001;
    return SizedBox(
      height: height,
      child: LineChart(LineChartData(
        minY: min - pad,
        maxY: max + pad,
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: [for (var i = 0; i < data.length; i++) FlSpot(i.toDouble(), data[i])],
            isCurved: true,
            color: col,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: fill,
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [col.withValues(alpha: 0.25), col.withValues(alpha: 0)]),
            ),
          ),
        ],
      )),
    );
  }
}

/// Jauge circulaire (progression / objectif).
class RingGauge extends StatelessWidget {
  const RingGauge({super.key, required this.value, this.size = 72, this.tone = KitTone.primary, this.label, this.stroke = 8});
  final double value;
  final double size, stroke;
  final KitTone tone;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final c = context.kc;
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value.clamp(0, 1)),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (_, v, _) => Stack(fit: StackFit.expand, children: [
          CircularProgressIndicator(value: v, strokeWidth: stroke, backgroundColor: c.fieldBg, color: tone.color(c), strokeCap: StrokeCap.round),
          Center(child: Text(label ?? '${(v * 100).round()} %', style: TextStyle(fontFamily: Fonts.heading, fontWeight: FontWeight.w700, fontSize: size * 0.2, color: c.textPrimary))),
        ]),
      ),
    );
  }
}
