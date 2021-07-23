import 'package:flutter/material.dart';
import 'package:threebotlogin/events/events.dart';
import 'package:threebotlogin/events/go_home_event.dart';
import 'package:threebotlogin/events/go_news_event.dart';
import 'package:threebotlogin/events/go_planetary_event.dart';
import 'package:threebotlogin/events/go_reservations_event.dart';
import 'package:threebotlogin/events/go_settings_event.dart';
import 'package:threebotlogin/events/go_support_event.dart';
import 'package:threebotlogin/events/go_wallet_event.dart';
import 'package:threebotlogin/helpers/globals.dart';

class LayoutDrawer extends StatefulWidget {
  LayoutDrawer(
      { @required this.titleText,
        @required this.content});

  final String titleText;
  final Widget content;

  @override
  _LayoutDrawerState createState() => _LayoutDrawerState();
}

class _LayoutDrawerState extends State<LayoutDrawer> {
  Globals globals = Globals();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.titleText),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: widget.content,
      drawer: Drawer(
        elevation: 5,
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              width: 200,
              height: 100,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: DrawerHeader(
                    decoration: BoxDecoration(
                      image: new DecorationImage(
                        alignment: Alignment.bottomCenter,
                        image: AssetImage("assets/logo.png"),
                        fit: BoxFit.contain,
                      ),
                    ),
                    child: Text(''),
              )
              ),
            ),
            ListTile(
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.home, color: Colors.black, size: 18)
                ],
              ),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
                globals.tabController.animateTo(0);
              },
            ),
            ListTile(
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.article, color: Colors.black, size: 18)
                ],
              ),
              title: Text('News'),
              onTap: () {
                Navigator.pop(context);
                globals.tabController.animateTo(1);
              },
            ),
            ListTile(
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.account_balance_wallet, color: Colors.black, size: 18)
                ],
              ),
              title: Text('Wallet'),
              onTap: () {
                Navigator.pop(context);
                globals.tabController.animateTo(2);
              },
            ),
            ListTile(
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.chat, color: Colors.black, size: 18)
                ],
              ),
              title: Text('Support'),
              onTap: () {
                Navigator.pop(context);
                globals.tabController.animateTo(3);
              },
            ),
            ListTile(
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.book_online, color: Colors.black, size: 18)
                ],
              ),
              title: Text('Reserve DigitalTwin'),
              onTap: () {
                Navigator.pop(context);
                globals.tabController.animateTo(4);
              },
            ),
            ListTile(
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.network_check, color: Colors.black, size: 18)
                ],
              ),
              title: Text('Planetary Network'),
              onTap: () {
                Navigator.pop(context);
                globals.tabController.animateTo(5);
              },
            ),
            ListTile(
              leading: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.settings, color: Colors.black, size: 18)
                  ],
              ),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                globals.tabController.animateTo(6);
              },
            ),
          ],
        ),
      ),
    );
  }
}
