import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:threebotlogin/app_config.dart';
import 'package:threebotlogin/services/user_service.dart';

class InitScreen extends StatefulWidget {
  InitScreen();

  @override
  _InitState createState() => _InitState();
}

class _InitState extends State<InitScreen> {
  InAppWebViewController webView;

  InAppWebView iaWebView;

  finish(List<dynamic> params) async {
    print("**** LOAD DONE ");
    saveInitDone();
    Navigator.pop(context, true);
  }

  addHandler() {
    webView.addJavaScriptHandler(handlerName: "FINISH", callback: finish);
  }

  _InitState() {
    iaWebView = InAppWebView(
      initialUrlRequest: URLRequest(url:Uri.parse(AppConfig().wizardUrl() + '?cache_buster=' + new DateTime.now().millisecondsSinceEpoch.toString())),

      initialOptions: InAppWebViewGroupOptions(
        android: AndroidInAppWebViewOptions(supportMultipleWindows: true),
      ),
      onWebViewCreated: (InAppWebViewController controller) {
        webView = controller;
        addHandler();
      },
      onCreateWindow:
          (InAppWebViewController controller, CreateWindowAction req) {},
      onLoadStart: (InAppWebViewController controller, Uri url) {},
      onLoadStop: (InAppWebViewController controller, Uri url) async {},
      onProgressChanged: (InAppWebViewController controller, int progress) {},
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(child: iaWebView),
    );
  }
}
