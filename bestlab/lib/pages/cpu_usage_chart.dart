import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class CpuUsageChart extends StatefulWidget {
  @override
  _CpuUsageChartState createState() => _CpuUsageChartState();
}

class _CpuUsageChartState extends State<CpuUsageChart> {
  List<FlSpot> spots = [];
  Timer? _timer;
  int dataPointIndex = 0; // Counter for x-axis values

  @override
  void initState() {
    super.initState();
    fetchData();
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      fetchData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse('http://tramquantrac.shop:10000/prometheus/api/v1/query?query=process_cpu_usage'),
        headers: {
          'Authorization': 'Bearer d2343b58f372e28159dab5e3c3a5f6738c7d830e',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['data']['result'][0];
        final value = double.parse(result['value'][1]);

        setState(() {
          // Add new data point with a fixed index for the x value
          spots.add(FlSpot(dataPointIndex.toDouble(), value));
          dataPointIndex++;

          // Limit the data to the last 30 points
          if (spots.length > 30) {
            spots.removeAt(0);
            dataPointIndex--; // Decrement index to maintain continuity
          }
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CPU Usage Chart'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toString(),
                      style: const TextStyle(color: Colors.black, fontSize: 10),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    // Display fixed x-axis labels
                    return Text(
                      (value.toInt() + 1).toString(), // Labels: 1, 2, 3, ...
                      style: const TextStyle(color: Colors.black, fontSize: 10),
                    );
                  },
                ),
              ),
            ),
            gridData: FlGridData(show: true),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: const Color(0xff37434d)),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: Colors.blue[600],
                belowBarData: BarAreaData(show: false),
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: Colors.blue,
                      strokeWidth: 1,
                      strokeColor: Colors.white,
                    );
                  },
                ),
              ),
            ],
            minX: 0,
            maxX: 29, // Set maxX to the maximum index you want to display
            minY: 0,
            maxY: 1,  // Set max Y value based on expected CPU usage
          ),
        ),
      ),
    );
  }
}