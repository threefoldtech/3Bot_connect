import 'package:flutter/material.dart';
import 'package:threebotlogin/app.dart';
import 'package:threebotlogin/apps/chatbot/chatbot.dart';
import 'package:threebotlogin/apps/wallet/wallet.dart';
import 'package:threebotlogin/screens/planetary_network_screen.dart';
import 'package:threebotlogin/screens/preference_screen.dart';
import 'package:threebotlogin/screens/registered_screen.dart';
import 'package:threebotlogin/screens/reservation_screen.dart';

import 'apps/news/news.dart';

class AppInfo {
  Route route;
  App app;

  AppInfo({this.route, this.app});
}

class JRouter {
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
            path: '/news',
            name: 'News',
            icon: Icons.article,
            view: await News().widget(),
          ),
          app: News()),
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
            path: '/chatbot',
            name: 'Support',
            icon: Icons.chat,
            view: await Chatbot().widget(),
          ),
          app: Chatbot()),
      AppInfo(
          route: Route(
            path: '/reservations',
            name: 'Reservations',
            icon: Icons.book_online,
            view: ReservationScreen(),
          ),
          app: null),
      AppInfo(
          route: Route(
            path: '/planetary',
            name: 'Planetary Network',
            icon: Icons.network_check,
            view: PlanetaryNetworkScreen(),
          ),
          app: null),
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
      iconButtons.add(Container(
          child: Tab(
        icon: Icon(
          r.route.icon,
          size: 40,
        ),
        text: r.route.name,
      )));
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
