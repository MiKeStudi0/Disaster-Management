import 'package:disaster_management/disaster/screen/Notifi/alert/alertbox.dart';
import 'package:disaster_management/disaster/screen/bar%20charts/barchart.dart';
import 'package:disaster_management/disaster/screen/bar%20charts/piechart.dart';
import 'package:flutter/material.dart';

class Charts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(" Charts ")),
      body: ListView(
        children:  const [
          ResourceManagementChart(),
           
          CustomPieChart(
            values: [40, 30, 15, 15],
            colors: [Colors.blue, Colors.yellow, Colors.purple, Colors.green],
            labels: ['First', 'Second', 'Third', 'Fourth'],
          ),
          CustomPieChart(
            values: [50, 25, 15, 10],
            colors: [Colors.red, Colors.orange, Colors.blue, Colors.green],
            labels: ['A', 'B', 'C', 'D'],
          ),
         Padding(padding: EdgeInsets.only(top: 20),
         child: AlertBox(),),
          
          CustomPieChart(
            values: [70, 20, 5, 5],
            colors: [Colors.pink, Colors.teal, Colors.amber, Colors.indigo],
            labels: ['Alpha', 'Beta', 'Gamma', 'Delta'],
          ),
          // Add as many pie chart widgets as needed
        ],
      ),
    );

  }
}
