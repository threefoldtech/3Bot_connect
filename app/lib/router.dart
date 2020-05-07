import 'package:flutter/material.dart';
import 'package:threebotlogin/app.dart';
import 'package:threebotlogin/apps/chatbot/chatbot.dart';
import 'package:threebotlogin/apps/free_flow_pages/ffp.dart';
import 'package:threebotlogin/apps/wallet/wallet.dart';
import 'package:threebotlogin/screens/preference_screen.dart';
import 'package:threebotlogin/screens/registered_screen.dart';

class AppInfo {
  Route route;
  App app;
  AppInfo({this.route, this.app});
}

class Router {
  List<AppInfo> routes;

  init() async {
    routes = [
      AppInfo(
          route: Route(
            path: '/',
            name: 'Home',
            icon: Icons.home,
            view: RegisteredScreen(),
          ),
          app: null),
      AppInfo(
          route: Route(
            path: '/wallet',
            name: 'Wallet',
            icon: Icons.account_balance_wallet,
            view: await Wallet().widget(),
          ),
          app: Wallet()),
      AppInfo(
          route: Route(
            path: '/ffp',
            name: 'Social',
            icon: Icons.person,
            view: await Ffp().widget(),
          ),
          app: Ffp()),
      AppInfo(
          route: Route(
            path: '/chatbot',
            name: 'Support',
            icon: Icons.chat,
            view: await Chatbot().widget(),
          ),
          app: Chatbot()),
      AppInfo(
          route: Route(
            path: '/settings',
            name: 'Settings',
            icon: Icons.settings,
            view: PreferenceScreen(),
          ),
          app: null),
    ];
  }

  Map<String, Widget Function(BuildContext)> getRoutes() {
    return Map.fromIterable(routes, key: (v) => v.path, value: (v) => v.view);
  }

  bool emailMustBeVerified(int index) {
    if (routes[index].app != null) {
      return routes[index].app.emailVerificationRequired();
    }
    return false;
  }

  bool pinRequired(int index) {
    if (routes[index].app != null) {
      return routes[index].app.pinRequired();
    }
    return false;
  }

  List<Widget> getContent() {
    List<Widget> containers = [];
    routes.forEach((r) {
      containers.add(r.route.view);
    });
    return containers;
  }

  List<Container> getAppButtons() {
    List<Container> iconButtons = [];
    routes.forEach((r) {
      iconButtons.add(
        Container(
          padding: EdgeInsets.all(0.0),
          child: Tab(
            child: Column(
              children: <Widget>[
                Icon(
                  r.route.icon,
                  size: 25,
                ),
                Text(
                  r.route.name,
                  style: TextStyle(fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ),
        ),
      );
    });
    return iconButtons;
  }
}

class Route {
  final IconData icon;
  final String name;
  final String path;
  final Widget view;

  Route({this.path, this.name, this.icon, this.view});
}
