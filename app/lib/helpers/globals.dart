import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:threebotlogin/helpers/hex_color.dart';
import 'package:threebotlogin/helpers/vpn_state.dart';
import 'package:threebotlogin/jrouter.dart';
import 'package:threebotlogin/models/paymentRequest.dart';

class NoAnimationTabController extends TabController {
  NoAnimationTabController(
      {int initialIndex = 0,
        @required int length,
        @required TickerProvider vsync})
      : super(initialIndex: initialIndex, length: length, vsync: vsync);

  @override
  void animateTo(int value,
      {Duration duration = kTabScrollDuration, Curve curve = Curves.ease}) {
    super.animateTo(value,
        duration: const Duration(milliseconds: 0), curve: curve);
  }
}
class Globals {
  static final bool isInDebugMode = true;
  static final HexColor color = HexColor("#0a73b8");

  ValueNotifier<bool> emailVerified = ValueNotifier(false);
  ValueNotifier<bool> phoneVerified = ValueNotifier(false);

  final JRouter router = new JRouter();

  int incorrectPincodeAttempts = 0;
  int sendSmsAttempts = 0;
  bool tooManyAuthenticationAttempts = false;
  bool tooManySmsAttempts = false;

  String routeName = 'Home';
  NoAnimationTabController tabController;

  int lockedUntill = 0;
  int lockedSmsUntill = 0;
  int loginTimeout = 120;
  PaymentRequest paymentRequest;

  VpnState vpnState = new VpnState();
  static final Globals _singleton = new Globals._internal();

  factory Globals() {
    return _singleton;
  }

  Globals._internal();
}
