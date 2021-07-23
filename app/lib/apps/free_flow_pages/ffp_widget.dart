// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:threebotlogin/apps/free_flow_pages/ffp.dart';
// import 'package:threebotlogin/apps/free_flow_pages/ffp_config.dart';
// import 'package:threebotlogin/apps/free_flow_pages/ffp_events.dart';
// import 'package:threebotlogin/browser.dart';
// import 'package:threebotlogin/clipboard_hack/clipboard_hack.dart';
// import 'package:threebotlogin/events/events.dart';
// import 'package:threebotlogin/events/go_home_event.dart';
// import 'package:threebotlogin/services/crypto_service.dart';
// import 'package:threebotlogin/services/user_service.dart';

// class FfpWidget extends StatefulWidget {
//   @override
//   _FfpState createState() => new _FfpState();
// }

// class _FfpState extends State<FfpWidget> with AutomaticKeepAliveClientMixin {
//   InAppWebViewController webView;

//   double progress = 0;
//   FfpConfig config = FfpConfig();
//   bool switchToCircle = false;

//   InAppWebView iaWebview;

//   bool finalDestinationLoading = false;

//   _FfpState() {
//     iaWebview = new InAppWebView(
//       initialUrl: config.cookieUrl(),
//       initialHeaders: {},
//       initialOptions: InAppWebViewGroupOptions(
//         android: AndroidInAppWebViewOptions(supportMultipleWindows: true),
//       ),
//       onLoadStart: (InAppWebViewController controller, String url) {
//         webView = controller;
//         if (url.contains('state')) {
//           controller.stopLoading();
//         }
//         initKeys(url);
//         controller.injectCSSCode(
//             source: ".crisp-client {display: none !important;}");
//       },
//       onLoadStop: (InAppWebViewController controller, String url) async {
//         controller.injectCSSCode(
//             source: ".crisp-client {display: none !important;}");
//         await addClipboardHack(controller);

//         if (switchToCircle && Ffp().firstUrlToLoad != "") {
//           switchToCircle = false;
//           controller.loadUrl(url: Ffp().firstUrlToLoad);
//         }
//       },
//       onCreateWindow:
//           (InAppWebViewController controller, CreateWindowRequest req) {
//         if (req.url.contains("freeflowpages.com/")) {
//           controller.loadUrl(url: req.url);
//           return;
//         }
//         inAppBrowser.openUrl(url: req.url, options: InAppBrowserClassOptions());
//       },
//       onProgressChanged: (InAppWebViewController controller, int progress) {
//         if (!finalDestinationLoading) {
//           finalDestinationLoading = true;
//           controller.getUrl().then((url) {
//             if (Platform.isIOS && url.contains('state')) {
//               controller.stopLoading();
//               initKeys(url);
//             }
//           });
//         }
//       },
//     );

//     Events().onEvent(FfpBrowseEvent().runtimeType, _browseToUrl);
//     Events().onEvent(FfpBackEvent().runtimeType, _browserBack);
//     Events().onEvent(FfpClearCacheEvent().runtimeType, _clearCache);
//   }

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   _clearCache(FfpClearCacheEvent event) async {
//     if (webView != null) {
//       webView.clearCache();
//     }
//   }

//   bool closeNext = false;

//   _browserBack(FfpBackEvent event) async {
//     String url = await webView.getUrl();
//     if (url.endsWith('/dashboard')) {
//       Events().emit(GoHomeEvent());
//     }
//     this.webView.goBack();
//   }

//   _browseToUrl(FfpBrowseEvent event) {
//     if (this.webView != null) {
//       this.webView.loadUrl(url: event.url);
//     }
//   }

//   initKeys(String url) async {
//     if (!url.contains('state') || url.contains('threebot://')) {
//       return;
//     }

//     final state = Uri.decodeFull(url.split("&state=")[1]);
//     final union = '?';
//     final privateKey = await getPrivateKey();

//     final redirecturl =
//         Uri.decodeFull(url.split("&redirecturl=")[1].split("&")[0]);
//     final scope = Uri.decodeFull(url.split("&scope=")[1].split("&")[0]);
//     final publickey = Uri.decodeFull(url.split("&publickey=")[1].split("&")[0]);

//     final scopeData = {};

//     if (scope != null && scope.contains("\"email\":")) {
//       scopeData['email'] = await getEmail();
//       print("adding scope");
//     }

//     var data = (await encrypt(jsonEncode(scopeData), publickey, privateKey));

//     String signedAttempt = json.encode({
//       'signedAttempt': await signData(
//           json.encode({
//             'signedState': state,
//             'data': data,
//             'doubleName': await getDoubleName(),
//           }),
//           await getPrivateKey()),
//       'doubleName': await getDoubleName()
//     });

//     var loadUrl =
//         'https://${config.appId()}$redirecturl${union}signedAttempt=${Uri.encodeQueryComponent(signedAttempt)}';

//     webView.loadUrl(url: loadUrl);
//     switchToCircle = true;
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     if (this.iaWebview == null) {
//       return null;
//     }
//     return Column(
//       children: <Widget>[
//         Expanded(
//           child: Container(child: iaWebview),
//         ),
//       ],
//     );
//   }

//   @override
//   bool get wantKeepAlive => true;
// }
