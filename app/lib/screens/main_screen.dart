import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threebotlogin/app_config.dart';
import 'package:threebotlogin/events/events.dart';
import 'package:threebotlogin/helpers/environment.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/screens/home_screen.dart';
import 'package:threebotlogin/screens/init_screen.dart';
import 'package:threebotlogin/screens/unregistered_screen.dart';
import 'package:threebotlogin/services/3bot_service.dart';
import 'package:threebotlogin/services/socket_service.dart';
import 'package:threebotlogin/services/user_service.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';
import 'package:threebotlogin/widgets/error_widget.dart';
import 'package:uni_links/uni_links.dart';

class MainScreen extends StatefulWidget {
  final bool initDone;
  final bool registered;

  MainScreen({this.initDone, this.registered});

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<MainScreen> {
  StreamSubscription _sub;
  String initialLink;
  // FirebaseNotificationListener _listener;
  BackendConnection _backendConnection;

  @override
  void initState() {
    super.initState();
    Events().reset();
    // _listener = FirebaseNotificationListener();
    WidgetsBinding.instance.addPostFrameCallback((_) => pushScreens());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return getErrorWidget(context, errorDetails);
    };

    return Container();
  }

  pushScreens() async {
    print("checking internet connection now");
    await checkInternetConnection();
    await checkInternetConnectionWithOurServers();
    await checkIfAppIsUnderMaintenance();
    await checkIfAppIsUpToDate();
    // await checkIfDeviceIdIsCorrect();

    if (widget.initDone != null && !widget.initDone) {
      InitScreen init = InitScreen();
      bool accepted = false;
      while (!accepted) {
        accepted = !(await Navigator.push(
                context, MaterialPageRoute(builder: (context) => init)) ==
            null);
      }
    }

    if (!widget.registered) {
      await Navigator.push(context,
          MaterialPageRoute(builder: (context) => UnregisteredScreen()));
    }

    await Globals().router.init();

    _backendConnection = BackendConnection(await getDoubleName());
    _backendConnection.init();

    await initUniLinks();

    if (_sub != null) {
      _sub.cancel();
    }

    await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomeScreen(
                initialLink: initialLink,
                backendConnection: _backendConnection)));
  }

  checkInternetConnection() async {
    try {
      final List<InternetAddress> result =
          await InternetAddress.lookup('google.com')
              .timeout(const Duration(seconds: 3));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected to the internet');
      }
    } on TimeoutException catch (_) {
      CustomDialog dialog = CustomDialog(
        title: "No internet connection available",
        description: "Please enable your internet connection to use this app.",
      );
      await dialog.show(context);
      if (Platform.isAndroid) {
        SystemNavigator.pop();
      } else if (Platform.isIOS) {
        exit(1);
      }
    } on Exception catch (_) {
      CustomDialog dialog = CustomDialog(
        title: "No internet connection available",
        description: "Please enable your internet connection to use this app.",
      );
      await dialog.show(context);
      if (Platform.isAndroid) {
        SystemNavigator.pop();
      } else if (Platform.isIOS) {
        exit(1);
      }
    }
  }

  checkInternetConnectionWithOurServers() async {
    if (AppConfig().environment != Environment.Local) {
      try {
        String baseUrl = AppConfig().baseUrl();
        final List<InternetAddress> result =
            await InternetAddress.lookup('$baseUrl')
                .timeout(const Duration(seconds: 3));
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          print('connected to the internet');
        }
      } on TimeoutException catch (_) {
        CustomDialog dialog = CustomDialog(
            title: "Connection problem",
            description:
                "The connection to our servers has failed, please try again later.");
        await dialog.show(context);
        if (Platform.isAndroid) {
          SystemNavigator.pop();
        } else if (Platform.isIOS) {
          exit(1);
        }
      } on Exception catch (_) {
        CustomDialog dialog = CustomDialog(
            title: "Oops",
            description:
                "Something went wrong when trying to connect to our servers, please try again. Contact support if this issue persists.");
        await dialog.show(context);
        if (Platform.isAndroid) {
          SystemNavigator.pop();
        } else if (Platform.isIOS) {
          exit(1);
        }
      }
    }
  }

  checkIfAppIsUnderMaintenance() async {
    try {
      if (await isAppUnderMaintenance()) {
        CustomDialog dialog = CustomDialog(
            title: "App is being rolled out",
            description:
                "The new version of our app is being rolled out, please try again later.");
        await dialog.show(context);
        if (Platform.isAndroid) {
          SystemNavigator.pop();
        } else if (Platform.isIOS) {
          exit(1);
        }
      }
    } on TimeoutException catch (_) {
      CustomDialog dialog = CustomDialog(
          title: "Connection problem",
          description:
              "The connection to our servers has failed, please try again later. 2");
      await dialog.show(context);
      if (Platform.isAndroid) {
        SystemNavigator.pop();
      } else if (Platform.isIOS) {
        exit(1);
      }
    } on Exception catch (_) {
      CustomDialog dialog = CustomDialog(
          title: "Oops",
          description:
              "Something went wrong. Please contact support if this issue persists.");
      await dialog.show(context);
      if (Platform.isAndroid) {
        SystemNavigator.pop();
      } else if (Platform.isIOS) {
        exit(1);
      }
    }
  }

  checkIfAppIsUpToDate() async {
    try {
      if (!await isAppUpToDate()) {
        CustomDialog dialog = CustomDialog(
            title: "Update required",
            description:
                "The app is outdated. Please, update it to the latest version.");

        await dialog.show(context);
        if (Platform.isAndroid) {
          SystemNavigator.pop();
        } else if (Platform.isIOS) {
          exit(1);
        }
      }
    } on TimeoutException catch (_) {
      CustomDialog dialog = CustomDialog(
          title: "Connection problem",
          description:
              "The connection to our servers has failed, please try again later. 3");
      await dialog.show(context);
      if (Platform.isAndroid) {
        SystemNavigator.pop();
      } else if (Platform.isIOS) {
        exit(1);
      }
    } on Exception catch (_) {
      CustomDialog dialog = CustomDialog(
          title: "Oops",
          description:
              "Something went wrong when checking if the app is up-to-date, please try again. Contact support if this issue persists.");
      await dialog.show(context);
      if (Platform.isAndroid) {
        SystemNavigator.pop();
      } else if (Platform.isIOS) {
        exit(1);
      }
    }
  }

  // checkIfDeviceIdIsCorrect() async {
  //   var doubleName = await getDoubleName();
  //   if (doubleName != null) {
  //     try {
  //       // Get user info
  //       Response userInfoResult = await getUserInfo(doubleName);
  //       if (userInfoResult.statusCode != 200) {
  //         throw new Exception('User not found.');
  //       }
  //       Map<String, dynamic> body = json.decode(userInfoResult.body);

  //       // Compare device id
  //       if (body == null ||
  //           body['device_id'] == null ||
  //           !body['device_id'].contains(await _listener.getToken())) {
  //         // If no match, update and recheck
  //         updateDeviceID(
  //             await getDoubleName(),
  //             await signData(
  //                 await _listener.getToken(), await getPrivateKey()));
  //         checkIfDeviceIdIsCorrect();
  //       }
  //     } on Exception catch (_) {
  //       CustomDialog dialog = CustomDialog(
  //           title: "Oops",
  //           description:
  //               "Something went wrong when checking the deviceID, please try again. Contact support if this issue persists.");
  //       await dialog.show(context);
  //     }
  //   }
  // }

  Future<Null> initUniLinks() async {
    initialLink = await getInitialLink();

    // Doesn't seem needed in this scenario. Might be removed in the future.
    _sub = getLinksStream().listen((String incomingLink) {
      if (!mounted) {
        return;
      }
      initialLink = incomingLink;
    });
  }
}
