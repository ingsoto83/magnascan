import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/record_database_provider.dart';

class ConfigPage extends StatefulWidget {
  final VoidCallback onUpdateSettings;

  const ConfigPage({Key key, this.onUpdateSettings}) : super(key: key);

  @override
  _ConfigPageState createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var _formKey = GlobalKey<FormState>();
  TextEditingController _urlController = new TextEditingController();
  String _url = "";

  readSPUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _urlController.value = TextEditingValue(
      text: prefs.getString('url_ws'),
      selection: TextSelection.fromPosition(
        TextPosition(offset: prefs.getString('url_ws').length),
      ),
    );
    setState(() {

    });
  }
  saveSPUrl(String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('url_ws', url);
    setState(() {

    });
  }
  @override
  void initState() {
    super.initState();
    readSPUrl();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Container(
          width: MediaQuery.of(context).size.width,
          height: 50,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/img/logo.png'),
                  fit: BoxFit.fitHeight)),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20),
              child: TextFormField(

                controller: _urlController,
                validator: (value)=> (value.isEmpty ) ? "Url es obligatoria!": null,
                onSaved: (value) => _url = value,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.miscellaneous_services_sharp),
                  labelText: "URL Web Service",
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.elliptical(20, 20)),
                    gapPadding: 10.0,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Container(
                height: 50.0,
                child: RaisedButton(
                  elevation: 8.0,
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    saveUrl();
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
                  padding: EdgeInsets.all(0.0),
                  child: Ink(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.red[600], Colors.red[900]],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(30.0)
                    ),
                    child: Container(
                      constraints: BoxConstraints( minHeight: 50.0),
                      alignment: Alignment.center,
                      child: Text(
                        "Guardar URL",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top:80.0),
              child: Divider(
                height: 10.0,
                color: Colors.black54,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
              child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Registros en base de datos: ",
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
              child:FutureBuilder<int>(
                  future: RecordDatabaseProvider.db.getAllRecords(),
                  builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                    return Align(
                      alignment: Alignment.center,
                      child: Text(
                        "${snapshot.data}",
                        style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 36),
                      ),
                    );
                  }),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 30),
              child: Container(
                height: 50.0,
                child: RaisedButton(
                  elevation: 8.0,
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    if(Platform.isIOS){
                      showCupertinoDialog(context: context, builder: (_) => _buildCupertinoAlertDialog());
                    }else{
                      showDialog(context: context, builder: (_) => _buildAlertDialog());
                    }
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
                  padding: EdgeInsets.all(0.0),
                  child: Ink(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.red[600], Colors.red[900]],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(30.0)
                    ),
                    child: Container(
                      constraints: BoxConstraints( minHeight: 50.0),
                      alignment: Alignment.center,
                      child: Text(
                        "Eliminar historial",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAlertDialog(){
    return AlertDialog(
      title: Text('Eliminar Historial'),
      content:
      Text("¿Esta seguro que desea eliminar el historial?"),
      actions: [
        FlatButton(
            child: Text("Sí, Eliminar"),
            textColor: Colors.blue,
            onPressed: () {
              Navigator.of(context).pop();
              clearDatabase();
            }),

        FlatButton(
            child: Text("Cancelar"),
            textColor: Colors.red,
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ],
    );
  }

  Widget _buildCupertinoAlertDialog() {
      return CupertinoAlertDialog(
        title: Text('Eliminar Historial'),
        content:
        Text("¿Esta seguro que desea eliminar el historial?"),
        actions: [
          FlatButton(
              child: Text("Sí, Eliminar"),
              textColor: Colors.blue,
              onPressed: () {
                Navigator.of(context).pop();
                clearDatabase();
              }),

          FlatButton(
              child: Text("Cancelar"),
              textColor: Colors.red,
              onPressed: () {
                Navigator.of(context).pop();
              }),
        ],
      );
  }

  void clearDatabase() {
    RecordDatabaseProvider.db.deleteAllRecords();
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('OK!, Historial eliminado!'),
          duration: Duration(seconds: 3),
        )
    );
    widget.onUpdateSettings();
  }

  void saveUrl() async{
    final form = _formKey.currentState;
    if(!form.validate()){return;}
    form.save();
    await saveSPUrl(_url);
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('OK!, Url actualizada correctamente!'),
          duration: Duration(seconds: 3),
        )
    );
    widget.onUpdateSettings();
  }
}
