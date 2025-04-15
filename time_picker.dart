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
  final DateTime initialDateTime;
  final bool is24HourFormat;
  final ValueSetter<TimeOfDay> setTime;

  const NoelTimePicker({
    super.key,
    required this.initialDateTime,
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
  late final _hourList;
  late final _minuteList;
  int selectedHour = 0;
  int selectedMinute = 0;
  bool isAM = true;

  List<String> _generateNumberList(int start, int end, int indexStep) {
    return List<String>.generate(((end - start) ~/ indexStep) + 1, (index) => '${start + index * indexStep}');
  }

  @override
  void initState() {
    super.initState();
    _hourList = widget.is24HourFormat ? _generateNumberList(0, 23, 1) : _generateNumberList(1, 12, 1);
    _minuteList = _generateNumberList(0, 55, 5);
    selectedHour = widget.initialDateTime.hour;
    selectedMinute = widget.initialDateTime.minute ~/ 5 * 5;
    final initHourIndex = widget.is24HourFormat ? selectedHour : ((selectedHour % 12) == 0 ? 11 : (selectedHour % 12) - 1);
    final initMinuteIndex = selectedMinute ~/ 5;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hourController.jumpToItem(initHourIndex);
      _minuteController.jumpToItem(initMinuteIndex);
    });
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
                        childCount: _hourList.length,
                        builder: (context, index) => Center(
                          child: Text(_hourList[index], style: const TextStyle(fontSize: 24)),
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
                        childCount: _minuteList.length,
                        builder: (context, index) => Center(
                          child: Text(_minuteList[index], style: const TextStyle(fontSize: 24)),
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
  bool _isSelected = false;

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
          Center(
            child: GestureDetector(
              onTap: () => setState(() => _isSelected = !_isSelected),
              child: Container(
                height: 28,
                padding: EdgeInsets.symmetric(horizontal: 8,),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8,),
                  color: (_isSelected) ? Color(0xFFF4F1E5) : Colors.transparent,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF6C757D),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    SizedBox(width: 8,),
                    Text(DateFormat((_is24HourFormat) ? 'Hm' : 'h:mm a').format(_displayDateTime), style: const TextStyle(fontSize: 24)),
                  ],
                ),
              ),
            ),
          ),
          /*Switch(
            value: _is24HourFormat,
            onChanged: (value) {
              setState(() {
                //BUG: If you change the format, time is out of sync due to index offsets.
                //This is no problem if user cannot change between 24 hour amd 12 hour format in the same screen that displays the time
                _is24HourFormat = !_is24HourFormat;
              });
            },
          ),*/
          Visibility(
            visible: _isSelected,
            child: TapRegion(
              onTapOutside: (PointerDownEvent event) => setState(() => _isSelected = false),
              child: NoelTimePicker(
                initialDateTime: _displayDateTime,
                is24HourFormat: _is24HourFormat,
                setTime: (time) {
                  print("Selected Time: $time");
                  setState(() => _displayDateTime = DateTime(_nowTime.year, _nowTime.month, _nowTime.day, time.hour, time.minute));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
