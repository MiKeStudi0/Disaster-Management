import 'package:disaster_management/app/ui/widgets/indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CustomPieChart extends StatefulWidget {
  final List<double> values;
  final List<Color> colors;
  final List<String> labels;

  const CustomPieChart({
    Key? key,
    required this.values,
    required this.colors,
    required this.labels,
  }) : super(key: key);

  @override
  State<CustomPieChart> createState() => _CustomPieChartState();
}

class _CustomPieChartState extends State<CustomPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Row(
        children: <Widget>[
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections: showingSections(),
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(widget.labels.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Indicator(
                  color: widget.colors[index],
                  text: widget.labels[index],
                  isSquare: true,
                ),
              );
            }),
          ),
          const SizedBox(width: 28),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(widget.values.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      return PieChartSectionData(
        color: widget.colors[i],
        value: widget.values[i],
        title: '${widget.values[i].toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        ),
      );
    });
  }
}
