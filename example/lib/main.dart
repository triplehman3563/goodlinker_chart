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
        textTheme: TextTheme(),
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
                    Column(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 200,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: BarChart(
                              dataSet: [
                                NewData(x: 1655071200, y: 600),
                                NewData(x: 1655071380, y: double.nan),
                                NewData(x: 1655071560, y: 660),
                                NewData(x: 1655071740, y: double.nan),
                                NewData(x: 1655071920, y: 550),
                                NewData(x: 1655072100, y: 400),
                                NewData(x: 1655072280, y: double.nan),
                                NewData(x: 1655072460, y: 700),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 200,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: BarChart(
                              dataSet: [
                                NewData(x: 1655071200, y: 600),
                                NewData(x: 1655071380, y: 600),
                                NewData(x: 1655071560, y: 600),
                                NewData(x: 1655071740, y: 600),
                                NewData(x: 1655071920, y: 600),
                                NewData(x: 1655072100, y: 600),
                                NewData(x: 1655072280, y: 600),
                                NewData(x: 1655072460, y: 600),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 200,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: BarChart(
                              dataSet: [
                                NewData(x: 1655071200, y: 0),
                                NewData(x: 1655071380, y: 0),
                                NewData(x: 1655071560, y: 0),
                                NewData(x: 1655071740, y: 0),
                                NewData(x: 1655071920, y: 0),
                                NewData(x: 1655072100, y: 0),
                                NewData(x: 1655072280, y: 0),
                                NewData(x: 1655072460, y: 0),
                              ],
                            ),
                          ),
                        ),
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
  final LineChartEntry? displayingEntry;

  _MainEventUpdateDisplayEntry(this.displayingEntry);
}
