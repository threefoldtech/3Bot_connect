import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:threebotlogin/helpers/migration_status.dart';
import 'package:threebotlogin/services/3bot_service.dart';
import 'package:threebotlogin/services/user_service.dart';

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
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        SizedBox(height: 10.0),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 200.0,
              height: 200.0,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
                image: DecorationImage(
                    fit: BoxFit.fill, image: AssetImage('assets/logo.png')),
              ),
            ),
            SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/newLogo.png',
                  height: 40,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    "Bot Connect",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
        RaisedButton(
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30),
                        ),
                        color: Theme.of(context).primaryColor,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Icon(
                              Icons.cloud_upload,
                              color: Colors.white,
                            ),
                            SizedBox(width: 10.0),
                            Text(
                              'Migrate to grid',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        onPressed: () {
                          migrateToGrid();
                        },
                      ),
        Column(
          children: <Widget>[
            Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Text(
                    "More functionality will be added soon.",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  void migrateToGrid() async {
    MigrationStatus currentMigrationStatus = (await getMigrationStatus());

    print('currentMigrationStatus: $currentMigrationStatus');

    if(currentMigrationStatus == MigrationStatus.registered) {
      return;
    }

    String doubleName = await getDoubleName();
    Map<String, Object> emailMap = await getEmail();


    print('doubleName: $doubleName');
    print('emailMap: $emailMap');
    print('emailMap: $emailMap');

    if (doubleName == null || emailMap['email'] == null) {
      return;
    }

    try {
      String publicKey = await getPublicKey();
      Response gridMigrationResponse = await migrateToGridVerification(doubleName, publicKey, emailMap['email'], emailMap['sei']);

      print('gridMigrationResponse.statusCode: ${gridMigrationResponse.statusCode}');

      if(gridMigrationResponse.statusCode == 200) {
        setMigrationStatus(MigrationStatus.registered);
        return;
      }

      if(gridMigrationResponse.statusCode != 200) {
        setMigrationStatus(MigrationStatus.registration_error); 
        // Separate email from doubleName error here? 
      }
    } catch (_) {
      setMigrationStatus(MigrationStatus.registration_failed);
    }
  }

  void updatePreference(bool preference) {
    setState(() {
      this.showPreference = preference;
    });
  }
}
