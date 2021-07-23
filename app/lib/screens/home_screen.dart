import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
//import 'package:threebotlogin/apps/free_flow_pages/ffp.dart';
//import 'package:threebotlogin/apps/free_flow_pages/ffp_events.dart';
import 'package:threebotlogin/events/email_event.dart';
import 'package:threebotlogin/events/go_news_event.dart';
import 'package:threebotlogin/events/go_reservations_event.dart';
import 'package:threebotlogin/events/go_settings_event.dart';
import 'package:threebotlogin/events/go_support_event.dart';
import 'package:threebotlogin/events/phone_event.dart';
import 'package:threebotlogin/events/events.dart';
import 'package:threebotlogin/events/go_home_event.dart';
import 'package:threebotlogin/events/go_wallet_event.dart';
import 'package:threebotlogin/events/new_login_event.dart';
import 'package:threebotlogin/events/uni_link_event.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/helpers/hex_color.dart';
import 'package:threebotlogin/screens/authentication_screen.dart';
import 'package:threebotlogin/services/socket_service.dart';
import 'package:threebotlogin/services/uni_link_service.dart';
import 'package:threebotlogin/services/user_service.dart';
import 'package:threebotlogin/widgets/email_verification_needed.dart';
import 'package:uni_links/uni_links.dart';


/* Screen shows tabbar and all pages defined in router.dart */
class HomeScreen extends StatefulWidget {
  final String initialLink;
  final BackendConnection backendConnection;

  HomeScreen({this.initialLink, this.backendConnection});

  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  Globals globals = Globals();
  StreamSubscription _sub;
  String initialLink;
  bool timeoutExpiredInBackground = true;
  bool pinCheckOpen = false;
  int lastCheck = 0;
  final int pinCheckTimeout = 60000 * 5;

  _HomeScreenState() {
    globals.tabController = NoAnimationTabController(
        initialIndex: 0, length: Globals().router.routes.length, vsync: this);
    //Events().onEvent(FfpBrowseEvent().runtimeType, activateFfpTab);
    globals.tabController.addListener(_handleTabSelection);
  }

  void checkPin(int indexIfAuthIsSuccess) async {
    String pin = await getPin();

    pinCheckOpen = true;

    bool authenticated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AuthenticationScreen(
          correctPin: pin,
          userMessage: "access the wallet.",
        ),
      ),
    );

    pinCheckOpen = false;

    if (authenticated != null && authenticated) {
      lastCheck = new DateTime.now().millisecondsSinceEpoch;
      timeoutExpiredInBackground = false;
      globals.tabController.animateTo(indexIfAuthIsSuccess);
    }
  }

  _handleTabSelection() async {
    if (globals.tabController.indexIsChanging) {
      if (Globals().router.pinRequired(globals.tabController.index) &&
          timeoutExpiredInBackground &&
          !pinCheckOpen) {
        int authenticatedAppIndex = globals.tabController.index;
        globals.tabController.animateTo(globals.tabController.previousIndex);

        checkPin(authenticatedAppIndex);
      }

      if (Globals().router.emailMustBeVerified(globals.tabController.index) &&
          !Globals().emailVerified.value) {
        globals.tabController.animateTo(globals.tabController.previousIndex);
        await emailVerificationDialog(context);
      }
    }
  }

  // activateFfpTab(FfpBrowseEvent event) {
  //   int ffpTab = 2;
  //   Ffp().firstUrlToLoad = event.url;
  //   setState(() {
  //     _tabController.animateTo(ffpTab);
  //   });
  // }

  close(GoHomeEvent e) {
    int homeTab = 0; //@todo can we do some indexoff on routes
    globals.tabController.animateTo(homeTab);
  }


  @override
  void initState() {
    super.initState();
    initUniLinks();

    Events().onEvent(GoHomeEvent().runtimeType, close);

    Events().onEvent(GoHomeEvent().runtimeType, (GoHomeEvent event) {
      globals.tabController.animateTo(0, duration: Duration(seconds: 0));
    });

    Events().onEvent(GoNewsEvent().runtimeType, (GoNewsEvent event) {
      globals.tabController.animateTo(1, duration: Duration(seconds: 0));
    });

    Events().onEvent(GoWalletEvent().runtimeType, (GoWalletEvent event) {
      globals.tabController.animateTo(2, duration: Duration(seconds: 0));
    });

    Events().onEvent(GoSupportEvent().runtimeType, (GoSupportEvent event) {
      globals.tabController.animateTo(3, duration: Duration(seconds: 0));
    });

    Events().onEvent(GoSettingsEvent().runtimeType, (GoSettingsEvent event) {
      globals.tabController.animateTo(4, duration: Duration(seconds: 0));
    });

    Events().onEvent(GoReservationsEvent().runtimeType, (GoReservationsEvent event) {
      globals.tabController.animateTo(5, duration: Duration(seconds: 0));
    });

    Events().onEvent(NewLoginEvent().runtimeType, (NewLoginEvent event) {
      openLogin(context, event.loginData, widget.backendConnection);
    });

    Events().onEvent(EmailEvent().runtimeType, (EmailEvent event) {
      emailVerification(context);
    });
    Events().onEvent(PhoneEvent().runtimeType, (PhoneEvent event) {
      phoneVerification(context);
    });

    WidgetsBinding.instance.addObserver(this);

  }

  @override
  void dispose() {
    _sub.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (pinCheckOpen) {
        return;
      }

      int timeSpendWithPausedApp =
          new DateTime.now().millisecondsSinceEpoch - lastCheck;

      if (timeSpendWithPausedApp >= pinCheckTimeout) {
        timeoutExpiredInBackground = true;
      }

      if (Globals().router.pinRequired(globals.tabController.index) &&
          timeoutExpiredInBackground) {
        int homeTab = 0;
        globals.tabController.animateTo(homeTab);
      }
    } else if (state == AppLifecycleState.inactive) {
    } else if (state == AppLifecycleState.paused) {
      lastCheck = new DateTime.now().millisecondsSinceEpoch;
    }
  }

  Future<Null> initUniLinks() async {
    Events().onEvent(
        UniLinkEvent(null, null).runtimeType, UniLinkService.handleUniLink);
    initialLink = widget.initialLink;

    if (initialLink != null) {
      Events().emit(UniLinkEvent(Uri.parse(initialLink), context));
    }
    _sub = getLinksStream().listen((String incomingLink) {
      if (!mounted) {
        return;
      }
      Events().emit(UniLinkEvent(Uri.parse(incomingLink), context));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        child: new AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: HexColor("#2d4052"),
        ),
        preferredSize: Size.fromHeight(0),
      ),
      body: DefaultTabController(
        length: Globals().router.routes.length,
        child: WillPopScope(
          child: Scaffold(
            body: Stack(
              children: <Widget>[
                SvgPicture.asset(
                  'assets/bg.svg',
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
                SafeArea(
                    child: TabBarView(
                  controller: globals.tabController,
                  physics: NeverScrollableScrollPhysics(),
                  children: Globals().router.getContent(),
                )),

              ],
            ),
            // bottomNavigationBar: Container(
            //   color: HexColor("#0A73B8"),
            //   //@todo theme obj
            //   padding: EdgeInsets.all(0.0),
            //   height: 80,
            //   margin: EdgeInsets.all(0.0),
            //   child: TabBar(
            //     controller: _tabController,
            //     isScrollable: false,
            //     indicatorSize: TabBarIndicatorSize.tab,
            //     tabs: Globals().router.getAppButtons(),
            //     labelPadding: EdgeInsets.all(0.0),
            //     indicatorPadding: EdgeInsets.all(0.0),
            //   ),
            // ),
          ),
          onWillPop: onWillPop,
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  Future<bool> onWillPop() {
    if (globals.tabController.index == 0) {
      return Future(() => true); // if home screen exit
    }
    if (Globals().router.routes[globals.tabController.index].app == null) {
      Events().emit(GoHomeEvent()); // if not an app, eg settings, go home
    }
    Globals()
        .router
        .routes[globals.tabController.index]
        .app
        .back(); // if app ask app to handle back event

    return Future(() => false);
  }
}
