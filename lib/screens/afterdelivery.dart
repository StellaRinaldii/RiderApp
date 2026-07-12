import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workers_campe/models/exercise_activity.dart';
import 'package:workers_campe/providers/possible_shift_provider.dart';
import 'package:workers_campe/screens/homepage.dart';

const kGreen = Color(0xFF4CAF50);

class Afterdelivery extends StatelessWidget {
  const Afterdelivery({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final provider = Provider.of<PossibleShiftProvider>(
      context,
      listen: true,
    );

    final shift = provider.lastCompletedShift;
    final activity = shift?.activity;

    final int batteryAfter = provider.currentBattery.batteryLevel;
    final int realBatteryReduction = provider.lastRealBatteryReduction;

    final int batteryBefore =
        (batteryAfter + realBatteryReduction).clamp(
      0,
      provider.currentBattery.maxLevel,
    );

    final double battery = batteryAfter / 100.0;

    final String estimatedEffortLabel = realBatteryReduction <= 10
        ? 'Low effort'
        : realBatteryReduction < 25
            ? 'Moderate effort'
            : 'High effort';

    final Color estimatedEffortColor = realBatteryReduction <= 10
        ? Colors.green
        : realBatteryReduction < 25
            ? Colors.orange
            : Colors.red;

    return Scaffold(
      backgroundColor: colors.secondary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Delivery Completed!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: colors.primary
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Your Delivery Summary:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.primary
                ),
              ),

              const SizedBox(height: 8),

              _card(
                child: activity == null
                    ? const Text(
                        'No delivery data available.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      )
                    : Column(
                        children: [
                          Row(
                            children: [
                              _stat(
                                'Distance',
                                'km',
                                activity.distanceKm.toStringAsFixed(2),
                              ),
                              const Spacer(),
                              _stat(
                                'Active time',
                                'min',
                                activity.activeDurationMinutes.toString(),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              _stat(
                                'Avg speed',
                                'km/h',
                                (activity.speed ?? 0).toStringAsFixed(1),
                              ),
                              const Spacer(),
                              _stat(
                                'Elevation',
                                'm',
                                (activity.elevationGain ?? 0)
                                    .round()
                                    .toString(),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              _stat(
                                'Avg HR',
                                'bpm',
                                (activity.averageHeartRate ?? 0)
                                    .round()
                                    .toString(),
                              ),
                              const Spacer(),
                              _stat(
                                'Calories',
                                'kcal',
                                (activity.calories ?? 0).round().toString(),
                              ),
                            ],
                          ),

                          const Divider(),

                          _info(
                            Icons.fitness_center,
                            'Effort',
                            estimatedEffortLabel,
                            valueColor: estimatedEffortColor,
                          ),
                          _info(
                            Icons.attach_money,
                            'Money Earned',
                            '€${shift!.earning.toStringAsFixed(2)}',
                          ),

                          const Divider(),

                          _info(
                            Icons.battery_std,
                            'Battery before delivery',
                            '$batteryBefore%',
                          ),
                          _info(
                            Icons.battery_alert,
                            'Real battery reduction',
                            '$realBatteryReduction%',
                          ),
                          _info(
                            Icons.battery_charging_full,
                            'Battery after delivery',
                            '$batteryAfter%',
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 20),

              Text(
                'Energy level',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.primary
                ),
              ),

              const SizedBox(height: 8),

              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _batteryHistoryBar(
                      batteryHistory: provider.batteryHistory,
                      batteryReductionHistory:
                          provider.batteryReductionHistory,
                    ),

                    const SizedBox(height: 1),

                    Center(
                      child: Text(
                        '${battery <= 0.25 ? "Low energy" : battery < 0.7 ? "Moderate energy" : "High energy"} · ${(battery * 100).round()}%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: battery <= 0.25
                              ? Colors.red
                              : battery < 0.7
                                  ? Colors.orange
                                  : Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              if (activity != null && activity.heartRateZones.isNotEmpty) ...[
                Text(
                  'Heart Rate Zones',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),

                const SizedBox(height: 8),

                _card(
                  child: _hrZonesChart(activity.heartRateZones),
                ),

                const SizedBox(height: 20),
              ],

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HomePage(),
                    ),
                    (r) => false,
                  ),
                  icon: const Icon(Icons.home),
                  label: const Text(
                    'Return to Home',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) => Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      );

  static Widget _stat(String title, String unit, String val) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: kGreen,
                fontSize: 15,
              ),
            ),
            Text(
              '$val $unit',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      );

  static Widget _info(
    IconData icon,
    String title,
    String value, {
    Color valueColor = Colors.black,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: kGreen),
            const SizedBox(width: 12),
            Text(
              '$title: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: valueColor,
                  fontWeight: valueColor == Colors.black
                      ? FontWeight.normal
                      : FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );

  static Widget _batteryHistoryBar({
    required List<int> batteryHistory,
    required List<int> batteryReductionHistory,
  }) {
    final int currentBattery =
        batteryHistory.isNotEmpty ? batteryHistory.last : 0;

    final double battery = currentBattery / 100.0;

    return SizedBox(
      height: 120,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double barWidth = constraints.maxWidth;

          return Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 52,
                child: Container(
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),

              Positioned(
                left: 0,
                top: 52,
                child: Container(
                  height: 22,
                  width: barWidth * battery.clamp(0.0, 1.0),
                  decoration: BoxDecoration(
                    color: battery <= 0.25
                        ? Colors.red
                        : battery < 0.7
                            ? Colors.orange
                            : Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),

              for (int i = 0; i < batteryReductionHistory.length; i++)
                if (i + 1 < batteryHistory.length)
                  Positioned(
                    left: (barWidth *
                            (batteryHistory[i + 1] / 100.0)
                                .clamp(0.0, 1.0)) -
                        1.5,
                    top: 46,
                    child: Container(
                      width: 3,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),

              for (int i = 0; i < batteryReductionHistory.length; i++)
                if (i + 1 < batteryHistory.length)
                  Positioned(
                    left: (barWidth *
                            (batteryHistory[i + 1] / 100.0)
                                .clamp(0.0, 1.0)) -
                        18,
                    top: i.isEven ? 16 : 84,
                    child: Text(
                      '-${batteryReductionHistory[i]}%',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }

  static Widget _hrZonesChart(List<HeartRateZone> zones) {
    final maxMinutes = zones
        .map((z) => z.minutes)
        .fold<int>(1, (a, b) => a > b ? a : b);

    final maxY = ((maxMinutes / 50).ceil() * 50).toDouble();

    return SizedBox(
      height: 280,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          barGroups: List.generate(
            zones.length,
            (index) {
              final zone = zones[index];

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: zone.minutes.toDouble(),
                    width: 26,
                    color: kGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ],
              );
            },
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.shade400,
                strokeWidth: 1,
                dashArray: [8, 6],
              );
            },
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 25,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 70,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();

                  if (index < 0 || index >= zones.length) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: SizedBox(
                      width: 85,
                      child: Text(
                        _formatZoneLabel(zones[index].name),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final zone = zones[group.x];

                return BarTooltipItem(
                  '${zone.name}\n${zone.minutes} min',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  static String _formatZoneLabel(String label) {
    return label.replaceAll(' ', '\n');
  }
}