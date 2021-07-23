import 'package:yggdrasil_plugin/yggdrasil_plugin.dart';

class VpnState {
  VpnState(){
    plugin = new YggdrasilPlugin();
  }
  YggdrasilPlugin plugin;
  String ipText;

  bool vpnConnected = false;
  String ipAddress = "";
}
