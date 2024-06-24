import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class RokuDevice {
  final String ip;
  final String name;

  RokuDevice(this.ip, this.name);

  Map<String, dynamic> toJson() => {
    'ip': ip,
    'name': name,
  };

  factory RokuDevice.fromJson(Map<String, dynamic> json) {
    return RokuDevice(json['ip'], json['name']);
  }
}

class RokuService {
  static const String _cachedDevicesKey = 'cached_roku_devices';

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

  static Future<List<RokuDevice>> discoverDevices({int timeout = 5000, int retries = 3}) async {
    final cachedDevices = await getCachedDevices();
    final localIp = await getLocalIpAddress();
    if (localIp == null) {
      print('Failed to get local IP address');
      throw Exception('Failed to get local IP address');
    }
    final subnet = localIp.substring(0, localIp.lastIndexOf('.'));
    print('Local IP: $localIp');
    print('Subnet: $subnet');

    List<RokuDevice> newDevices = [];
    List<Future> futures = [];

    for (int attempt = 0; attempt < retries; attempt++) {
      print('Discovery attempt ${attempt + 1} of $retries');
      futures.clear();

      for (int i = 1; i < 255; i++) {
        final ip = '$subnet.$i';
        futures.add(checkDevice(ip, timeout: timeout).then((device) {
          if (device != null) {
            newDevices.add(device);
            print('Found Roku device: ${device.name} at ${device.ip}');
          }
        }));
      }

      try {
        await Future.wait(futures);
        if (newDevices.isNotEmpty) {
          break;
        }
      } catch (e) {
        print('Error during device discovery attempt ${attempt + 1}: $e');
      }

      if (attempt < retries - 1) {
        print('Retrying device discovery...');
        await Future.delayed(Duration(seconds: 1));
      }
    }

    // Merge new devices with cached devices
    List<RokuDevice> allDevices = [...cachedDevices];
    for (var newDevice in newDevices) {
      int existingIndex = allDevices.indexWhere((device) => device.name == newDevice.name);
      if (existingIndex != -1) {
        // Update IP if it has changed
        if (allDevices[existingIndex].ip != newDevice.ip) {
          allDevices[existingIndex] = newDevice;
        }
      } else {
        // Add new device
        allDevices.add(newDevice);
      }
    }

    await _cacheDevices(allDevices);
    print('Total devices (including cached): ${allDevices.length}');
    return allDevices;
  }

  static Future<RokuDevice?> checkDevice(String ip, {int timeout = 5000}) async {
    try {
      final response = await http.get(Uri.parse('http://$ip:8060/query/device-info'))
          .timeout(Duration(milliseconds: timeout));
      if (response.statusCode == 200) {
        final deviceInfo = xml.XmlDocument.parse(response.body);
        final friendlyName = deviceInfo.findAllElements('friendly-device-name').firstOrNull?.text ?? 'Unknown Roku';
        print('Device found at $ip: $friendlyName');
        return RokuDevice(ip, friendlyName);
      }
    } on TimeoutException {
      print('Timeout checking device at $ip');
    } on SocketException {
      print('Socket exception checking device at $ip');
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

  static Future<void> sendLiteralCommand(String ip, String text) async {
    try {
      for (int i = 0; i < text.length; i++) {
        final char = text[i];
        final encodedChar = Uri.encodeComponent(char);
        final response = await http.post(Uri.parse('http://$ip:8060/keypress/Lit_$encodedChar'));
        print('Sent literal command "$char" to $ip. Response: ${response.statusCode}');
        if (response.statusCode != 200) {
          throw Exception('Failed to send character: $char. Status code: ${response.statusCode}');
        }
        // Add a small delay between requests to avoid overwhelming the device
        await Future.delayed(Duration(milliseconds: 100));
      }
      print('Successfully sent all characters of "$text" to $ip');
    } catch (e) {
      print('Error sending literal command "$text" to $ip: $e');
    }
  }

  static Future<List<RokuDevice>> getCachedDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final String? deviceJson = prefs.getString(_cachedDevicesKey);
    if (deviceJson != null) {
      final List<dynamic> deviceList = json.decode(deviceJson);
      return deviceList.map((device) => RokuDevice.fromJson(device)).toList();
    }
    return [];
  }

  static Future<void> _cacheDevices(List<RokuDevice> devices) async {
    final prefs = await SharedPreferences.getInstance();
    final String deviceJson = json.encode(devices.map((device) => device.toJson()).toList());
    await prefs.setString(_cachedDevicesKey, deviceJson);
  }

  static Future<void> deleteDevice(RokuDevice device) async {
    List<RokuDevice> devices = await getCachedDevices();
    devices.removeWhere((d) => d.ip == device.ip && d.name == device.name);
    await _cacheDevices(devices);
  }

  // New method to add a device
  static Future<void> addDevice(RokuDevice newDevice) async {
    List<RokuDevice> devices = await getCachedDevices();
    devices.add(newDevice);
    await _cacheDevices(devices);
  }

  // New method to save device order
  static Future<void> saveDeviceOrder(List<RokuDevice> orderedDevices) async {
    await _cacheDevices(orderedDevices);
  }
}