import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:threebotlogin/events/events.dart';
import 'package:threebotlogin/events/pop_all_login_event.dart';
import 'package:threebotlogin/helpers/block_and_run_mixin.dart';
import 'package:threebotlogin/services/tools_service.dart';
import 'package:threebotlogin/services/user_service.dart';
import 'package:threebotlogin/services/crypto_service.dart';
import 'package:threebotlogin/services/3bot_service.dart';
import 'package:threebotlogin/widgets/image_button.dart';
import 'package:threebotlogin/widgets/preference_dialog.dart';

_LoginScreenState lastState;

class LoginScreen extends StatefulWidget {
  final Widget loginScreen;
  final Widget scopeList;
  final message;
  final bool closeWhenLoggedIn;
  final bool autoLogin;

  LoginScreen(this.message,
      {Key key,
      this.loginScreen,
      this.closeWhenLoggedIn = false,
      this.scopeList,
      this.autoLogin = false})
      : super(key: key);

  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with BlockAndRunMixin {
  String helperText = '';

  String scopeTextMobile =
      'Please select the data you want to share and press Accept';
  String scopeText =
      'Please select the data you want to share and press the corresponding emoji';

  List<int> imageList = new List();
  Map scope = Map();

  int selectedImageId = -1;
  int correctImage = -1;

  bool cancelBtnVisible = false;
  bool showScopeAndEmoji = false;
  bool isMobileCheck = false;
  String emitCode = randomString(10);
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  close(PopAllLoginEvent e) {
    if (e.emitCode == emitCode) {
      return;
    }
    if (mounted) {
      Navigator.pop(context, false);
    }
  }

  @override
  void initState() {
    super.initState();
    Events().onEvent(PopAllLoginEvent("").runtimeType, close);
    isMobileCheck = checkMobile();

    makePermissionPrefs();
    generateEmojiImageList();

    // if (widget.autoLogin) {
    //   sendIt(true);
    //   return;
    // }

    finishLogin();
  }

  void generateEmojiImageList() {
    correctImage = parseImageId(widget.message['randomImageId']);

    imageList.add(correctImage);

    int generated = 1;
    var rng = new Random();
    while (generated <= 3) {
      var x = rng.nextInt(266) + 1;
      if (!imageList.contains(x)) {
        imageList.add(x);
        generated++;
      }
    }

    setState(() {
      imageList.shuffle();
    });
  }

  bool isRequired(value, givenScope) {
    var decodedValue = jsonDecode(givenScope)[value];
    if (decodedValue == null) return false;
    if (decodedValue is String) {
      return true;
    } else
      return decodedValue && decodedValue != null;
  }

  makePermissionPrefs() async {
    if (widget.message['scope'] != null) {
      if (jsonDecode(widget.message['scope']).containsKey('email')) {
        scope['email'] = await getEmail();
      }

      // if (jsonDecode(widget.message['scope']).containsKey('derivedSeed')) {
      //   scope['derivedSeed'] = await getDerivedSeed(widget.message['appId']);
      // }

      // if (jsonDecode(widget.message['scope']).containsKey('trustedDevice')) {
      //   var trustedDevice = {};
      //   trustedDevice['trustedDevice'] =
      //       json.decode(widget.message['scope'])['trustedDevice'];
      //   scope['trustedDevice'] = trustedDevice;
      // }
    }

    String scopePermissions = await getScopePermissions();
    if (scopePermissions == null) {
      saveScopePermissions(jsonEncode(scope));
      scopePermissions = jsonEncode(scope);
    }

    var initialPermissions = jsonDecode(scopePermissions);

    if (!initialPermissions.containsKey(widget.message['appId'])) {
      var newHashMap = new HashMap();
      initialPermissions[widget.message['appId']] = newHashMap;

      if (scope != null) {
        scope.keys.toList().forEach((var value) {
          newHashMap[value] = {
            'enabled': true,
            'required': isRequired(value, widget.message['scope'])
          };
        });
      }
      saveScopePermissions(jsonEncode(initialPermissions));
    } else {
      List<String> permissions = [
        'doubleName',
        'email',
        // 'derivedSeed',
        // 'trustedDevice'
      ];

      permissions.forEach((var permission) {
        if (!initialPermissions[widget.message['appId']]
            .containsKey(permission)) {
          initialPermissions[widget.message['appId']][permission] = {
            'enabled': true,
            'required': isRequired(permission, widget.message['scope'])
          };
        }
      });
      saveScopePermissions(jsonEncode(initialPermissions));
    }
  }

  finishLogin() {
    cancelBtnVisible = true;

    setState(() {
      showScopeAndEmoji = true;
    });
  }

  Widget scopeEmojiView() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 24.0, left: 24.0),
                  child: Text(
                    isMobileCheck ? scopeTextMobile : scopeText,
                    style: TextStyle(fontSize: 18.0),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: SizedBox(
                  height: 200.0,
                  child: PreferenceDialog(
                    scope: scope,
                    appId: widget.message['appId'],
                    callback: cancelIt,
                    type: 'login',
                  )),
            ),
            Visibility(
              visible: !isMobileCheck,
              child: Expanded(
                flex: 2,
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          ImageButton(imageList[0], selectedImageId,
                              imageSelectedCallback),
                          ImageButton(imageList[1], selectedImageId,
                              imageSelectedCallback),
                          ImageButton(imageList[2], selectedImageId,
                              imageSelectedCallback),
                          ImageButton(imageList[3], selectedImageId,
                              imageSelectedCallback),
                        ])),
              ),
            ),
            Visibility(
              visible: isMobileCheck,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: RaisedButton(
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30),
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 11.0, vertical: 6.0),
                  color: Theme.of(context).accentColor,
                  child: Text(
                    'Accept',
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                  onPressed: () async {
                    await sendIt(true);
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: new Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Login'),
          elevation: 0.0,
        ),
        body: Column(
          children: <Widget>[
            Visibility(
              visible: showScopeAndEmoji,
              child: Expanded(flex: 6, child: scopeEmojiView()),
            ),
            Visibility(
              visible: cancelBtnVisible,
              child: Expanded(
                flex: 0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FlatButton(
                    child: Text(
                      "It wasn\'t me - cancel",
                      style:
                          TextStyle(fontSize: 16.0, color: Color(0xff0f296a)),
                    ),
                    onPressed: () {
                      cancelIt();
                      Navigator.pop(context, false);
                      Events().emit(PopAllLoginEvent(emitCode));
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      onWillPop: () {
        cancelIt();
        return Future.value(true);
      },
    );
  }

  imageSelectedCallback(imageId) {
    blockAndRun(() async {
      setState(() {
        selectedImageId = imageId; 
      });

      if (selectedImageId != -1) {
        if (selectedImageId == correctImage) {
         await sendIt(true);
        } else {
          _scaffoldKey.currentState.showSnackBar(
              SnackBar(content: Text('Oops... that\'s the wrong emoji')));
          await sendIt(false);
        }
      } else {
        _scaffoldKey.currentState
            .showSnackBar(SnackBar(content: Text('Please select an emoji')));
      }
    });
  }

  cancelIt() async {
    cancelLogin(await getDoubleName());
  }

  sendIt(bool includeData) async {
    var state = widget.message['state'];
    var signedRoom = widget.message['signedRoom'];
    var publicKey = widget.message['appPublicKey']?.replaceAll(" ", "+");
    bool hashMatch = RegExp(r"[^A-Za-z0-9]+").hasMatch(state);

    if (hashMatch) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('States can only be alphanumeric [^A-Za-z0-9]'),
      ));
      return;
    }

    var signedHash = signData(state, await getPrivateKey());
    var tmpScope = Map();

    try {
      tmpScope = await buildScope();
    } catch (exception) {
      print(exception);
    }

    var data =
        await encrypt(jsonEncode(tmpScope), publicKey, await getPrivateKey());

    //push to backend with signed
    if (!includeData) {
      await sendData(state, "", null, selectedImageId,
          null); // temp fix send empty data for regenerate emoji
    } else {
      await sendData(
          state, await signedHash, data, selectedImageId, signedRoom);
    }

    // if (scope['trustedDevice'] != null) {
    //   saveTrustedDevice(widget.message['appId'], scope['trustedDevice']['trustedDevice']);
    // }

    if (selectedImageId == correctImage || isMobileCheck) {
      Navigator.pop(context, true);
      Events().emit(PopAllLoginEvent(emitCode));
    }
  }

  dynamic buildScope() async {
    Map tmpScope = new Map.from(scope);

    var json = jsonDecode(await getScopePermissions());
    var permissions = json[widget.message['appId']];
    var keysOfPermissions = permissions.keys.toList();

    keysOfPermissions.forEach((var value) {
      if (!permissions[value]['enabled']) {
        tmpScope.remove(value);
      }
    });

    return tmpScope;
  }

  bool checkMobile() {
    var mobile = widget.message['mobile'];
    return mobile == true || mobile == 'true';
  }

  int parseImageId(String imageId) {
    if (imageId == null || imageId == '') {
      return 1;
    }
    return int.parse(imageId);
  }
}