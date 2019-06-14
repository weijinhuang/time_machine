import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:time_machine/EditRecordPage.dart';
import 'dart:io';
import 'model/entity.dart';
import 'test.dart';

void main() => runApp(MyApp());

const TIME_RECORD = "time_record";
const TIME_JOURNEY = 'time_journey';

class MyApp extends StatelessWidget {
  static const int _greyPrimaryValue = 0xFF333333;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: MaterialColor(
          _greyPrimaryValue,
          <int, Color>{
            50: Color(0xFFFAFAFA),
            100: Color(0xFFF5F5F5),
            200: Color(0xFFEEEEEE),
            300: Color(0xFFE0E0E0),
            350: Color(0xFFD6D6D6),
            // only for raised button while pressed in light theme
            400: Color(0xFFBDBDBD),
            500: Color(_greyPrimaryValue),
            600: Color(0xFF757575),
            700: Color(0xFF616161),
            800: Color(0xFF424242),
            850: Color(0xFF303030),
            // only for background color in dark theme
            900: Color(0xFF212121),
          },
        ),
      ),
      home: MyHomePage(title: '时光机'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  List<RecordEntity> datas = List();
  GlobalKey floatButtonKey = GlobalKey();
  double screenWidth;

  @override
  void initState() {
    super.initState();
    RecordEntityProvider().open().then((db) {
      db.getAll().then((data) {
        setState(() {
          datas.addAll(data);
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    RecordEntityProvider().open().then((db) {
      db.close();
    });
  }

  void _toEditPage({RecordEntity data, String recordType}) async {
    RecordEntity result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditRecordPage(
                  data: data,
                  recordType: recordType,
                )));
    if (null != result) {
      for (RecordEntity e in datas) {
        if (e.recordId == result.recordId) {
          setState(() {
            RecordEntityProvider().open().then((db) {
              db.update(result);
            });
          });
          return;
        }
      }
      setState(() {
        datas.add(result);
        RecordEntityProvider().open().then((db) {
          db.insert(result);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var of = MediaQuery.of(context);
    screenWidth = of.size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          Center(
            heightFactor: 1,
            child: GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TestPage()));
              },
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 0, top: 0, right: 10, bottom: 0),
                child: Text(
                  "Test",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Container(
          color: Colors.transparent,
          child: ListView.builder(
            itemBuilder: (context, index) {
              var data = datas[index];
//            if (!data.isBlank) {
              return _getCommonItem1(data);
//            } else {
//            return _getBlankItem();
//            }
            },
            itemCount: datas.length,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.orange,
          child: const Icon(Icons.add),
          key: floatButtonKey,
          onPressed: (() {
            final RenderBox button =
                floatButtonKey.currentContext.findRenderObject();
            final RenderBox overlay =
                Overlay.of(context).context.findRenderObject();
            final RelativeRect position = RelativeRect.fromRect(
              Rect.fromPoints(
                button.localToGlobal(Offset.zero, ancestor: overlay),
                button.localToGlobal(button.size.bottomRight(Offset.zero),
                    ancestor: overlay),
              ),
              Offset.zero & overlay.size,
            );
            showMenu(context: context, position: position, items: [
              const PopupMenuItem<String>(
                  value: TIME_RECORD,
                  child: ListTile(
                      leading: Icon(Icons.visibility), title: Text('时光记录'))),
              const PopupMenuItem<String>(
                  value: TIME_JOURNEY,
                  child: ListTile(
                      leading: Icon(Icons.person_add), title: Text('时间旅程'))),
            ]).then<void>((String newValue) {
              if (!mounted) return null;
              if (newValue == null) {
                return null;
              }
              if (newValue == TIME_JOURNEY) {
                _toEditPage(recordType: TIME_JOURNEY);
              } else if (newValue == TIME_RECORD) {
                _toEditPage(recordType: TIME_RECORD);
              }
            });
          })),
    );
  }

  ///时间旅程
  Widget _getTimeJourneyItem(RecordEntity data) {
    return GestureDetector(
        onTap: () {
          _toEditPage(data: data);
        },
        onLongPress: () {
          showDialog(
              context: context,
              builder: (BuildContext context) => CupertinoAlertDialog(
                    title: const Text("是否删除此项目"),
                    content: Text(data.comment),
                    actions: <Widget>[
                      CupertinoDialogAction(
                        child: const Text('删除'),
                        onPressed: () {
                          setState(() {
                            Navigator.pop(context, '已删除');
                            datas.remove(data);
                            RecordEntityProvider().open().then((db) {
                              db.delete(data.recordId);
                            });
                          });
                        },
                      ),
                      CupertinoDialogAction(
                        child: const Text('取消'),
                        onPressed: () {
                          Navigator.pop(context, '');
                        },
                      ),
                    ],
                  ));
        },
        child: Card(elevation: 10));
  }

  List<Widget> _getChildren(RecordEntity data) {
    List<Widget> list = List();
    ThemeData theme = Theme.of(context);
    TextStyle titleTextStyle =
        theme.textTheme.title.copyWith(color: Color.fromARGB(0xff, 0x55, 0x55, 0x55));
    TextStyle contentTextStyle =
        theme.textTheme.body2;
    if (data.image != null && data.image != '') {
      Image image = Image.file(
        File(data.image),

        height: (screenWidth - 50) * 2 / 3,
        fit: BoxFit.cover,
      );
      list.add(image);
    }
    if (null != data.title && data.title.isNotEmpty) {
      Text title = Text(
        data.title,
        textAlign: TextAlign.left,
        style: titleTextStyle,
      );
      Padding padding = Padding(padding: EdgeInsets.all(8), child: title);
      list.add(padding);
    }
    if (null != data.comment && data.comment.isNotEmpty) {
      Text content = Text(data.comment, style: contentTextStyle);
      Padding padding = Padding(padding: EdgeInsets.all(8), child: content);
      list.add(padding);
    }
    Widget getStartTimeItem(String str) => Padding(
        padding: EdgeInsets.only(left: 8, bottom: 8),
        child: Text(
          str,
          style: TextStyle(color: Colors.black45, fontSize: 12),
        ));

    if (null != data.endDateTime && data.endDateTime > 0) {
      list.add(Row(
        children: <Widget>[
          getStartTimeItem(
              DateTime.fromMillisecondsSinceEpoch(data.startDateTime)
                  .toString()
                  .substring(0, 10)),
          getStartTimeItem("—>"),
          getStartTimeItem(DateTime.fromMillisecondsSinceEpoch(data.endDateTime)
              .toString()
              .substring(0, 10))
        ],
      ));
    } else {
      list.add(getStartTimeItem(
          DateTime.fromMillisecondsSinceEpoch(data.startDateTime)
              .toString()
              .substring(0, 10)));
    }
    return list;
  }

  Widget _getCommonItem1(RecordEntity data) {
    return Padding(
      padding: const EdgeInsets.only(left: 8,top: 8,right: 8),
      child: GestureDetector(
        onTap: () {
          _toEditPage(data: data);
        },
        child: Card(
          elevation: 10,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: _getChildren(data),
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ),
      ),
    );
  }

  Widget _getCommonItem(RecordEntity data) {
    return GestureDetector(
      onTap: () {
        _toEditPage(data: data);
      },
      onLongPress: () {
        showDialog(
            context: context,
            builder: (BuildContext context) => CupertinoAlertDialog(
                  title: const Text("是否删除此项目"),
                  content: Text(data.comment),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      child: const Text('删除'),
                      onPressed: () {
                        setState(() {
                          Navigator.pop(context, '已删除');
                          datas.remove(data);
                          RecordEntityProvider().open().then((db) {
                            db.delete(data.recordId);
                          });
                        });
                      },
                    ),
                    CupertinoDialogAction(
                      child: const Text('取消'),
                      onPressed: () {
                        Navigator.pop(context, '');
                      },
                    ),
                  ],
                ));
      },
      child: Card(
        margin: EdgeInsets.only(left: 8, top: 8, right: 8),
        elevation: 10,
        child: Row(
          //行0
          children: <Widget>[
            Expanded(
                flex: 3,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                      color: Color(0xee333333),
                      borderRadius: BorderRadiusDirectional.only(
                          topStart: Radius.circular(4),
                          bottomStart: Radius.circular(4))),
                  child: Column(
                    //左边文字
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 10, top: 1),
                        child: Text(
                          //备注文字
                          data.comment,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      _getLeftDateWidget(data),
                      //时间
                    ],
                  ),
                )),
            Expanded(
                flex: 2,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(4),
                          topRight: Radius.circular(4))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _getRightText(data),
                  ),
                ))
          ],
        ),
      ),
    );
  }

  List<Widget> _getRightText(RecordEntity data) {
    List<Widget> list = List();
    int nowTime = DateTime.now().millisecondsSinceEpoch;
    if (data.startDateTime > 0) {
      String preStr1 = '';
      int recordStartTime = data.startDateTime;
      if (nowTime < recordStartTime) {
        preStr1 = '距离开始还有';
      } else {
        preStr1 = '已开始';
      }
      double timeInSeconds = (nowTime - recordStartTime).abs() / 1000;
      int day = (timeInSeconds / 86400).round();
      var countDateStr = '';
      countDateStr = '$day天';
      Text text1Pre = Text(
        preStr1,
        style: TextStyle(color: Colors.white, fontSize: 14),
      );
      Text text1 = Text(
        countDateStr,
        style: TextStyle(color: Colors.white, fontSize: 14),
      );
      list.add(text1Pre);
      list.add(text1);
    }
    if (data.endDateTime != null && data.endDateTime > 0) {
      String pre2;
      if (nowTime < data.endDateTime) {
        pre2 = '距离结束还有';
      } else {
        pre2 = '已结束';
      }
      double timeInSeconds2 = (nowTime - data.endDateTime).abs() / 1000;
      int day = (timeInSeconds2 / 86400).round();
      String countDateStr2 = '';
      countDateStr2 = '$day天';
      Text text2Pre = Text(
        pre2,
        style: TextStyle(color: Colors.white, fontSize: 14),
      );
      Text text2 = Text(
        countDateStr2,
        style: TextStyle(color: Colors.white, fontSize: 14),
      );
      list.add(Container(
        margin: EdgeInsets.only(left: 10, right: 10),
        color: Colors.white70,
        height: 1,
      ));
      list.add(text2Pre);
      list.add(text2);
    }
    return list;
  }

  Widget _getLeftDateWidget(RecordEntity data) {
    String startDateStr =
        DateTime.fromMillisecondsSinceEpoch(data.startDateTime).toString();
    startDateStr = startDateStr.substring(0, 10);
    if (data.endDateTime == null || data.endDateTime < 0) {
      return _getDateItem('开始:$startDateStr');
    } else {
      String endDateStr =
          DateTime.fromMillisecondsSinceEpoch(data.endDateTime).toString();
      endDateStr = endDateStr.substring(0, 10);
      return Column(
        children: <Widget>[
          _getDateItem('开始:$startDateStr'),
          _getDateItem('结束:$endDateStr'),
        ],
      );
    }
  }

  Widget _getDateItem(String dateStr) {
    return Container(
      margin: EdgeInsets.only(left: 10, bottom: 1),
      child: Text(
        //时间文字
        dateStr,
        textAlign: TextAlign.start,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _getBlankItem() => Container(
        height: 80,
        child: Text(''),
      );
}
