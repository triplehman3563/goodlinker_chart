import 'package:flutter/material.dart';
import 'package:goodlinker_chart/goodlinker_chart.dart';
import 'package:goodlinker_chart/src/FakeData.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final simulatedItemNumber = 240;
  final simulatedDataInterval = 180;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(children: [
          const Text('test'),
          Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 200,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TimestampXAxisLineChart(
                    // padding: EdgeInsets.all(20),
                    style: LineChartStyle(lineStyle: LineStyle()),
                    dataSet: TimestampXAxisDataSet(
                      data: Iterable.generate(simulatedItemNumber * 3 ~/ 4,
                          (index) {
                        final List<double> fakeData = FakeData.bigFakeData;
                        return TimestampXAxisData(
                            x: 1655071200 + index * simulatedDataInterval,
                            y: fakeData[index % fakeData.length]);
                      }).toList(),
                      xAxisStartPoint: 1655071200,
                      xAxisEndPoint: 1655071200 +
                          simulatedItemNumber * simulatedDataInterval,
                      // baseline: [350, 400],
                      upperBaseline: const ChartBaseline(dy: 400),
                      lowerBaseline: const ChartBaseline(dy: 350),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 200,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TimestampXAxisBarChart(
                    // padding: EdgeInsets.all(50),
                    style: BarChartStyle(
                        style: BarStyle(
                      normalColor: Colors.green.withAlpha(75),
                      underMaskColor: Colors.red.withAlpha(75),
                    )),
                    dataSet: TimestampXAxisDataSet(
                      data: Iterable.generate(simulatedItemNumber, (index) {
                        final List<double> fakeData = FakeData.bigFakeData;
                        return TimestampXAxisData(
                            x: 1655071200 + index * simulatedDataInterval,
                            y: fakeData[index % fakeData.length]);
                      }).toList(),
                      xAxisStartPoint: 1655071200,
                      xAxisEndPoint: 1655071200 +
                          simulatedItemNumber * simulatedDataInterval,
                      // baseline: [350, 400],
                      upperBaseline: const ChartBaseline(
                          dy: 400, baselineColor: Colors.red),
                      lowerBaseline: const ChartBaseline(
                          dy: 350, baselineColor: Colors.red),
                    ),
                  ),
                ),
              ),
            ],
          ),
          //   Expanded(
          //     child: ListView(
          //       shrinkWrap: true,
          //       children: FakeData.fakeDataSets.map((e) {
          //         return Padding(
          //           padding: const EdgeInsets.all(8.0),
          //           child: Row(
          //             children: [
          //               Expanded(
          //                 child: Container(
          //                   // padding: EdgeInsets.all(1),
          //                   // decoration: BoxDecoration(
          //                   //     border: Border.all(
          //                   //       color: Color.fromARGB(20, 33, 33, 33),
          //                   //       width: 2,
          //                   //     ),
          //                   //     borderRadius:
          //                   //         BorderRadius.all(Radius.circular(10))),
          //                   width: MediaQuery.of(context).size.width * 0.5,
          //                   height: 100,
          //                   child: TimestampXAxisLineChart(
          //                     dataSet: TimestampXAxisDataSet(
          //                       data: Iterable.generate(simulatedItemNumber,
          //                           (index) {
          //                         final List<double> _fakeData = e;
          //                         return TimestampXAxisData(
          //                             x: 1655071200 +
          //                                 index * simulatedDataInterval,
          //                             y: _fakeData[index % _fakeData.length]);
          //                       }).toList(),
          //                       // baseline: [350, 400],
          //                       upperBaseline: const ChartBaseline(
          //                         dy: 400,
          //                       ),
          //                       lowerBaseline: const ChartBaseline(
          //                         dy: 350,
          //                       ),
          //                       xAxisStartPoint: 1655071200,
          //                       xAxisEndPoint: 1655071200 +
          //                           simulatedItemNumber * simulatedDataInterval,
          //                     ),
          //                   ),
          //                 ),
          //               ),
          //               Container(
          //                 width: MediaQuery.of(context).size.width * 0.3,
          //                 height: 100,
          //                 child: Column(
          //                   mainAxisAlignment: MainAxisAlignment.center,
          //                   children: [
          //                     const Text('test'),
          //                   ],
          //                 ),
          //               )
          //             ],
          //           ),
          //         );
          //       }).toList(),
          //     ),
          //   ),
          // ],
        ]),
      ),
    );
  }
}
