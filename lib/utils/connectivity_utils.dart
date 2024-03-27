import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';

class ConnectivityUtils {
  static Future<String?> getIPAddress() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi) {
      try {
        return await NetworkInfo().getWifiIP();
      } catch (e) {
        print('Error getting IP address: $e');
      }
    }

    return null;
  }
}
