import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class MyInAppBrowser extends InAppBrowser {
  @override
  void onLoadStart(Uri url) {
    super.onLoadStart(url);
    print("\n\nStarted $url\n\n");
  }

  @override
  void onLoadStop(Uri url) {
    super.onLoadStop(url);
    print("\n\nStopped $url\n\n");
  }

  // @override
  // void onLoadError(String url, String code, String message) {
  //   super.onLoadStop(url);
  //   print("\n\nCan't load $url.. Error: $message\n\n");
  // }

  @override
  void onExit() {
    super.onExit();
    print("\n\nBrowser closed!\n\n");
  }
}

MyInAppBrowser inAppBrowser = new MyInAppBrowser();
