import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:threebotlogin/app_config.dart';
import 'package:threebotlogin/apps/free_flow_pages/ffp_events.dart';
import 'package:threebotlogin/events/events.dart';

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
  final tfGradient = const BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(50)),
    gradient: LinearGradient(colors: [
      Color(0xff73E5C0),
      Color(0xff68C5D5),
    ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/intro.png"),
                  fit: BoxFit.contain,
                ),
              ),
              child: null),
        ),
        Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: new EdgeInsets.all(40.0),
                child: Text("Threefold News Circles",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                SizedBox(
                  width: 10,
                ),
                Column(
                  children: <Widget>[
                    FloatingActionButton(
                      heroTag: "tft",
                      elevation: 0,
                      child: Container(
                        decoration: tfGradient,
                        padding: EdgeInsets.all(5.0),
                        child: CircleAvatar(
                          backgroundImage: ExactAssetImage(
                              'assets/circle_images/tftokens.jpg'),
                          minRadius: 90,
                          maxRadius: 150,
                        ),
                      ),
                      onPressed: () {
                        Events().emit(FfpBrowseEvent(
                            url: AppConfig().circleUrls()['tftokens']));
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text("TF Tokens"),
                    ),
                  ],
                ),
                Column(
                  //2 News
                  children: <Widget>[
                    FloatingActionButton(
                      heroTag: "tfnews",
                      backgroundColor: Colors.greenAccent,
                      elevation: 0,
                      child: Container(
                        decoration: tfGradient,
                        padding: EdgeInsets.all(5.0),
                        child: CircleAvatar(
                          backgroundImage: ExactAssetImage(
                              'assets/circle_images/tffamily.jpg'),
                          minRadius: 90,
                          maxRadius: 150,
                        ),
                      ),
                      onPressed: () {
                        Events().emit(FfpBrowseEvent(
                            url: AppConfig().circleUrls()['tf-news']));
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text("TF News"),
                    ),
                  ],
                ),
                Column(
                  //3 tf grid
                  children: <Widget>[
                    FloatingActionButton(
                      heroTag: "tfgrid",
                      backgroundColor: Colors.blueAccent,
                      elevation: 0,
                      child: Container(
                        decoration: tfGradient,
                        padding: EdgeInsets.all(5.0),
                        child: CircleAvatar(
                          backgroundImage: ExactAssetImage(
                              'assets/circle_images/tfgrid.jpg'),
                          minRadius: 90,
                          maxRadius: 150,
                        ),
                      ),
                      onPressed: () {
                        Events().emit(FfpBrowseEvent(
                            url: AppConfig().circleUrls()['tf-grid']));
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text("TF Grid"),
                    ),
                  ],
                ),
                Column(
                  // 4
                  children: <Widget>[
                    FloatingActionButton(
                      heroTag: "ffnation",
                      backgroundColor: Colors.grey,
                      elevation: 0,
                      child: Container(
                        decoration: tfGradient,
                        padding: EdgeInsets.all(5.0),
                        child: CircleAvatar(
                          backgroundImage: ExactAssetImage(
                              'assets/circle_images/ffnation.jpg'),
                          minRadius: 90,
                          maxRadius: 150,
                        ),
                      ),
                      onPressed: () {
                        Events().emit(FfpBrowseEvent(
                            url: AppConfig().circleUrls()['freeflownation']));
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text("FF Nation"),
                    ),
                  ],
                ),
                Column(
                  // 5
                  children: <Widget>[
                    FloatingActionButton(
                      heroTag: "3bot",
                      backgroundColor: Colors.orangeAccent,
                      elevation: 0,
                      child: Container(
                        decoration: tfGradient,
                        padding: EdgeInsets.all(5.0),
                        child: CircleAvatar(
                          backgroundImage:
                              ExactAssetImage('assets/circle_images/3bot.jpg'),
                          minRadius: 90,
                          maxRadius: 150,
                        ),
                      ),
                      onPressed: () {
                        Events().emit(FfpBrowseEvent(
                            url: AppConfig().circleUrls()['3bot']));
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text("3Bot"),
                    ),
                  ],
                ),
                SizedBox(
                  width: 10,
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 50.0),
      ],
    );
  }

  void updatePreference(bool preference) {
    setState(() {
      this.showPreference = preference;
    });
  }
}
