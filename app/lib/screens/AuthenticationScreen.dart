import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threebotlogin/helpers/Globals.dart';
import 'package:threebotlogin/helpers/HexColor.dart';
import 'package:threebotlogin/services/fingerprintService.dart';
import 'package:threebotlogin/services/userService.dart';
import 'package:threebotlogin/widgets/CustomDialog.dart';

class AuthenticationScreen extends StatefulWidget {
  final int pinLength = 4;
  final String correctPin;
  final String userMessage;

  @override
  AuthenticationScreen({this.correctPin, this.userMessage});

  @override
  AuthenticationScreenState createState() => AuthenticationScreenState();
}

class AuthenticationScreenState extends State<AuthenticationScreen> {
  int timeout = 30000;
  Globals globals = Globals();

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => checkFingerprint());
  }

  checkFingerprint() async {
    bool isFingerprintEnabled = await getFingerprint();

    if (isFingerprintEnabled) {
      bool isAuthenticated = await authenticate();

      if (isAuthenticated) {
        Navigator.pop(context, true);
      }
    }
  }

  List<String> input = List();

  Widget buildTextField(int i, BuildContext context) {
    const double maxSize = 7;
    double size = input.length > i ? maxSize : 1;
    double height = MediaQuery.of(context).size.height;
    return AnimatedContainer(
      margin: EdgeInsets.all(height / 120),
      height: height / 50,
      width: size,
      decoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle),
      duration: Duration(milliseconds: 100),
      curve: Curves.bounceInOut,
    );
  }

  Widget buildNumberPin(String buttonText, BuildContext context,
      {Color backgroundColor: Colors.blueGrey}) {
    var onPressedMethod = () => handleInput(buttonText);
    double height = MediaQuery.of(context).size.height;

    if (buttonText == 'OK')
      onPressedMethod = input.length >= widget.pinLength ? () => onOk() : null;
    if (buttonText == 'C')
      onPressedMethod = input.length >= 1 ? () => onClear() : null;
    return Container(
        padding: EdgeInsets.only(top: height / 136, bottom: height / 136),
        child: Center(
            child: RawMaterialButton(
          padding: EdgeInsets.all(12),
          child: Text(
            buttonText,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: onPressedMethod,
          fillColor: backgroundColor,
          shape: CircleBorder(),
        )));
  }

  Widget generateNumbers(BuildContext context) {
    List<String> possibleInput = [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      'C',
      '0',
      'OK'
    ];
    List<Widget> pins = List.generate(possibleInput.length, (int i) {
      String buttonText = possibleInput[i];
      if (buttonText == 'C')
        return buildNumberPin(possibleInput[i], context,
            backgroundColor:
                input.length >= 1 ? Colors.yellow[700] : Colors.yellow[200]);
      else if (buttonText == 'OK')
        return buildNumberPin(possibleInput[i], context,
            backgroundColor: input.length >= widget.pinLength
                ? Colors.green[600]
                : Colors.green[100]);
      else
        return buildNumberPin(possibleInput[i], context);
    });
    return Container(
      width: double.infinity,
      child: Center(
        child: Column(
          children: <Widget>[
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: pins.take(3).toList()),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: pins.skip(3).take(3).toList()),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: pins.skip(6).take(3).toList()),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: pins.skip(9).take(3).toList()),
          ],
        ),
      ),
    );
  }

  Widget generateTextFields(BuildContext context) {
    List<Widget> textFields = List.generate(widget.pinLength, (int i) {
      return buildTextField(i, context);
    });

    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: textFields);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
            backgroundColor: HexColor("#2d4052"),
            title: Text("Authentication"),
            elevation: 0.0,
            automaticallyImplyLeading: true),
        body: Container(
          color: Colors.white,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Text("Please authenticate to " + widget.userMessage),
                  padding: const EdgeInsets.only(bottom: 50),
                ),
                Container(
                  alignment: Alignment.center,
                  color: Colors.white,
                  child: Column(children: [
                    generateTextFields(context),
                    SizedBox(height: 25),
                    generateNumbers(context),
                  ]),
                ),
              ]),
        ));
  }

  Future<void> onOk() async {
    HapticFeedback.mediumImpact();

    String pin = "";
    input.forEach((char) => pin += char);

    int currentTime = new DateTime.now().millisecondsSinceEpoch;

    if (globals.incorrectPincodeAttempts >= 3 &&
        (globals.tooManyAuthenticationAttempts &&
            globals.lockedUntill < currentTime)) {
      globals.tooManyAuthenticationAttempts = false;
      globals.lockedUntill = 0;
      globals.incorrectPincodeAttempts = 0;
    }

    if (pin == widget.correctPin && !globals.tooManyAuthenticationAttempts) {
      globals.incorrectPincodeAttempts = 0;
      Navigator.pop(context, pin == widget.correctPin);
      return;
    }

    if (pin != widget.correctPin) {
      globals.incorrectPincodeAttempts++;
    }

    var dialog;

    if (globals.incorrectPincodeAttempts >= 3 ||
        (globals.tooManyAuthenticationAttempts &&
            globals.lockedUntill >= currentTime)) {
      if (!globals.tooManyAuthenticationAttempts) {
        globals.tooManyAuthenticationAttempts = true;
        globals.lockedUntill = currentTime + timeout;
      }

      dialog = CustomDialog(
        title: "Too many attempts",
        description: Text(
            "Too many incorrect attempts, please wait ${((globals.lockedUntill - currentTime) / 1000).toStringAsFixed(0)} seconds"),
      );
    } else {
      dialog = CustomDialog(
        title: "Incorrect pin",
        description: Text("Your pincode is incorrect."),
      );
    }

    await dialog.show(context);

    setState(() {
      input.removeRange(0, 4);
    });
  }

  void onClear() {
    HapticFeedback.mediumImpact();
    setState(() {
      input.removeLast();
    });
  }

  void handleInput(String buttonText) async {
    if (input.length < widget.pinLength) {
      HapticFeedback.lightImpact();
      setState(() {
        input.add(buttonText);
      });
    }
  }
}