import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/helpers/hex_color.dart';
import 'package:threebotlogin/screens/main_screen.dart';
import 'package:threebotlogin/services/logging_service.dart';
import 'package:threebotlogin/services/user_service.dart';

LoggingService logger;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  bool initDone = await getInitDone();
  String doubleName = await getDoubleName();

  Map<String, Object> email = await getEmail();

  Globals().emailVerified.value = (email['sei'] != null);
  bool registered = doubleName != null;

  runApp(MyApp(initDone: initDone, registered: registered));
}

class MyApp extends StatelessWidget {
  MyApp({this.initDone, this.doubleName, this.registered});

  final bool initDone;
  final String doubleName;
  final bool registered;
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: HexColor("#2d4052"),
        accentColor: HexColor("#16a085"),
      ),
      home: MainScreen(initDone: initDone, registered: registered),
    );
  }
}
