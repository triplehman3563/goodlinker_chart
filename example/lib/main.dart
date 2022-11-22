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
    bloc = _MainBloc(const _MainState(
        panel1DisplayingEntry: null, panel2DisplayingEntry: null));
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
                                  dataSelectionCallback: (entry, selectIndex) {
                                    bloc.add(eventUpdatePanel1Entry(entry));
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
                                      }).toList()
                                        ..addAll(
                                          [
                                            CartesianEntry(
                                              x: (1655071200 +
                                                      240 *
                                                          simulatedDataInterval)
                                                  .toDouble(),
                                              y: double.nan,
                                              data: '',
                                            ),
                                            CartesianEntry(
                                              x: (1655071200 +
                                                      241 *
                                                          simulatedDataInterval)
                                                  .toDouble(),
                                              y: double.nan,
                                              data: '',
                                            ),
                                          ],
                                        ),
                                    ),
                                  ),
                                  // padding: EdgeInsets.all(50),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                            '${state.panel1DisplayingEntry?.x}/${state.panel1DisplayingEntry?.y}'),
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
                                    bloc.add(eventUpdatePanel2Entry(entry));
                                  },
                                  xAxisFormatter: (value) {
                                    DateTime dateTime =
                                        DateTime.fromMillisecondsSinceEpoch(
                                            (value * 1000).toInt());
                                    String text = dateTime.minute == 0
                                        ? '${dateTime.hour}時'
                                        : '${dateTime.hour >= 10 ? '${dateTime.hour}' : '0${dateTime.hour}'}:${dateTime.minute >= 10 ? '${dateTime.minute}' : '0${dateTime.minute}'}';
                                    return value==0?'': dateTime.minute == 0 ? text : '';
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
                                      }).toList()
                                        ..addAll(
                                          [
                                            CartesianEntry(
                                              x: (1655071200 +
                                                      240 *
                                                          simulatedDataInterval)
                                                  .toDouble(),
                                              y: double.nan,
                                              data: '',
                                            ),
                                            CartesianEntry(
                                              x: (1655071200 +
                                                      241 *
                                                          simulatedDataInterval)
                                                  .toDouble(),
                                              y: double.nan,
                                              data: '',
                                            ),
                                          ],
                                        ),
                                    ),
                                  ),
                                  // padding: EdgeInsets.all(50),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                            '${state.panel2DisplayingEntry?.x}/${state.panel2DisplayingEntry?.y}'),
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
    on<eventUpdatePanel1Entry>(_updatePanel1DisplayEntry);
    on<eventUpdatePanel2Entry>(_updatePanel2DisplayEntry);
  }

  void _updatePanel1DisplayEntry(
    eventUpdatePanel1Entry event,
    Emitter<_MainState> emitter,
  ) {
    emitter.call(state.copyWith(
      panel1DisplayingEntry: event.displayingEntry,
    ));
  }

  void _updatePanel2DisplayEntry(
    eventUpdatePanel2Entry event,
    Emitter<_MainState> emitter,
  ) {
    emitter.call(state.copyWith(
      panel2DisplayingEntry: event.displayingEntry,
    ));
  }
}

class _MainState extends Equatable {
  const _MainState({
    this.panel1DisplayingEntry,
    this.panel2DisplayingEntry,
  });
  _MainState copyWith({
    LineChartEntry? panel1DisplayingEntry,
    LineChartEntry? panel2DisplayingEntry,
  }) =>
      _MainState(
        panel1DisplayingEntry:
            panel1DisplayingEntry ?? this.panel1DisplayingEntry,
        panel2DisplayingEntry:
            panel2DisplayingEntry ?? this.panel2DisplayingEntry,
      );

  @override
  List<Object?> get props => [panel1DisplayingEntry, panel2DisplayingEntry];

  final LineChartEntry? panel1DisplayingEntry;
  final LineChartEntry? panel2DisplayingEntry;
}

abstract class _MainEvent {}

class eventUpdatePanel1Entry extends _MainEvent {
  final LineChartEntry? displayingEntry;

  eventUpdatePanel1Entry(this.displayingEntry);
}

class eventUpdatePanel2Entry extends _MainEvent {
  final LineChartEntry? displayingEntry;

  eventUpdatePanel2Entry(this.displayingEntry);
}
