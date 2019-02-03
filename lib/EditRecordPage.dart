import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'model/entity.dart';

const double _kPickerSheetHeight = 216.0;
const double _kPickerItemHeight = 32.0;

class EditRecordPage extends StatefulWidget {
  EditRecordPage({this.data});

  final RecordEntity data;

  @override
  State<StatefulWidget> createState() => _EditRecordState(data);
}

class _EditRecordState extends State<EditRecordPage> {
  DateTime startDate;

  DateTime startTime;
  DateTime endDate;

  DateTime endTime;
  RecordEntity data;
  String inputText;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  _EditRecordState(RecordEntity data) {
    this.data = data;
    if (null != data) {
      startDate = DateTime.fromMillisecondsSinceEpoch(data.startDateTime);
      if (data.hasSelectTime) {
        startTime = DateTime.fromMillisecondsSinceEpoch(data.startDateTime);
      }
      if (data.endDateTime != null && data.endDateTime > 0) {
        endDate = DateTime.fromMillisecondsSinceEpoch(data.endDateTime);
        if (data.hasSelectTime) {
          endTime = DateTime.fromMillisecondsSinceEpoch(data.endDateTime);
        }
      }
    }
  }

  void _onFinish(BuildContext context) {
    FormState formState = _formKey.currentState;
    if (null == startDate || !formState.validate()) {
      String tips;
      if (null == startDate) {
        tips = "请选择开始日期";
      }
      if (!formState.validate()) {
        tips = "请填写备注";
      }
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text(tips),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: const Text('确定'),
                  isDestructiveAction: true,
                  onPressed: () {
                    Navigator.pop(context, '确定');
                  },
                ),
              ],
            ),
      );
    } else {
      formState.save();
      if (null == data) {
        data = RecordEntity();
      }
      if (startTime == null) {
        data.hasSelectTime = false;
        data.startDateTime = startDate.millisecondsSinceEpoch;
      } else {
        data.hasSelectTime = true;
        data.startDateTime = DateTime(startDate.year, startDate.month,
                startDate.day, startTime.hour, startTime.minute)
            .millisecondsSinceEpoch;
      }
      if (endDate != null) {
        if (endTime == null) {
          data.hasSelectTime = false;
          data.endDateTime = endDate.millisecondsSinceEpoch;
        } else {
          data.hasSelectTime = true;
          data.endDateTime = DateTime(endDate.year, endDate.month, endDate.day,
                  endTime.hour, endTime.minute)
              .millisecondsSinceEpoch;
        }
      }
      data.comment = inputText;
      data.isBlank = false;
      Navigator.pop(context, data);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (null != data && null != data.comment) {
      inputText = data.comment;
    } else {
      inputText = '';
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("编辑时光记录"),
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              _onFinish(context);
            },
            child: Container(
              width: 60,
              child: Center(
                  child: Text(
                '完成',
                style: TextStyle(fontSize: 18),
              )),
            ),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          Container(
            color: Color(0x00000000),
            height: 10,
          ),
          _buildStartTimePicker(
              context, "开始日期", CupertinoDatePickerMode.date, startDate,
              (selectDateTime) {
            setState(() => startDate = selectDateTime);
          }, '请选择开始日期'),
          _buildStartTimePicker(
              context, "开始时间", CupertinoDatePickerMode.time, startTime,
              (selectDateTime) {
            setState(() => startTime = selectDateTime);
          }, '(可选)如不选择，则只计算天数'),
          Container(
            color: Color(0xEEEEEEEE),
            height: 10,
          ),
          _buildStartTimePicker(
              context, "结束日期", CupertinoDatePickerMode.date, endDate,
              (selectDateTime) {
            setState(() => endDate = selectDateTime);
          }, '(可选)请选择结束日期'),
          _buildStartTimePicker(
              context, "结束时间", CupertinoDatePickerMode.time, endTime,
              (selectDateTime) {
            setState(() => endTime = selectDateTime);
          }, '(可选)请选择结束时间'),
          Container(
            margin: EdgeInsets.only(left: 10, top: 20, right: 10, bottom: 20),
            child: Form(
              key: _formKey,
              child: TextFormField(
                initialValue: inputText,
                autovalidate: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  helperText: '这一天发生了什么',
                  labelText: '备注',
                ),
                maxLines: 3,
                onSaved: (saved) => inputText = saved,
                validator: (str) {
                  if (str.isEmpty) {
                    return '请填写备注';
                  }
                  return null;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartTimePicker(
      BuildContext context,
      String title,
      CupertinoDatePickerMode mode,
      DateTime initialDateTime,
      Function onDateTimeChange,
      String nullTimeDes) {
    String des;
    if (null == initialDateTime) {
      des = nullTimeDes;
      initialDateTime = DateTime.now();
    } else {
      if (mode == CupertinoDatePickerMode.date) {
        des = DateFormat("yyyy-MM-dd").format(initialDateTime);
      } else {
        des = DateFormat.Hm().format(initialDateTime);
      }
    }
    return GestureDetector(
      onTap: () {
        showCupertinoModalPopup<void>(
          context: context,
          builder: (BuildContext context) {
            return _buildBottomPicker(
              CupertinoDatePicker(
                mode: mode,
                initialDateTime: initialDateTime,
                use24hFormat: true,
                onDateTimeChanged: (DateTime newDateTime) {
                  onDateTimeChange(newDateTime);
                },
              ),
            );
          },
        );
      },
      child: _buildMenu(
        <Widget>[
          Text(title),
          Text(
            des,
            style: const TextStyle(color: CupertinoColors.inactiveGray),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPicker(Widget picker) {
    return Container(
      height: _kPickerSheetHeight,
      padding: const EdgeInsets.only(top: 6.0),
      color: CupertinoColors.white,
      child: DefaultTextStyle(
        style: const TextStyle(
          color: CupertinoColors.black,
          fontSize: 22.0,
        ),
        child: GestureDetector(
          // Blocks taps from propagating to the modal sheet and popping.
          onTap: () {},
          child: SafeArea(
            top: false,
            child: picker,
          ),
        ),
      ),
    );
  }

  Widget _buildMenu(List<Widget> children) {
    return Container(
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFBCBBC1), width: 0.0),
        ),
      ),
      height: 44.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SafeArea(
          top: false,
          bottom: false,
          child: DefaultTextStyle(
            style: const TextStyle(
              letterSpacing: -0.24,
              fontSize: 17.0,
              color: CupertinoColors.black,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}
