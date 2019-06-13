import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class TestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => TestState();
}

class TestState extends StatefulWidget {
  @override
  State createState() => _TestState();
}

class _TestState extends State<TestState> {
  void testAwait() async {
    var stringAsync = await getStringAsync();
    print(stringAsync);
    print("ssss");
    int i = 0;
    while (i < 200000) {
      i++;
    }
    print(stringAsync + "2");
  }

  Future<String> getStringAsync() async {
    int i = 0;
    while (i < 10000000) {
      i++;
    }
    return i.toString();
  }

  @override
  Widget build(BuildContext context) {
    Map map = <String, Function>{
      "test_await": () {
        print("text_await onclick");
        testAwait();
      }
    };
    var list = map.keys.toList(growable: false);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('测试页面'),
      ),
      child: SafeArea(
          child: Center(
        child: ListView.builder(
          itemBuilder: (context, index) =>
              getItem(list[index], map[list[index]]),
          itemCount: map.length,
        ),
      )),
    );
  }

  Widget getItem(String title, Function onClick) => Padding(
        padding: EdgeInsets.all(12),
        child: CupertinoButton.filled(child: Text(title), onPressed: onClick),
      );
}
