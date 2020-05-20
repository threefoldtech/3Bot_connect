import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:threebotlogin/screens/change_pin_screen.dart';
import 'package:threebotlogin/screens/mobile_registration_screen.dart';
import 'package:threebotlogin/screens/recover_screen.dart';
import 'package:threebotlogin/screens/successful_screen.dart';

class UnregisteredScreen extends StatefulWidget {
  UnregisteredScreen();

  _UnregisteredScreenState createState() => _UnregisteredScreenState();
}

class _UnregisteredScreenState extends State<UnregisteredScreen>
    with WidgetsBindingObserver {
  _UnregisteredScreenState();

  Future<void> startRegistration() async {
    final bool registered = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => MobileRegistrationScreen()));

    if (registered != null && registered) {
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChangePinScreen(hideBackButton: true)));
      /* CustomDialog(
          title: "Registered", description: Text("You are now registered.")).show(context);*/
      Navigator.pop(context, true);
    }
  }

  Future<void> startRecovery() async {
    final bool registered = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => RecoverScreen()));
    if (registered != null && registered) {
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChangePinScreen(hideBackButton: true)));
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SuccessfulScreen(
                  title: "Recovered",
                  text: "Your account has been recovered.")));

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final BoxDecoration tfGradient = const BoxDecoration(
      borderRadius: BorderRadius.all(
        Radius.circular(10),
      ),
      gradient: LinearGradient(colors: [
        Color(0xff73E5C0),
        Color(0xff68C5D5),
      ], stops: [
        0.0,
        0.1
      ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
    );
    return Material(
      child: WillPopScope(
        child: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
                maxHeight: double.infinity,
                maxWidth: double.infinity,
                minHeight: 250,
                minWidth: 250),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/intro.png"),
                          fit: BoxFit.contain,
                        ),
                      ),
                      child: null),
                ),
                IntrinsicWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text('A digital world with you',
                          style: TextStyle(fontSize: 24, color: Colors.black)),
                      Text('at the center',
                          style: TextStyle(fontSize: 24, color: Colors.black)),
                      SizedBox(height: 50),
                      Container(
                        margin: EdgeInsets.only(bottom: 10.0),
                        decoration: tfGradient,
                        padding: EdgeInsets.symmetric(horizontal: 5.0),
                        child: RaisedButton(
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(7),
                          ),
                          color: Theme.of(context).primaryColor,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Sign up',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          onPressed: () {
                            startRegistration();
                          },
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 10.0),
                        decoration: tfGradient,
                        padding: EdgeInsets.symmetric(horizontal: 5.0),
                        child: RaisedButton(
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(7),
                          ),
                          color: Theme.of(context).primaryColor,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Recover account',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          onPressed: () {
                            startRecovery();
                          },
                        ),
                      ),
                      SizedBox(height: 100),
                    ],
                  ),
                ),
                Container(),
              ],
            ),
          ),
        ),
        onWillPop: () {
          return Future.value(false);
        },
      ),
    );
  }
}
