import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:threebotlogin/apps/free_flow_pages/ffp.dart';
import 'package:threebotlogin/apps/free_flow_pages/ffp_events.dart';
import 'package:threebotlogin/events/email_event.dart';
import 'package:threebotlogin/events/events.dart';
import 'package:threebotlogin/events/go_home_event.dart';
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
  TabController _tabController;
  StreamSubscription _sub;
  String initialLink;
  bool timeoutExpiredInBackground = true;
  bool pinCheckOpen = false;
  int lastCheck = 0;
  final int pinCheckTimeout = 60000 * 5;
  final BoxDecoration tfGradient = const BoxDecoration(
    gradient: LinearGradient(colors: [
      Color(0xff73E5C0),
      Color(0xff68C5D5),
    ], stops: [
      0.0,
      0.1
    ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
  );

  _HomeScreenState() {
    _tabController = TabController(
        initialIndex: 0, length: Globals().router.routes.length, vsync: this);
    Events().onEvent(FfpBrowseEvent().runtimeType, activateFfpTab);
    _tabController.addListener(_handleTabSelection);
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
      _tabController.animateTo(indexIfAuthIsSuccess);
    }
  }

  _handleTabSelection() async {
    if (_tabController.indexIsChanging) {
      if (Globals().router.pinRequired(_tabController.index) &&
          timeoutExpiredInBackground &&
          !pinCheckOpen) {
        int authenticatedAppIndex = _tabController.index;
        _tabController.animateTo(_tabController.previousIndex);

        checkPin(authenticatedAppIndex);
      }

      if (Globals().router.emailMustBeVerified(_tabController.index) &&
          !Globals().emailVerified.value) {
        _tabController.animateTo(_tabController.previousIndex);
        await emailVerificationDialog(context);
      }
    }
  }

  activateFfpTab(FfpBrowseEvent event) {
    int ffpTab = 2;
    Ffp().firstUrlToLoad = event.url;
    setState(() {
      _tabController.animateTo(ffpTab);
    });
  }

  close(GoHomeEvent e) {
    int homeTab = 0; //@todo can we do some indexoff on routes
    _tabController.animateTo(homeTab);
  }

  @override
  void initState() {
    super.initState();
    initUniLinks();

    Events().onEvent(GoHomeEvent().runtimeType, close);

    Events().onEvent(NewLoginEvent().runtimeType, (NewLoginEvent event) {
      openLogin(context, event.loginData, widget.backendConnection);
    });

    Events().onEvent(EmailEvent().runtimeType, (EmailEvent event) {
      emailVerification(context);
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

      if (Globals().router.pinRequired(_tabController.index) &&
          timeoutExpiredInBackground) {
        int homeTab = 0;
        _tabController.animateTo(homeTab);
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
            body: SafeArea(
              child: TabBarView(
                controller: _tabController,
                physics: NeverScrollableScrollPhysics(),
                children: Globals().router.getContent(),
              ),
            ),
            bottomNavigationBar: Container(
              decoration: tfGradient,
              height: 70,
              child: Container(
                margin: EdgeInsets.only(top: 7.0),
                padding: EdgeInsets.only(top: 7.0),
                color: Theme.of(context).primaryColor,
                child: TabBar(
                  unselectedLabelColor: Colors.white60,
                  labelColor: Color(0xff6BCED0),
                  indicatorColor: Colors.transparent,
                  controller: _tabController,
                  isScrollable: false,
                  tabs: Globals().router.getAppButtons()
                ),
              ),
            ),
          ),
          onWillPop: onWillPop,
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  Future<bool> onWillPop() {
    if (_tabController.index == 0) {
      return Future(() => true); // if home screen exit
    }
    if (Globals().router.routes[_tabController.index].app == null) {
      Events().emit(GoHomeEvent()); // if not an app, eg settings, go home
    }
    Globals()
        .router
        .routes[_tabController.index]
        .app
        .back(); // if app ask app to handle back event

    return Future(() => false);
  }
}
