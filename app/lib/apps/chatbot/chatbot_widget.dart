import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:threebotlogin/apps/chatbot/chatbot_config.dart';
import 'package:threebotlogin/browser.dart';
import 'package:threebotlogin/clipboard_hack/clipboard_hack.dart';
import 'package:threebotlogin/widgets/layout_drawer.dart';

class ChatbotWidget extends StatefulWidget {
  final String email;

  ChatbotWidget({this.email});

  @override
  _ChatbotState createState() => new _ChatbotState(email: this.email);
}

class _ChatbotState extends State<ChatbotWidget>
    with AutomaticKeepAliveClientMixin {
  InAppWebViewController webView;

  ChatbotConfig config = ChatbotConfig();
  InAppWebView iaWebview;
  final String email;

  _ChatbotState({this.email}) {
    iaWebview = InAppWebView(
      initialUrlRequest: URLRequest(url:Uri.parse('${config.url()}$email&cache_buster=' +
          new DateTime.now().millisecondsSinceEpoch.toString())),

      initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(useShouldOverrideUrlLoading: true),
          android: AndroidInAppWebViewOptions(supportMultipleWindows: true)),
      onWebViewCreated: (InAppWebViewController controller) {
        webView = controller;
      },
      onCreateWindow:
           (InAppWebViewController controller, CreateWindowAction req) {

        inAppBrowser.openUrlRequest(urlRequest: req.request, options: InAppBrowserClassOptions());

      },
      onConsoleMessage:
          (InAppWebViewController controller, ConsoleMessage consoleMessage) {
        print("CB console: " + consoleMessage.message);
      },
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
    super.build(context);
    return LayoutDrawer(titleText: 'Support', content: Column(
      children: <Widget>[
        Expanded(
          child: Container(child: iaWebview),
        ),
      ],
    ));
  }

  @override
  bool get wantKeepAlive => true;
}
