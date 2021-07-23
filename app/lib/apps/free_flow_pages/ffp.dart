// import 'package:flutter/material.dart';
// import 'package:threebotlogin/app.dart';
// import 'package:threebotlogin/apps/free_flow_pages/ffp_events.dart';
// import 'package:threebotlogin/apps/free_flow_pages/ffp_widget.dart';
// import 'package:threebotlogin/events/events.dart';

// class Ffp implements App {
//   static final Ffp _singleton = new Ffp._internal();
//   static final FfpWidget _ffpWidget = FfpWidget();

//   factory Ffp() {
//     return _singleton;
//   }

//   Ffp._internal();

//   String firstUrlToLoad = ""; // quick fix make pretty
//   @override
//   Future<Widget> widget() async {
//     return _ffpWidget;
//   }

//   void back() {
//     Events().emit(FfpBackEvent());
//   }

//   void clearData() {
//     //clearAllData();
//   }

//   @override
//   bool emailVerificationRequired() {
//     return true;
//   }

//   @override
//   bool pinRequired() {
//     return false;
//   }
// }
