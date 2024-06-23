import 'package:flutter/material.dart';
import 'roku_service.dart';
import 'remote_control_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Remotely',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        colorScheme: ColorScheme.dark(
          primary: Colors.blueGrey[800]!,
          secondary: Colors.blueGrey[600]!,
        ),
      ),
      home: const DeviceListScreen(),
    );
  }
}

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({super.key});

  @override
  _DeviceListScreenState createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  List<RokuDevice> _devices = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCachedDevices();
    _discoverDevices();
  }

  Future<void> _loadCachedDevices() async {
    final cachedDevices = await RokuService.getCachedDevices();
    setState(() {
      _devices = cachedDevices;
    });
  }

  Future<void> _discoverDevices() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      print('Starting device discovery');
      final devices = await RokuService.discoverDevices();
      setState(() {
        _devices = devices;
        _isLoading = false;
      });
      print('Device discovery completed. Found ${devices.length} devices.');
    } catch (e) {
      print('Error during device discovery: $e');
      setState(() {
        _error = 'Failed to discover devices: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteDevice(RokuDevice device) async {
    await RokuService.deleteDevice(device);
    setState(() {
      _devices.removeWhere((d) => d.ip == device.ip && d.name == device.name);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Device'),
      ),
      body: Column(
        children: [
          if (_isLoading)
            LinearProgressIndicator(),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(_error!, style: TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: _devices.isEmpty
                ? Center(child: Text('No devices found'))
                : ListView.builder(
                    itemCount: _devices.length,
                    itemBuilder: (context, index) {
                      final device = _devices[index];
                      return ListTile(
                        title: Text(device.name),
                        subtitle: Text(device.ip),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red[300]),
                          onPressed: () => _deleteDevice(device),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RemoteControlScreen(device: device),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _discoverDevices,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh, color: Colors.white),
        backgroundColor: Colors.blueGrey[800],
        shape: CircleBorder(),
      ),
    );
  }
}