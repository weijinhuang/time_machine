import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'model/entity.dart';
import 'package:time_machine/EditRecordPage.dart';
import 'package:flutter/cupertino.dart';

void main() => runApp(MyApp());

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

  _MyHomePageState() {
//    getMyHomePageState();
  }

  getMyHomePageState() {
//    var recordEntityProvider = RecordEntityProvider();
//    recordEntityProvider.open();
//    recordEntityProvider.getAll().then((results) {
//      setState(() {
//        datas = results;
//        datas.add(RecordEntity(isBlank: true));
//      });
//    });
//    recordEntityProvider.close();
  }

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

  void _toEditPage({RecordEntity data}) async {
    RecordEntity result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditRecordPage(
                  data: data,
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        color: Colors.transparent,
        child: ListView.builder(
          itemBuilder: (context, index) {
            var data = datas[index];
            if (!data.isBlank) {
              return _getCommonItem(data);
            } else {
              return _getBlankItem();
            }
          },
          itemCount: datas.length,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toEditPage,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  ///倒计时
  Widget _getCountDownItem(RecordEntity data) {
    return GestureDetector(
      onTap: () {
        _toEditPage(data: data);
      },
      child: Padding(
          padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                color: Colors.blue),
            child: Column(
              children: <Widget>[
                Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Text(data.comment, //备注文字
                        maxLines: 1,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          color: Colors.white,
                        ))),
                Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                          child: Text(
                        DateTime.fromMillisecondsSinceEpoch(data.startDateTime)
                            .toString()
                            .substring(0, 16),
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      )),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'xx天xx小时',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            Divider(height: 1, color: Colors.white),
                            Text(
                              '已过去xxxx天xx小时',
                              maxLines: 1,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                          child: Text(
                        DateTime.fromMillisecondsSinceEpoch(data.endDateTime)
                            .toString()
                            .substring(0, 16),
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      )),
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }

  Widget _getCommonItem(RecordEntity data) {
//    String preStr = '';
//    int nowTime = DateTime.now().millisecondsSinceEpoch;
//    int recordTime = data.startDateTime;
//    if (nowTime < recordTime) {
//      preStr = '还有';
//    } else {
//      preStr = '已过去';
//    }
//    double timeInSeconds = (nowTime - recordTime).abs() / 1000;
//    int day = (timeInSeconds / 86400).round();
//    var countDateStr = '';
//    if (data.hasSelectTime) {
//      int hour = ((timeInSeconds % 86400) / 3600).round();
//      countDateStr = '$day天$hour小时';
//    } else {
//      countDateStr = '$day天';
//    }

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
        margin: EdgeInsets.only(left: 10, top: 10, right: 10),
        
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
                          topStart: Radius.circular(8),
                          bottomStart: Radius.circular(8))),
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
                          bottomRight: Radius.circular(8),
                          topRight: Radius.circular(8))),
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
      if (data.hasSelectTime) {
        int hour = ((timeInSeconds % 86400) / 3600).round();
        countDateStr = '$day天$hour小时';
      } else {
        countDateStr = '$day天';
      }
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
      if (data.hasSelectTime) {
        int hour = ((timeInSeconds2 % 86400) / 3600).round();
        countDateStr2 = '$day天$hour小时';
      } else {
        countDateStr2 = '$day天';
      }
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
    if (data.hasSelectTime) {
      startDateStr = startDateStr.substring(0, 16);
    } else {
      startDateStr = startDateStr.substring(0, 10);
    }
    if (data.endDateTime == null || data.endDateTime < 0) {
      return _getDateItem('开始:$startDateStr');
    } else {
      String endDateStr =
          DateTime.fromMillisecondsSinceEpoch(data.endDateTime).toString();
      if (data.hasSelectTime) {
        endDateStr = endDateStr.substring(0, 16);
      } else {
        endDateStr = endDateStr.substring(0, 10);
      }
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
