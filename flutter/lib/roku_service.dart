import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class RokuDevice {
  final String ip;
  final String name;

  RokuDevice(this.ip, this.name);
}

class RokuService {
  static Future<String?> getLocalIpAddress() async {
    try {
      final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4, includeLinkLocal: false);
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.address.startsWith('192.168.') || addr.address.startsWith('10.') || addr.address.startsWith('172.')) {
            return addr.address;
          }
        }
      }
    } catch (e) {
      print('Error getting local IP address: $e');
    }
    return null;
  }

  static Future<List<RokuDevice>> discoverDevices() async {
    final localIp = await getLocalIpAddress();
    if (localIp == null) {
      print('Failed to get local IP address');
      throw Exception('Failed to get local IP address');
    }
    final subnet = localIp.substring(0, localIp.lastIndexOf('.'));
    print('Local IP: $localIp');
    print('Subnet: $subnet');

    List<RokuDevice> devices = [];
    List<Future> futures = [];

    for (int i = 1; i < 255; i++) {
      final ip = '$subnet.$i';
      futures.add(checkDevice(ip).then((device) {
        if (device != null) {
          devices.add(device);
          print('Found Roku device: ${device.name} at ${device.ip}');
        }
      }));
    }

    try {
      await Future.wait(futures);
    } catch (e) {
      print('Error during device discovery: $e');
    }

    print('Found ${devices.length} Roku devices');
    return devices;
  }

  static Future<RokuDevice?> checkDevice(String ip) async {
    try {
      final response = await http.get(Uri.parse('http://$ip:8060/query/device-info'))
          .timeout(Duration(milliseconds: 500));
      if (response.statusCode == 200) {
        final deviceInfo = xml.XmlDocument.parse(response.body);
        final friendlyName = deviceInfo.findAllElements('friendly-device-name').firstOrNull?.text ?? 'Unknown Roku';
        print('Device found at $ip: $friendlyName');
        return RokuDevice(ip, friendlyName);
      }
    } on TimeoutException {
      // print('Timeout checking device at $ip');
    } on SocketException {
      // print('Socket exception checking device at $ip');
    } catch (e) {
      print('Error checking device at $ip: $e');
    }
    return null;
  }

  static Future<void> sendCommand(String ip, String command) async {
    try {
      final response = await http.post(Uri.parse('http://$ip:8060/keypress/$command'));
      print('Sent command $command to $ip. Response: ${response.statusCode}');
    } catch (e) {
      print('Error sending command $command to $ip: $e');
    }
  }
}