import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:threebotlogin/Apps/Wallet/walletUserData.dart';

import 'package:threebotlogin/services/cryptoService.dart';
import 'package:threebotlogin/services/toolsService.dart';
import 'package:threebotlogin/services/userService.dart';
import 'config.dart';
/*
Future main() async {
  runApp(new WalletWidget());
}*/

class WalletWidget extends StatefulWidget {
  @override
  _WalletState createState() => new _WalletState();
}

class _WalletState extends State<WalletWidget> {
  InAppWebViewController webView;
  String url = "";
  double progress = 0;
  var config = WalletConfig().config();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }



  initKeys() async {
    final union = '?';

    var keys = await generateKeyPair();

    final state = randomString(15);

    final privateKey = await getPrivateKey();
    final signedHash = await signData(state, privateKey);

    var jsToExecute =
        "(function() { try {window.localStorage.setItem('tempKeys', \'{\"privateKey\": \"${keys["privateKey"]}\", \"publicKey\": \"${keys["publicKey"]}\"}\');  window.localStorage.setItem('state', '$state'); } catch (err) { return err; } })();";

    webView.evaluateJavascript(source: jsToExecute);

    var scope = {};
    scope['doubleName'] = await getDoubleName();
    scope['derivedSeed'] = await getDerivedSeed(config['appId']);
    var encrypted =
        await encrypt(jsonEncode(scope), keys["publicKey"], privateKey);
    var jsonData = jsonEncode(encrypted);
    var data = Uri.encodeQueryComponent(jsonData); //Uri.encodeFull();

    var loadUrl =
        'https://${config.appId}${config.redirectUrl}${union}username=${await getDoubleName()}&signedhash=${Uri.encodeQueryComponent(signedHash)}&data=$data';


    webView.loadUrl(url: loadUrl);
  }



  addHandler() {
    webView.addJavaScriptHandler(handlerName: "ADD_IMPORT_WALLET", callback: saveImportedWallet);
    webView.addJavaScriptHandler(handlerName: "ADD_APP_WALLET", callback: saveAppWallet);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: new Scaffold(
        body: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                child: InAppWebView(
                  initialUrl: "http://192.168.2.90:8080/handlertest.html?test=3",
                  initialHeaders: {},
                  initialOptions: InAppWebViewWidgetOptions(),
                  onWebViewCreated: (InAppWebViewController controller) {
                    webView = controller;
                    this.addHandler();
                    //initKeys();
                  },
                  onLoadStart: (InAppWebViewController controller, String url) {
                    setState(() {
                      this.url = url;
                    });
                  },
                  onLoadStop:
                      (InAppWebViewController controller, String url) async {
                    setState(() {
                      this.url = url;
                    });
                  },
                  onProgressChanged:
                      (InAppWebViewController controller, int progress) {
                    setState(() {
                      this.progress = progress / 100;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
