import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'main.dart';
import 'model/entity.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:permission_handler/permission_handler.dart';

const double _kPickerSheetHeight = 216.0;

class EditRecordPage extends StatefulWidget {
  EditRecordPage({this.data, this.recordType = TIME_RECORD});

  final RecordEntity data;
  final String recordType;

  @override
  State<StatefulWidget> createState() => _EditRecordState(data);
}

class _EditRecordState extends State<EditRecordPage> {
  DateTime startDate;

  DateTime endDate;

  RecordEntity data;
  String inputText;

  File _image;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  _EditRecordState(RecordEntity data) {
    this.data = data;
    if (null != data) {
      startDate = DateTime.fromMillisecondsSinceEpoch(data.startDateTime);
      if (data.endDateTime != null && data.endDateTime > 0) {
        endDate = DateTime.fromMillisecondsSinceEpoch(data.endDateTime);
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
      data.startDateTime = startDate.millisecondsSinceEpoch;
      if (endDate != null) {
        data.endDateTime = endDate.millisecondsSinceEpoch;
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
        children: _getListItem(),
      ),
    );
  }

  List<Widget> _getListItem() {
    List<Widget> list = List();
    list.add(Container(
      color: Color(0xEEEEEEEE),
      height: 10,
    ));
    list.add(_buildStartTimePicker(
        context, "From:", CupertinoDatePickerMode.date, startDate,
        (selectDateTime) {
      setState(() => startDate = selectDateTime);
    }, '请选择日期'));
    list.add(Container(
      color: Color(0xEEEEEEEE),
      height: 10,
    ));
    if (widget.recordType == TIME_JOURNEY) {
      list.add(_buildStartTimePicker(
          context, "To:", CupertinoDatePickerMode.date, endDate,
          (selectDateTime) {
        setState(() => endDate = selectDateTime);
      }, '请选择日期'));
      list.add(Container(
        color: Color(0xEEEEEEEE),
        height: 10,
      ));
    }
    if (null != _image) {
      list.add(GestureDetector(
        onTap: _selePicture,
        child: Image.file(
          _image,
          width: 150,
          height: 150,
        ),
      ));
    } else {
      list.add(GestureDetector(
        onTap: _selePicture,
        child: Image.asset(
          "images/icon_camera.png",
          width: 150,
          height: 150,
        ),
      ));
    }
    list.add(Container(
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
    ));
    return list;
  }

  void _selePicture() {
    showDemoActionSheet(
      context: context,
      child: CupertinoActionSheet(
          title: const Text(
            '添加时光照片',
            style: TextStyle(fontSize: 20),
          ),
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: const Text('从相册选择'),
              onPressed: () {
                getImage(ImageSource.gallery);
              },
            ),
            CupertinoActionSheetAction(
              child: const Text('拍照'),
              onPressed: () {
                getImage(ImageSource.camera);
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: const Text('取消'),
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context, '');
            },
          )),
    );
  }

  Future getImage(ImageSource source) async {
    var permission;
    if (source == ImageSource.gallery) {
      permission =  PermissionGroup.storage ;
    } else {
      permission =  PermissionGroup.camera ;
    }
    var permissionStatus =
        await PermissionHandler().checkPermissionStatus(permission);
    if (permissionStatus != PermissionStatus.granted) {
      Navigator.pop(context, '');
      final List<PermissionGroup> permissionList = <PermissionGroup>[permission];
      Map<PermissionGroup, PermissionStatus> result =
          await PermissionHandler().requestPermissions(permissionList);

      if (result[permission] == PermissionStatus.granted) {
        var image = await ImagePicker.pickImage(source: source);
        setState(() {
          _image = image;
        });
      }
    } else {
      var image = await ImagePicker.pickImage(source: source);
      setState(() {
        _image = image;
      });
    }
  }

  Future<bool> checkPermission(ImageSource source) async {}

  void showDemoActionSheet({BuildContext context, Widget child}) {
    showCupertinoModalPopup<String>(
      context: context,
      builder: (BuildContext context) => child,
    ).then((String value) {
      if (value != null) {}
    });
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
        _selectDate(context, initialDateTime, onDateTimeChange);
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

  Future<void> _selectDate(BuildContext context, DateTime initialDateTime,
      Function onDateTimeChange) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: initialDateTime,
        firstDate: DateTime(1970, 1),
        lastDate: DateTime(2100));
    if (picked != null) onDateTimeChange(picked);
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
