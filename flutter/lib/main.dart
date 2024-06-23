import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    _loadDevices();
  }

  Future<void> _loadDevices() async {
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
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _loadDevices,
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
      body: Focus(
        autofocus: true,
        onKey: (node, event) {
          if (event is RawKeyDownEvent) {
            switch (event.logicalKey) {
              case LogicalKeyboardKey.arrowUp:
                _sendCommand('Up');
                return KeyEventResult.handled;
              case LogicalKeyboardKey.arrowDown:
                _sendCommand('Down');
                return KeyEventResult.handled;
              case LogicalKeyboardKey.arrowLeft:
                _sendCommand('Left');
                return KeyEventResult.handled;
              case LogicalKeyboardKey.arrowRight:
                _sendCommand('Right');
                return KeyEventResult.handled;
              case LogicalKeyboardKey.enter:
                _sendCommand('Select');
                return KeyEventResult.handled;
              case LogicalKeyboardKey.backspace:
                _sendCommand('Back');
                return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => _sendCommand('Power'),
                    child: const Text('Power'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () => _sendCommand('Home'),
                    child: const Text('Home'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => _sendCommand('Back'),
                    child: const Text('Back'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () => _sendCommand('InstantReplay'),
                    child: const Icon(Icons.replay),
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
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => _sendCommand('VolumeDown'),
                    child: const Icon(Icons.volume_down),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () => _sendCommand('VolumeMute'),
                    child: const Icon(Icons.volume_mute),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () => _sendCommand('VolumeUp'),
                    child: const Icon(Icons.volume_up),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => _sendCommand('Rev'),
                    child: const Icon(Icons.fast_rewind),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () => _sendCommand('Play'),
                    child: const Icon(Icons.play_arrow),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () => _sendCommand('Fwd'),
                    child: const Icon(Icons.fast_forward),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}