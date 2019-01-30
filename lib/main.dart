import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'model/entity.dart';
import 'package:time_machine/EditRecordPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: '时光机'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _incrementCounter() {
    setState(() {});
  }

  var datas = List.generate(
      10,
      (i) => RecordEntity(
            id: i.toDouble(),
            startTime: DateTime.now().millisecondsSinceEpoch + 86400000 * i,
            endTime: i % 3 == 0
                ? DateTime.now().millisecondsSinceEpoch + 864000000
                : 0,
            isBlank: i == 9 ? true : false,
            hasSelectTime: i % 3 == 0 ? false : true,
            comment: "comment:$i",
          ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: ListView.builder(
          itemBuilder: (context, index) {
            var data = datas[index];
            if (!data.isBlank) {
              if (data.endTime != 0) {
                return _getCountDownItem(data);
              } else {
                return _getCommonItem(data);
              }
            } else {
              return _getBlankItem();
            }
          },
          itemCount: datas.length,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  ///倒计时
  Widget _getCountDownItem(RecordEntity data) {
    return Padding(
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
                      DateTime.fromMillisecondsSinceEpoch(data.startTime)
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
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          Divider(height: 1, color: Colors.white),
                          Text(
                            '已过去xxxx天xx小时',
                            maxLines: 1,
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                        child: Text(
                      DateTime.fromMillisecondsSinceEpoch(data.endTime)
                          .toString()
                          .substring(0, 16),
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    )),
                  ],
                ),
              )
            ],
          ),
        ));
  }

  Widget _getCommonItem(RecordEntity data) {
    String preStr = '';
    int nowTime = DateTime.now().millisecondsSinceEpoch;
    int recordTime = data.startTime;
    if (nowTime < recordTime) {
      preStr = '还有';
    } else {
      preStr = '已过去';
    }
    double timeInSeconds = (nowTime - recordTime).abs() / 1000;
    int day = (timeInSeconds / 86400).round();
    var countDateStr = '';
    if (data.hasSelectTime) {
      int hour = ((timeInSeconds % 86400) / 3600).round();
      countDateStr = '$day天$hour小时';
    } else {
      countDateStr = '$day天';
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => EditRecordPage()));
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
        child: Row(
          //行0
          children: <Widget>[
            Expanded(
                flex: 3,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadiusDirectional.only(
                          topStart: Radius.circular(8),
                          bottomStart: Radius.circular(8))),
                  child: Column(
                    //左边文字
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 10, top: 10),
                        child: Text(
                          //备注文字
                          data.comment,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      _getDateWidget(data),
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
                    children: <Widget>[
                      Text(
                        preStr,
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      Text(
                        countDateStr,
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }

  Widget _getDateWidget(RecordEntity data) {
    String startDateStr =
        DateTime.fromMillisecondsSinceEpoch(data.startTime).toString();
    if (data.hasSelectTime) {
      startDateStr = startDateStr.substring(0, 16);
    } else {
      startDateStr = startDateStr.substring(0, 10);
    }
    if (data.endTime == 0) {
      return _getDateItem(startDateStr);
    } else {
      String endDateStr =
          DateTime.fromMillisecondsSinceEpoch(data.endTime).toString();
      if (data.hasSelectTime) {
        endDateStr = endDateStr.substring(0, 16);
      } else {
        endDateStr = endDateStr.substring(0, 10);
      }
      return Column(
        children: <Widget>[
          _getDateItem('From:$startDateStr'),
          _getDateItem('To:$endDateStr'),
        ],
      );
    }
  }

  Widget _getDateItem(String dateStr) {
    return Container(
      margin: EdgeInsets.only(left: 10, bottom: 10),
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
