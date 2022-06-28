import 'package:flutter/material.dart';
import 'package:goodlinker_chart/FakeData.dart';
import 'package:goodlinker_chart/TimestampXAxisBarChart.dart';
import 'package:goodlinker_chart/TimestampXAxisLineChart.dart';
import 'package:goodlinker_chart/common/entry/ChartRuleLine.dart';
import 'package:goodlinker_chart/common/entry/TimestampXAxisData.dart';
import 'package:goodlinker_chart/common/entry/TimestampXAxisDataSet.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

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
        child: Column(
          children: [
            const Text('test'),
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  height: 200,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TimestampXAxisLineChart(
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
                        upperBaseline: const ChartRuleline(
                            dy: 400, baselineColor: Colors.red),
                        lowerBaseline: const ChartRuleline(
                            dy: 350, baselineColor: Colors.red),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  height: 200,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TimestampXAxisBarChart(
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
                        upperBaseline: const ChartRuleline(
                            dy: 400, baselineColor: Colors.red),
                        lowerBaseline: const ChartRuleline(
                            dy: 350, baselineColor: Colors.red),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: FakeData.fakeDataSets.map((e) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            // padding: EdgeInsets.all(1),
                            // decoration: BoxDecoration(
                            //     border: Border.all(
                            //       color: Color.fromARGB(20, 33, 33, 33),
                            //       width: 2,
                            //     ),
                            //     borderRadius:
                            //         BorderRadius.all(Radius.circular(10))),
                            width: MediaQuery.of(context).size.width * 0.5,
                            height: 100,
                            child: TimestampXAxisLineChart(
                              dataSet: TimestampXAxisDataSet(
                                data: Iterable.generate(simulatedItemNumber,
                                    (index) {
                                  final List<double> fakeData = e;
                                  return TimestampXAxisData(
                                      x: 1655071200 +
                                          index * simulatedDataInterval,
                                      y: fakeData[index % fakeData.length]);
                                }).toList(),
                                // baseline: [350, 400],
                                upperBaseline: const ChartRuleline(
                                    dy: 400, baselineColor: Colors.red),
                                lowerBaseline: const ChartRuleline(
                                    dy: 350, baselineColor: Colors.red),
                                xAxisStartPoint: 1655071200,
                                xAxisEndPoint: 1655071200 +
                                    simulatedItemNumber * simulatedDataInterval,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: 100,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('test'),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
