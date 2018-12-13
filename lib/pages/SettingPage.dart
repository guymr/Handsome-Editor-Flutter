import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  SettingPage() : super();
  final String title = 'Settings';

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  TextEditingController _urlController;
  TextEditingController _cidController;
  TextEditingController _tokenController;
  final FocusNode cidTextFieldNode = FocusNode();
  final FocusNode tokenTextFieldNode = FocusNode();

  @override
  void initState() {
    super.initState();
    List<String> strList = ['url', 'cid', 'token'];
    Future<Map> rst = get(strList);
    rst.then((Map rstList) {
      _urlController = new TextEditingController(text: rstList[strList[0]]);
      _cidController = new TextEditingController(text: rstList[strList[1]]);
      _tokenController = new TextEditingController(text: rstList[strList[2]]);
    });
  }

  Future<Map> get(List<String> strList) async {
    Map rst = new Map();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for(String str in strList){
      rst[str] = prefs.getString(str);
    }
    return rst;
  }

  @override
  Widget build(BuildContext context) {
    save() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('url', _urlController.value.text.toString());
      prefs.setString('cid', _cidController.value.text.toString());
      prefs.setString('token', _tokenController.value.text.toString());
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Builder(builder: (BuildContext context) {
          return Column(
            children: <Widget>[
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(top: 10.0),
                  icon: Icon(Icons.perm_identity),
                  labelText: 'URL',
                ),
                onEditingComplete: () =>
                    FocusScope.of(context).requestFocus(cidTextFieldNode),
              ),
              TextField(
                focusNode: cidTextFieldNode,
                controller: _cidController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(top: 10.0),
                  icon: Icon(Icons.perm_identity),
                  labelText: 'Cid',
                ),
                onEditingComplete: () =>
                    FocusScope.of(context).requestFocus(tokenTextFieldNode),
              ),
              TextField(
                focusNode: tokenTextFieldNode,
                controller: _tokenController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(top: 10.0),
                  icon: Icon(Icons.lock),
                  labelText: 'Token',
                ),
                obscureText: true,
              ),
              RaisedButton(
                  child: Text('保存'),
                  onPressed: () {
                    save();
                    Scaffold.of(context)
                        .showSnackBar(SnackBar(content: Text("数据存储成功")));
                  }),
            ],
          );
        }));
  }
}
