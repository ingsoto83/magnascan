import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inventario_magna/config_page.dart';
import 'package:inventario_magna/data/record.dart';
import 'package:inventario_magna/scan_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/record_database_provider.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String _lote = "";
  String _loteOriginal = "";
  String _cantidad = "";
  String _url="";
  DateFormat formatterLocal = DateFormat('yyyyMMdd');
  DateFormat formatterApi = DateFormat('yyyy-MM-dd hh:mm:ss');
  DateFormat formatterTime = new DateFormat.jm();

  var _formKey = GlobalKey<FormState>();
  bool capture = false;

  @override
  void initState() {
    super.initState();
    readSPUrl();
  }

    readSPUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    _url = prefs.getString('url_ws');
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String today = formatterLocal.format(now);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Container(
          width: MediaQuery.of(context).size.width,
          height:50,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/img/logo.png'),
              fit: BoxFit.fitHeight
            )
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: capture? Colors.blueGrey : Colors.red,
        child: capture? Icon(Icons.cancel):  Icon(Icons.add),
        foregroundColor: Colors.white,
        onPressed: (){
          if(_url!=null) {
            if (!capture) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  settings: RouteSettings(name: "/ScanPage"),
                  builder: (context) => ScanPage(callback: scanResult,),
                ),
              );
            } else {
              capture = false;
              _cantidad = "";
              _loteOriginal = "";
              _lote = "";
              setState(() {

              });
            }
          }
        },
      ),
      bottomNavigationBar: new BottomAppBar(
        shape: CircularNotchedRectangle(),
        color: Colors.white,
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            new Expanded(child: new SizedBox()),
            IconButton(
              icon: Icon(
                Icons.settings,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    settings: RouteSettings(name: "/ConfigPage"),
                    builder: (context) => ConfigPage(onUpdateSettings: updateSettings,),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: !capture ? Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 32.0, top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Text(
                  "Hoy",
                  style: Theme.of(context).textTheme.headline,
                ),
              ],
            ),
          ),
          Expanded(
            //padding: const EdgeInsets.only(top: 16.0),
            child: _url!=null ? Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: FutureBuilder<List<Record>>(
                future: RecordDatabaseProvider.db.getAllRecordsWithDate(today),
                builder: (BuildContext context, AsyncSnapshot<List<Record>> snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        Record item = snapshot.data[index];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Card(
                            color: Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            child: ListTile(
                              leading: Icon(
                                Icons.qr_code,
                                color: Theme.of(context).iconTheme.color,
                              ),
                              title: Text(
                                "Lote: ${item.codigo}",
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Cantidad: ${item.quantity}",
                                    style: Theme.of(context).textTheme.bodyText2,
                                  ),
                                  Text(
                                    item.time,
                                    style: Theme.of(context).textTheme.bodyText2,
                                  ),
                                ],
                              ),
                              trailing: Icon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ) : Center(child:Text(
              "Url de webservice no configurada!, vaya a configuración!",
              style: Theme.of(context).textTheme.bodyText2,
              textAlign: TextAlign.center,
            ),)
          ),
        ],
      ):Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20),
              child: TextFormField(
                enabled: false,
                initialValue: _loteOriginal,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email),
                  labelText: "Cadena original",
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.elliptical(20, 20)),
                    gapPadding: 10.0,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                enabled: false,
                initialValue: _lote,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock_open),
                  isDense: true,
                  labelText: "Lote",
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.elliptical(20, 20)),
                    gapPadding: 10.0,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                validator: (value)=> (value.isEmpty ) ? "Cantidad es obligatoria!": null,
                onSaved: (value) => _cantidad = value,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock_open),
                  isDense: true,
                  labelText: "Cantidad",
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
                    sendData();
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
                        "Enviar",
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

  void scanResult(String lote, String scan){
    _lote = lote;
    _loteOriginal = scan;
    capture= true;
    setState(() {

    });
  }

  void updateSettings() async{
    readSPUrl();
  }

  Future<String> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) { // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }

  void sendData() async{
    final form = _formKey.currentState;
    if(!form.validate()){return;}
    form.save();
    DateTime now = DateTime.now();
    String date = formatterLocal.format(now);
    String dateApi = formatterApi.format(now);
    String time = formatterTime.format(now);
    String user = await _getId();
    var map = new Map<String, dynamic>();
    map['cadena_original'] = _loteOriginal;
    map['lote'] = _lote;
    map['fecha_escaneo'] = dateApi;
    map['cantidad'] = _cantidad;
    map['dispositivo_id'] = user;
    print(map);
    try {
      http.Response response = await http.post(_url, body: map,headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      });
      if(response.statusCode==200){
        capture= false;
        _scaffoldKey.currentState.showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text('OK!, Registro guardado correctamente!'),
              duration: Duration(seconds: 3),
            )
        );
        setState(() {
          RecordDatabaseProvider.db.addRecordToDatabase(new Record(
              codigo: _lote,
              codigo_original: _loteOriginal,
              date: date,
              time: time,
              user: user,
              quantity: int.parse(_cantidad)
          ));
        });
      }else{
        print(response.reasonPhrase);
        print(response.request);
        captureOff();
        _scaffoldKey.currentState.showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text('Error al procesar la petición!'),
              duration: Duration(seconds: 5),
            )
        );
      }
    } on SocketException {
      captureOff();
      _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Error!, Servidor no encontrado!'),
            duration: Duration(seconds: 5),
          )
      );
    }
  }

  void captureOff(){
    capture=false;
    setState(() {

    });
  }

}
