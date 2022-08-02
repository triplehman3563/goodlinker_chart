import 'package:equatable/equatable.dart';
import 'package:example/FakeData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goodlinker_chart/goodlinker_chart.dart';

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
  late _MainBloc bloc;
  @override
  void initState() {
    bloc = _MainBloc(const _MainState(null));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: BlocProvider(
            create: (context) => bloc,
            child: BlocBuilder<_MainBloc, _MainState>(
              builder: (context, state) {
                return Column(
                  children: [
                    const Text('test'),
                    Row(
                      children: [
                        SizedBox(
                          width: 200,
                          height: 100,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SimpleBarChart(
                              xAxisFormatter: (value) {
                                DateTime dateTime =
                                    DateTime.fromMillisecondsSinceEpoch(
                                        (value * 1000).toInt());
                                String text = dateTime.minute == 0
                                    ? '${dateTime.hour}時'
                                    : '${dateTime.hour >= 10 ? '${dateTime.hour}' : '0${dateTime.hour}'}:${dateTime.minute >= 10 ? '${dateTime.minute}' : '0${dateTime.minute}'}';
                                return dateTime.minute == 0 ? text : '';
                                // return text;
                              },
                              // padding: EdgeInsets.all(50),
                              style: BarChartStyle(
                                  style: BarStyle(
                                normalColor: Colors.green.withAlpha(75),
                                underMaskColor: Colors.red.withAlpha(75),
                              )),
                              dataSet: TimestampXAxisDataSet(
                                data: Iterable.generate(simulatedItemNumber,
                                    (index) {
                                  final List<double> thisFakeData =
                                      FakeData.bigFakeData;
                                  return TimestampXAxisData(
                                      x: 1655071200 +
                                          index * simulatedDataInterval,
                                      y: thisFakeData[
                                          index % thisFakeData.length]);
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
                        SizedBox(
                          width: 200,
                          height: 100,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SimpleLineChart(
                              // padding: EdgeInsets.all(50),
                              style: LineChartStyle(lineStyle: LineStyle()),
                              xAxisFormatter: (value) {
                                DateTime dateTime =
                                    DateTime.fromMillisecondsSinceEpoch(
                                        (value * 1000).toInt());
                                String text = dateTime.minute == 0
                                    ? '${dateTime.hour}時'
                                    : '${dateTime.hour >= 10 ? '${dateTime.hour}' : '0${dateTime.hour}'}:${dateTime.minute >= 10 ? '${dateTime.minute}' : '0${dateTime.minute}'}';
                                return dateTime.minute == 0 ? text : '';
                                // return text;
                              },
                              dataSet: TimestampXAxisDataSet(
                                data: Iterable.generate(simulatedItemNumber,
                                    (index) {
                                  final List<double> thisFakeData =
                                      FakeData.bigFakeData;
                                  return TimestampXAxisData(
                                      x: 1655071200 +
                                          index * simulatedDataInterval,
                                      y: thisFakeData[
                                          index % thisFakeData.length]);
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
                    Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 300,
                              height: 200,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: LineChart(
                                  dataSelectionCallback:
                                      (entry, selectIndex) {},
                                  xAxisFormatter: (value) {
                                    DateTime dateTime =
                                        DateTime.fromMillisecondsSinceEpoch(
                                            (value * 1000).toInt());
                                    String text = dateTime.minute == 0
                                        ? '${dateTime.hour}時'
                                        : '${dateTime.hour >= 10 ? '${dateTime.hour}' : '0${dateTime.hour}'}:${dateTime.minute >= 10 ? '${dateTime.minute}' : '0${dateTime.minute}'}';
                                    return dateTime.minute == 0 ? text : '';
                                    // return text;
                                  },
                                  yAxisFormatter: (value) {
                                    return value.toStringAsFixed(1);
                                    // return text;
                                  },
                                  cartesianDataSet: CartesianDataSet(
                                    upperMaskLine: 600,
                                    lowerMaskLine: 280,
                                    maxValue: 630,
                                    minValue: 253,
                                    data: CartesianData(
                                      entities: Iterable.generate(
                                          simulatedItemNumber, (index) {
                                        final List<double> thisFakeData =
                                            FakeData.bigFakeData;
                                        return CartesianEntry(
                                          x: (1655071200 +
                                                  index * simulatedDataInterval)
                                              .toDouble(),
                                          y: thisFakeData[
                                              index % thisFakeData.length],
                                          data: '',
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  // padding: EdgeInsets.all(50),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 300,
                              height: 200,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: LineChart(
                                  defalutDisplayRange: 100,
                                  defaultMiddleDisplayIndex:
                                      simulatedItemNumber - 1,
                                  dataSelectionCallback:
                                      (entry, selectIndex) {},
                                  xAxisFormatter: (value) {
                                    DateTime dateTime =
                                        DateTime.fromMillisecondsSinceEpoch(
                                            (value * 1000).toInt());
                                    String text = dateTime.minute == 0
                                        ? '${dateTime.hour}時'
                                        : '${dateTime.hour >= 10 ? '${dateTime.hour}' : '0${dateTime.hour}'}:${dateTime.minute >= 10 ? '${dateTime.minute}' : '0${dateTime.minute}'}';
                                    return dateTime.minute == 0 ? text : '';
                                    // return text;
                                  },
                                  yAxisFormatter: (value) {
                                    return value.toStringAsFixed(1);
                                    // return text;
                                  },
                                  cartesianDataSet: CartesianDataSet(
                                    upperMaskLine: 600,
                                    lowerMaskLine: 280,
                                    maxValue: 630,
                                    minValue: 253,
                                    data: CartesianData(
                                      entities: Iterable.generate(
                                          simulatedItemNumber, (index) {
                                        final List<double> thisFakeData =
                                            FakeData.bigFakeData;
                                        return CartesianEntry(
                                          x: (1655071200 +
                                                  index * simulatedDataInterval)
                                              .toDouble(),
                                          y: thisFakeData[
                                              index % thisFakeData.length],
                                          data: '',
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  // padding: EdgeInsets.all(50),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 100,
                              height: 200,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: BarChart(
                                  dataSelectionCallback: (entry, selectIndex) {
                                    bloc.add(
                                        _MainEventUpdateDisplayEntry(entry));
                                  },
                                  xAxisFormatter: (value) {
                                    DateTime dateTime =
                                        DateTime.fromMillisecondsSinceEpoch(
                                            (value * 1000).toInt());
                                    String text = dateTime.minute == 0
                                        ? '${dateTime.hour}時'
                                        : '${dateTime.hour >= 10 ? '${dateTime.hour}' : '0${dateTime.hour}'}:${dateTime.minute >= 10 ? '${dateTime.minute}' : '0${dateTime.minute}'}';
                                    return dateTime.minute == 0 ? text : '';
                                    // return text;
                                  },
                                  yAxisFormatter: (value) {
                                    return value.toStringAsFixed(1);
                                    // return text;
                                  },
                                  cartesianDataSet: CartesianDataSet(
                                    upperMaskLine: 600,
                                    lowerMaskLine: 280,
                                    maxValue: 630,
                                    minValue: 253,
                                    data: CartesianData(
                                      entities: Iterable.generate(
                                          simulatedItemNumber, (index) {
                                        final List<double> thisFakeData =
                                            FakeData.bigFakeData;
                                        return CartesianEntry(
                                          x: (1655071200 +
                                                  index * simulatedDataInterval)
                                              .toDouble(),
                                          y: thisFakeData[
                                              index % thisFakeData.length],
                                          data: '',
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  // padding: EdgeInsets.all(50),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (state.displayingEntry != null)
                          Column(
                            children: [
                              Text(
                                  'data: ${state.displayingEntry?.originEntry.x}'),
                              Text(
                                  'data: ${state.displayingEntry?.originEntry.y}'),
                              Text(
                                  'data: ${state.displayingEntry?.originEntry.data}'),
                            ],
                          )
                      ],
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 70,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: BarChart(
                                  defalutDisplayRange: 100,
                                  defaultMiddleDisplayIndex: 0,
                                  dataSelectionCallback: (entry, selectIndex) {
                                    bloc.add(
                                        _MainEventUpdateDisplayEntry(entry));
                                  },
                                  xAxisFormatter: (value) {
                                    DateTime dateTime =
                                        DateTime.fromMillisecondsSinceEpoch(
                                            (value * 1000).toInt());
                                    String text = dateTime.minute == 0
                                        ? '${dateTime.hour}時'
                                        : '${dateTime.hour >= 10 ? '${dateTime.hour}' : '0${dateTime.hour}'}:${dateTime.minute >= 10 ? '${dateTime.minute}' : '0${dateTime.minute}'}';
                                    return dateTime.minute == 0 ? text : '';
                                    // return text;
                                  },
                                  yAxisFormatter: (value) {
                                    return value.toStringAsFixed(1);
                                    // return text;
                                  },
                                  cartesianDataSet: CartesianDataSet(
                                    upperMaskLine: 600,
                                    lowerMaskLine: 280,
                                    maxValue: 630,
                                    minValue: 253,
                                    data: CartesianData(
                                      entities: Iterable.generate(
                                          simulatedItemNumber, (index) {
                                        final List<double> thisFakeData =
                                            FakeData.bigFakeData;
                                        return CartesianEntry(
                                          x: (1655071200 +
                                                  index * simulatedDataInterval)
                                              .toDouble(),
                                          y: thisFakeData[
                                              index % thisFakeData.length],
                                          data: '',
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  // padding: EdgeInsets.all(50),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (state.displayingEntry != null)
                          Column(
                            children: [
                              Text(
                                  'data: ${state.displayingEntry?.originEntry.x}'),
                              Text(
                                  'data: ${state.displayingEntry?.originEntry.y}'),
                              Text(
                                  'data: ${state.displayingEntry?.originEntry.data}'),
                            ],
                          )
                      ],
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
}

class _MainBloc extends Bloc<_MainEvent, _MainState> {
  _MainBloc(_MainState initialState) : super(initialState) {
    on<_MainEventUpdateDisplayEntry>(_updateDisplayEntry);
  }

  void _updateDisplayEntry(
    _MainEventUpdateDisplayEntry event,
    Emitter<_MainState> emitter,
  ) {
    emitter.call(_MainState(event.displayingEntry));
  }
}

class _MainState extends Equatable {
  const _MainState(this.displayingEntry);

  @override
  List<Object?> get props => [displayingEntry];

  final LineChartEntry? displayingEntry;
}

abstract class _MainEvent {}

class _MainEventUpdateDisplayEntry extends _MainEvent {
  final LineChartEntry displayingEntry;

  _MainEventUpdateDisplayEntry(this.displayingEntry);
}
