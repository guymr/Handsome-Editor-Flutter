import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './SettingPage.dart';

class HomePage extends StatefulWidget {
  HomePage() : super();

  final String title = 'Handsome Editor';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _textController = new TextEditingController();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        drawer: Drawer(
            child: ListView(children: <Widget>[
          ListTile(
              title: Text('发布'),
              trailing: Icon(Icons.arrow_upward),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) =>
                        HomePage()));
              }),
          ListTile(
              title: Text('设置'),
              trailing: Icon(Icons.settings),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => SettingPage()));
              })
        ])),
        body: Builder(builder: (BuildContext context) {

          Future<Map> get(List<String> strList) async {
            Map rst = new Map();
            SharedPreferences prefs = await SharedPreferences.getInstance();
            for (String str in strList) {
              rst[str] = prefs.getString(str);
            }
            return rst;
          }

          String toMd5(String data) {
            var content = new Utf8Encoder().convert(data);
            var digest = md5.convert(content);
            return hex.encode(digest.bytes);
          }

          send() async {
            String url, cid, token;
            List<String> strList = ['url', 'cid', 'token'];
            Future<Map> rst = get(strList);
            rst.then((Map rstList) {
              url = rstList[strList[0]];
              cid = rstList[strList[1]];
              token = rstList[strList[2]];
              Dio dio = new Dio();
              FormData formData = new FormData.from({
                'action': 'send_talk',
                'content': _textController.value.text.toString(),
                'cid': cid,
                'token': token,
                'time_code': toMd5(token)
              });
              Future<Response> response = dio.post(url, data: formData);
              response.then((Response response) {
                var data = response.data.toString();
                print(data);
                if (data == '1') {
                  _textController.clear();
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text("发送成功")));
                } else
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text("发送失败")));
              },onError: (e) {
                Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text("发送失败")));
              });
            });
          }

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: <Widget>[
                Flexible(
                  child:TextField(
                    controller: _textController,
                    decoration: InputDecoration.collapsed(
                        hintText: "说点什么吧"
                    ),
                  )
                ),
                Container(
                  margin:new EdgeInsets.symmetric(horizontal: 4.0),
                  child: new IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () => send(),
                  )
                )
              ])
          );
        }));
  }
}
