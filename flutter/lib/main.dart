import 'package:flutter/material.dart';
import 'roku_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roku Remote',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
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
    _discoverDevices();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Select Roku Device'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: TextStyle(color: Colors.red)))
              : _devices.isEmpty
                  ? Center(child: Text('No Roku devices found'))
                  : ListView.builder(
                      itemCount: _devices.length,
                      itemBuilder: (context, index) {
                        final device = _devices[index];
                        return ListTile(
                          title: Text(device.name),
                          subtitle: Text(device.ip),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _discoverDevices,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class RemoteControlScreen extends StatelessWidget {
  final RokuDevice device;

  const RemoteControlScreen({super.key, required this.device});

  void _sendCommand(String command) {
    RokuService.sendCommand(device.ip, command);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(device.name),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _sendCommand('VolumeUp'),
                  child: const Text('Volume Up'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => _sendCommand('VolumeDown'),
                  child: const Text('Volume Down'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _sendCommand('Up'),
              child: const Icon(Icons.arrow_upward),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _sendCommand('Left'),
                  child: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => _sendCommand('Select'),
                  child: const Text('OK'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => _sendCommand('Right'),
                  child: const Icon(Icons.arrow_forward),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () => _sendCommand('Down'),
              child: const Icon(Icons.arrow_downward),
            ),
          ],
        ),
      ),
    );
  }
}