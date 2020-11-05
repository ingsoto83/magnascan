import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:intl/intl.dart';

typedef void ScanCallback(String lote, String scan);

class ScanPage extends StatefulWidget {
  final ScanCallback callback;

  const ScanPage({Key key, this.callback}) : super(key: key);

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
    final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
    var qrText = "";
    RegExp _numeric = RegExp(r'^-?[0-9]+$');//solo numeros

    QRViewController controller;

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                children: [
                 QRView(
                      key: qrKey,
                      overlay: QrScannerOverlayShape(
                          borderColor: Colors.red,
                          borderRadius: 10,
                          borderLength: 30,
                          borderWidth: 10,
                          cutOutSize: 300,
                          overlayColor: Colors.black87
                      ),
                      onQRViewCreated: (QRViewController controller) {
                        this.controller = controller;
                        controller.scannedDataStream.listen((scanData) {
                          if(scanData.length<10){
                            print('¡Código incorrecto <10!');
                          }else if(scanData.length>10){
                            if(scanData.toUpperCase().startsWith('1J')){
                              String code = scanData.substring(13);
                              NumberFormat formatter = new NumberFormat("0000000000");
                              code = formatter.format(int.parse(code));
                              widget.callback(code,scanData);
                              Navigator.of(context)
                                  .popUntil(ModalRoute.withName("/"));
                            }else{
                              print('¡Código incorrecto no IJ!');
                            }
                          }else if(isNumeric(scanData)){
                            if(scanData.startsWith('55')){
                              print('¡Código incorrecto 55!');
                            }else{
                              widget.callback(scanData,scanData);
                              Navigator.of(context)
                                  .popUntil(ModalRoute.withName("/"));
                            }
                          }else{
                            print('¡Código incorrecto! NAN');
                          }
                        });
                      }
                  ),
                 Positioned(
                      top: 50.0,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 100,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('assets/img/logo_trans.png')
                            )
                        ),
                      )
                  ),
                ],
              )
            ),
          ],
        ),
      );
    }

    bool isNumeric(String str) {
      return _numeric.hasMatch(str);
    }

    @override
    void dispose() {
      controller?.dispose();
      super.dispose();
    }
}


