import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/helpers/vpn_state.dart';
import 'package:threebotlogin/services/user_service.dart';
import 'package:threebotlogin/widgets/layout_drawer.dart';
import 'package:yggdrasil_plugin/yggdrasil_plugin.dart';

class PlanetaryNetworkScreen extends StatefulWidget {
  @override
  _PlanetaryNetworkScreenState createState() => _PlanetaryNetworkScreenState();
}

class _PlanetaryNetworkScreenState extends State<PlanetaryNetworkScreen> {

  VpnState _vpnState = new VpnState();
  bool _vpnTimeoutRunning = false;

  Text _ipText;
  Text _statusMessage = Text('');

  bool _isSwitched = Globals().vpnState.vpnConnected;

  void reportIp(String ip) {
    setState(() {
      _vpnState.ipAddress = ip;
    });
  }

  _PlanetaryNetworkScreenState() {
    _vpnState = Globals().vpnState;
    _vpnState.plugin.setOnReportIp(reportIp);
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      if (_vpnState.vpnConnected) {
        _ipText = new Text("IP Address: " + _vpnState.ipText);
        _statusMessage = new Text('Connected', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16));
        return;
      }
      _ipText = new Text("");
      _statusMessage = new Text('Not Connected', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16));
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutDrawer(
      titleText: 'Planetary Network',
      content: Stack(
        children: <Widget>[
          SvgPicture.asset(
            'assets/bg.svg',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          Column(
            children: [
              Container(
                height: 200,
                width: MediaQuery.of(context).size.width,
                child: Image.asset('assets/planetary-network.png'),
              ),
              Text('Planetary Network', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 40, right: 40),
                child: Text('A public peer-to-peer overlay network to connect everything on the planet. Connections are end-to-end'
                    ' encrypted and take the shortest path.', style: const TextStyle(fontSize: 14)),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 40, right: 40),
                child: Text('Think of it as a Local Area Network (LAN) on a planetary scale, a "global peer-to-peer VPN"'
                    ' that lives on top of other networks and looks for any path to connectivity. '
                    'Strongly authenticated at the edge.', style: const TextStyle(fontSize: 14)),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 40, right: 40, top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statusMessage,
                    Switch(
                      value: _isSwitched,
                      // If the user spams the button, the application would crash => use a timeout
                      onChanged: _vpnTimeoutRunning ? null : (value) async {

                        // When the user is not connected yet
                        if (!_vpnState.vpnConnected){
                          bool isVPNConnectionStarted = await _vpnState.plugin.startVpn(await getEdCurveKeys());

                          // In case the VPN Plugin connection couldn't be started
                          if (!isVPNConnectionStarted) {
                            setState(() { _ipText = new Text("Please click connect again after accepting VPN permissions."); });
                            return;
                          }

                          // When we are trying to connect to the network, set the timeout true
                          setState(() {
                            _vpnTimeoutRunning = true;
                            _statusMessage = new Text('Connecting ...', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16));
                          });


                          // Set the timeout of 5 seconds
                          Future.delayed(const Duration(milliseconds: 5000), () {
                            setState(() {
                              _vpnTimeoutRunning = false;
                              _isSwitched = true;
                              _statusMessage = new Text('Connected', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16));
                              _ipText = Text('IP Address: ' + _vpnState.ipAddress);
                            });
                          });

                          // The VPN connection is established => activate the button
                          _vpnState.vpnConnected = true;
                          return;
                        }

                        // Else: the the user is already connected and want to disconnect
                        setState(() {
                          _ipText = new Text("");
                          _vpnTimeoutRunning = true;
                          _statusMessage = new Text('Disconnecting ...', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16));
                        });

                        _vpnState.plugin.stopVpn();
                        _vpnState.vpnConnected = false;

                        _vpnState.plugin = new YggdrasilPlugin();
                        setState(() {
                          Future.delayed(const Duration(milliseconds: 5000), () {
                            setState(() {
                              _vpnTimeoutRunning = false;
                              _statusMessage = new Text('Not connected', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16));
                            });

                            _vpnState.ipAddress = "";
                            _isSwitched = false;
                          });

                          return;
                        });
                      },
                      activeColor: Theme.of(context).primaryColorDark,
                    ),
                  ]
                ),
              ),
              new GestureDetector(
                onTap: () async {
                  if (_vpnState.ipAddress != "") {
                    Clipboard.setData(new ClipboardData(text: _vpnState.ipAddress));

                    final snackBar = SnackBar(
                        content: Text('Address copied to clipboard'),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                },
                child: _ipText,
              ),
            ],
          )
        ],
      ),
    );
  }
}
