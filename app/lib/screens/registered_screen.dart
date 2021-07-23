import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/helpers/vpn_state.dart';
import 'package:threebotlogin/services/user_service.dart';
import 'package:threebotlogin/widgets/layout_drawer.dart';
import 'package:yggdrasil_plugin/yggdrasil_plugin.dart';
import 'package:flutter/services.dart';

class RegisteredScreen extends StatefulWidget {
  static final RegisteredScreen _singleton = new RegisteredScreen._internal();

  factory RegisteredScreen() {
    return _singleton;
  }

  RegisteredScreen._internal() {
    //init
  }

  _RegisteredScreenState createState() => _RegisteredScreenState();
}

class _RegisteredScreenState extends State<RegisteredScreen>
    with WidgetsBindingObserver {
  // We will treat this error as a singleton

  bool showSettings = false;
  bool showPreference = false;

  @override
  Widget build(BuildContext context) {
    return LayoutDrawer(titleText: 'Home', content:
     Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        SizedBox(height: 10.0),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 360.0,
              height: 108.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.fill, image: AssetImage('assets/logo.png')),
              ),
            ),
            SizedBox(height: 80),
            Container(
              width: 200.0,
              height: 200.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/threefold_registered.png')),
              ),
            ),
          ],
        ),
        Column(
          children: <Widget>[
            Column(
              children: <Widget>[],
            ),
          ],
        ),
      ],
    ));
  }

  void updatePreference(bool preference) {
    setState(() {
      this.showPreference = preference;
    });
  }
}
