import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:threebotlogin/services/open_kyc_service.dart';
import 'package:threebotlogin/services/user_service.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';

emailVerificationDialog(context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => CustomDialog(
      image: Icons.error,
      title: "Please verify email",
      description: "Please verify email before using this app",
      actions: <Widget>[
        FlatButton(
          child: new Text("Ok"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        FlatButton(
          child: new Text("Resend email"),
          onPressed: () async {
            sendVerificationEmail();
            Navigator.pop(context);
            emailResendedDialog(context);
          },
        ),
      ],
    ),
  );
}

emailResendedDialog(context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => CustomDialog(
      image: Icons.check,
      title: "Email has been resent.",
      description: "A new verification email has been sent.",
      actions: <Widget>[
        FlatButton(
          child: new Text("Ok"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}

phoneSendDialog(context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => CustomDialog(
      image: Icons.check,
      title: "Sms has been sent.",
      description: "A verification sms has been sent.",
      actions: <Widget>[
        FlatButton(
          child: new Text("Ok"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}

addPhoneNumberDialog(context) async {
  // https://api.ipgeolocationapi.com/geolocate

  var response = await http.get('https://ipinfo.io/country');

  var countryCode = response.body.replaceAll("\n", "");

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => PhoneAlertDialog(defaultCountryCode: countryCode ),
  );
}

class PhoneAlertDialog extends StatefulWidget {
  final String defaultCountryCode;

  const PhoneAlertDialog({Key key, this.defaultCountryCode}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new PhoneAlertDialogState();
  }
}

class PhoneAlertDialogState extends State<PhoneAlertDialog> {
  bool valid;
  String verificationPhoneNumber;

  @override
  void initState() {
    valid = false;
    verificationPhoneNumber = "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
        image: Icons.phone,
        title: "Add phone number",
        widgetDescription: SizedBox(
          height: 100,
          child: Row(
            children: <Widget>[
              // Expanded(
              //   child: InternationalPhoneInput(
              //     // initialSelection: initial ? initial['phoneCode'] : '',
              //     onPhoneNumberChange: onNumberChange,
              //     labelText: "Phone Number",
              //   ),
              // ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: IntlPhoneField(
                    initialCountryCode: widget.defaultCountryCode,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(),
                      ),
                    ),
                    onChanged: (phone) {
                      PhoneNumber p = phone as PhoneNumber;
                      print(p.completeNumber);

                      RegExp regExp = new RegExp(
                        r"^(\+[0-9]{1,3}|0)[0-9]{3}( ){0,1}[0-9]{7,8}\b$",
                        caseSensitive: false,
                        multiLine: false,
                      );

                      setState(() {
                        valid = regExp.hasMatch(p.completeNumber.replaceAll('\n', ''));
                        verificationPhoneNumber = p.completeNumber;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          new FlatButton(
              child: const Text(
                'CANCEL',
                style: TextStyle(color: Colors.redAccent),
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
          new FlatButton(
              color: valid ? Colors.green : Colors.grey,
              child: const Text('VERIFY'),
              onPressed: verifyButton)
        ]);
  }

  void verifyButton() {
    if (!valid) {
      return;
    }
    savePhone(verificationPhoneNumber, null);
    Navigator.pop(context);
  }

  void onNumberChange(
      String phoneNumber, String internationalizedPhoneNumber, String isoCode) {
    setState(() {
      valid = internationalizedPhoneNumber.isNotEmpty;
      verificationPhoneNumber = internationalizedPhoneNumber;
    });
  }
}

void onPhoneNumberChange(
    String phoneNumber, String internationalizedPhoneNumber, String isoCode) {}

onValidPhoneNumber(
    String number, String internationalizedPhoneNumber, String isoCode) {}
