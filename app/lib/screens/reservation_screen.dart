import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:threebotlogin/events/events.dart';
import 'package:threebotlogin/events/go_wallet_event.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/helpers/hex_color.dart';
import 'package:threebotlogin/models/paymentRequest.dart';
import 'package:threebotlogin/services/3bot_service.dart';
import 'package:threebotlogin/services/user_service.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';
import 'package:threebotlogin/widgets/layout_drawer.dart';

class ReservationScreen extends StatefulWidget {
  ReservationScreen({Key key}) : super(key: key);

  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  String doubleName = '';
  bool _isLoading = false;
  Map<String, Object> _productKeys;
  TextEditingController productKeyController = TextEditingController();
  bool _isValid = false;
  bool _layoutValid = true;
  bool _isDigitalTwinActive = true;

  Future _getReservationDetails() async {
    if (doubleName.isEmpty) {
      String value = await getDoubleName();
      doubleName = value;
      setState(() {
        doubleName = value;
      });
    }

      Response reservationDetailsResult = await getReservationDetails(doubleName);
      Map<String, Object> reservationDetails = jsonDecode(reservationDetailsResult.body);


      if(reservationDetails['details'] == null){
        return;
      }

    return reservationDetails['details'];
  }

  Future _checkReservations() async {
    print('LADEN');
    if (doubleName.isEmpty) {
      String value = await getDoubleName();
      doubleName = value;
      setState(() {
        doubleName = value;
      });
      if (!_isLoading) {
        _loadingDialog();
        setState(() {
          _isLoading = true;
        });
      }
    }

    Response reservationsResult = await getReservations(doubleName);
    print('RESULTAAT');
    print(reservationsResult);
    if (_isLoading) {
      Navigator.pop(context); // Remove loading screen
      setState(() {
        _isLoading = false;
      });
    }
    if (reservationsResult.statusCode != 200) {
      // TODO let user know there was an error
      _isDigitalTwinActive = false;
      return {"active": false};
    }

    _isDigitalTwinActive = jsonDecode(reservationsResult.body)['active'];
  }

  bool _checkIfProductKeyIsValid(String productKey) {
    if (_productKeys.isEmpty) return false;
    if (_productKeys['productkeys'] == null) return false;

    for (var item in _productKeys['productkeys']) {
      if (item['key'] == productKey) return true;
    }
    return false;
  }

  Future _fillProductKeys() async {
    Response productKeysResult = await getProductKeys(doubleName);
    Map<String, Object> productKeys = jsonDecode(productKeysResult.body);

    if (productKeys == null) {
      // There are no product keys available
      print("There are no product keys available");
      return;
    }

    _productKeys = productKeys;
    return productKeys['productkeys'];
  }

  _activateProductKey(String productKey) async {
    bool isValid = _checkIfProductKeyIsValid(productKey);

    if (!isValid) {
      // Double check to be sure the key is valid
      // For some reason, the given product key is not valid
      print('Given product key is not valid');
      return;
    }

    activateDigitalTwin(doubleName, productKey);

    _successDialog();

    productKeyController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutDrawer(
      titleText: 'Reservations',
      content: Stack(
        children: [
          SvgPicture.asset(
            'assets/bg.svg',
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                FutureBuilder(
                  future: _checkReservations(),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    Widget box = Container();
                    box =
                        _isDigitalTwinActive ? _reserved() : _notReservedYet();

                    return Container(
                      padding: EdgeInsets.all(25.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          box,
                          SizedBox(
                            height: 50.0,
                          ),
                          _reserveForLovedOnes(),
                          SizedBox(
                            height: 50.0,
                          ),
                          _productKeysItem(),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _notReservedYet() {
    return _card(
      title: 'Reserve your digital twin for life',
      body: Column(
        children: [
          Text(
              'With Digital Twin seamless experiences, grant yourself with a lifetime digital freedom and frivacy for only 1000 TFT'),
          SizedBox(
            height: 10,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            ElevatedButton(
              onPressed: () {
                redirectToWallet(activatedDirectly: true);
              },
              child: Text('Reserve now'),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _reserved() {
    return _card(
      title: 'Already reserved for yourself',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            children: [
              Text(
                  'Digital Twin for Life is coming soon. Stay tuned and subscribes to our Telegram Channel for News and Updates'),
            ],
          ),
          SizedBox(
            height: 25.0,
          ),
          // https://t.me/joinchat/JnJfqY9tfAU1NTY0
          TextButton.icon(
            onPressed: () {},
            label: Text('Check Telegram channel'),
            icon: Icon(Icons.open_in_new),
          ),
          ElevatedButton(
              onPressed: () {
                _showReservation();
              }, child: Text('Check your reservation'))
        ],
      ),
    );
  }

  Widget _reserveForLovedOnes() {
    return _card(
      title: "Reserve Digital Twin for Life for your loved ones",
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              'Grant a Digital Twin for Life to your Loved ones for only 1000 TFT. All you need is their 3Bot ID.'),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  redirectToWallet(
                      reservingFor: 'loved.3bot', activatedDirectly: false);
                },
                child: Text('Buy productkey'),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _productKeysItem() {
    return _card(
      title: "Product keys",
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder(
            builder: (context, snapshot) {
              if (ConnectionState.done != null && snapshot.hasError) {
                return Center(child: Text('Something went wrong'));
              }

              if (!snapshot.hasData) {
                return Text('No product keys available');
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8, right: 8, bottom: 8),
                        child: Text('Product key ' +
                            (index + 1).toString() +
                            ': ' +
                            snapshot.data[index]['key'].toString()),
                      ),
                      new GestureDetector(
                        onTap: () async {
                          if (snapshot.hasData) {
                            Clipboard.setData(new ClipboardData(text: snapshot.data[index]['key'].toString()));

                            final snackBar = SnackBar(
                              content: Text('Product key copied to clipboard'),
                            );

                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          }
                        },
                        child: Icon(Icons.content_copy, size: 14,),
                      ),

                    ],
                  );
                },
              );
            },
            future: _fillProductKeys(),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _isDigitalTwinActive || _productKeys['productkeys'] == null
                  ? Container()
                  : Flexible(
                      child: Row(
                      children: [
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.only(right: 25),
                          child: TextFormField(
                            controller: productKeyController,
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'Enter product key',
                              errorText: _layoutValid
                                  ? ''
                                  : 'Enter a valid product key',
                              errorBorder: _layoutValid
                                  ? new OutlineInputBorder(
                                      borderSide: new BorderSide(
                                          color: Colors.transparent,
                                          width: 0.0))
                                  : new OutlineInputBorder(
                                      borderSide: new BorderSide(
                                          color: Colors.red, width: 1),
                                    ),
                            ),
                          ),
                        )),
                        ElevatedButton(
                          onPressed: () {
                            setState(() => _isValid = _checkIfProductKeyIsValid(
                                productKeyController.text));
                            _layoutValid = _isValid;
                            if (!_isValid) return;

                            _activateProductKey(productKeyController.text);
                          },
                          child: Text('Activate'),
                        ),
                      ],
                    ))
            ],
          ),
        ],
      ),
    );
  }

  Future<void> redirectToWallet(
      {String reservingFor, bool activatedDirectly}) async {
    if (reservingFor == null) {
      reservingFor = doubleName;
    }

    Map<String, dynamic> data = {
      'doubleName': doubleName,
      'reservationBy': await getDoubleName(),
      'activated_directly': activatedDirectly,
    };

    Response res = await sendProductReservation(data);

    Map<String, dynamic> decode = json.decode(res.body);

    Globals().paymentRequest = PaymentRequest.fromJson(decode);

    Events().emit(GoWalletEvent());
  }

  Future _loadingDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 10,
            ),
            new CircularProgressIndicator(),
            SizedBox(
              height: 10,
            ),
            new Text("One moment please"),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  Future _successDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
              image: Icons.check,
              title: "Successfully activated",
              description: "The product key was successfully activated",
              actions: <Widget>[
                FlatButton(
                  child: new Text("Ok"),
                  onPressed: () {
                    Navigator.pop(context);
                    setState((){});
                  },
                ),
              ],
            ));
  }

  Future _showReservation() {
    return showDialog(
        context: context,
        builder: (BuildContext context) => Dialog(
          child: FutureBuilder(
            future: _getReservationDetails(),
            builder:
                (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if(!snapshot.hasData) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        new Text('Reservation information',  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                        new Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            new CircularProgressIndicator(),
                            SizedBox(
                              height: 10,
                            ),
                            new Text("Loading"),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      new Text('Reservation information',  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                      SizedBox(
                        height: 10,
                      ),

                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            new Text('Reserved for:', style: TextStyle(fontWeight: FontWeight.bold)),
                            new Text(snapshot.data['double_name'])
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            new Text('Product key:', style: TextStyle(fontWeight: FontWeight.bold)),
                            new Text(snapshot.data['key'])
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            new Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                            new Text('Activated', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                          ],
                        ),
                      ),
                      new ElevatedButton(onPressed: (){
                        Navigator.pop(context, true);

                      }, child: Text('OK')),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  );
            },
          ),
        ));
  }

  Widget _card({String title, Widget body}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
              offset: Offset(1, 2),
              blurRadius: 2.0,
              spreadRadius: 0.0,
              color: Colors.grey.shade300),
        ],
      ),
      child: Container(
        padding: EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 20,
            ),
            body,
          ],
        ),
      ),
    );
  }
}
