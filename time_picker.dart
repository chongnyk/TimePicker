import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Root of the application
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Date Duration Picker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TestScreen(),
    );
  }
}

class NoelTimePicker extends StatefulWidget {
  final bool is24HourFormat;
  final ValueSetter<TimeOfDay> setTime;

  const NoelTimePicker({
    super.key,
    this.is24HourFormat = true,
    required this.setTime,
  });

  @override
  State<NoelTimePicker> createState() => _NoelTimePickerState();
}

class _NoelTimePickerState extends State<NoelTimePicker> {
  final FixedExtentScrollController _hourController = FixedExtentScrollController();
  final FixedExtentScrollController _minuteController = FixedExtentScrollController();
  final FixedExtentScrollController? _periodController = FixedExtentScrollController();
  int selectedHour = 0;
  int selectedMinute = 0;
  bool isAM = true;

  List<String> _generateNumberList(int start, int end, int indexStep) {
    return List<String>.generate(((end - start) ~/ indexStep) + 1, (index) => '${start + index * indexStep}');
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _periodController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hourList = widget.is24HourFormat ? _generateNumberList(0, 23, 1) : _generateNumberList(1, 12, 1);
    final minuteList = _generateNumberList(0, 55, 5);
    
    return Container(
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: SizedBox(
                  height: 150,
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.black, Colors.transparent, Colors.transparent, Colors.black],
                      stops: [0.0, 0.4, 0.6, 1.0],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds),
                    blendMode: BlendMode.dstOut,
                    child: ListWheelScrollView.useDelegate(
                      controller: _hourController,
                      physics: const FixedExtentScrollPhysics(),
                      itemExtent: 50,
                      perspective: 0.003,
                      onSelectedItemChanged: (index) => setState(() {
                        selectedHour = widget.is24HourFormat ? index : index + 1;
                        widget.setTime(TimeOfDay(hour: (!widget.is24HourFormat && !isAM) ? (selectedHour + 12) % 24 : selectedHour, minute: selectedMinute));
                      }),
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: hourList.length,
                        builder: (context, index) => Center(
                          child: Text(hourList[index], style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Text(":", style: TextStyle(fontSize: 24)),
              Expanded(
                child: SizedBox(
                  height: 150,
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.black, Colors.transparent, Colors.transparent, Colors.black],
                      stops: [0.0, 0.4, 0.6, 1.0],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds),
                    blendMode: BlendMode.dstOut,
                    child: ListWheelScrollView.useDelegate(
                      controller: _minuteController,
                      physics: const FixedExtentScrollPhysics(),
                      itemExtent: 50,
                      perspective: 0.003,
                      onSelectedItemChanged: (index) => setState(() {
                        selectedMinute = index * 5;
                        widget.setTime(TimeOfDay(hour: (!widget.is24HourFormat && !isAM) ? (selectedHour + 12) % 24 : selectedHour, minute: selectedMinute));
                      }),
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: minuteList.length,
                        builder: (context, index) => Center(
                          child: Text(minuteList[index], style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: !widget.is24HourFormat,
                child: Expanded(
                  child: SizedBox(
                    height: 150,
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.black, Colors.transparent, Colors.transparent, Colors.black],
                        stops: [0.0, 0.4, 0.6, 1.0],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ).createShader(bounds),
                      blendMode: BlendMode.dstOut,
                      child: ListWheelScrollView.useDelegate(
                        controller: _periodController,
                        physics: const FixedExtentScrollPhysics(),
                        itemExtent: 50,
                        perspective: 0.003,
                        onSelectedItemChanged: (index) => setState(() {
                          isAM = index == 0;
                          widget.setTime(TimeOfDay(hour: (!widget.is24HourFormat && !isAM) ? (selectedHour + 12) % 24 : selectedHour, minute: selectedMinute));
                        }),
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) =>
                              Center(child: Text((index == 0) ? 'AM' : 'PM', style: const TextStyle(fontSize: 24))),
                          childCount: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  DateTime _nowTime = DateTime.now();
  late DateTime _displayDateTime;
  bool _is24HourFormat = true;

  @override
  void initState() {
    super.initState();
    _displayDateTime = DateTime(_nowTime.year, _nowTime.month, _nowTime.day, 0, 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Screen'),
      ),
      body: Column(
        children: [
          Text(DateFormat((_is24HourFormat) ? 'Hm' : 'h:mm a').format(_displayDateTime), style: const TextStyle(fontSize: 24)),
          Switch(
            value: _is24HourFormat,
            onChanged: (value) {
              setState(() {
                _is24HourFormat = !_is24HourFormat;
              });
            },
          ),
          NoelTimePicker(
            is24HourFormat: _is24HourFormat,
            setTime: (time) {
              print("Selected Time: $time");
              setState(() => _displayDateTime = DateTime(_nowTime.year, _nowTime.month, _nowTime.day, time.hour, time.minute));
            },
          ),
        ],
      ),
    );
  }
}
