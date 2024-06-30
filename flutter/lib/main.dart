import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'roku_service.dart';
import 'remote_control_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
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
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.white),
          hintStyle: TextStyle(color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
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

  Future<void> _confirmDeleteDevice(RokuDevice device) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('❌ Confirm Delete'),
          content: Text('Are you sure you want to delete device ${device.name}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white)
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white)
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _deleteDevice(device);
    }
  }

  Future<void> _deleteDevice(RokuDevice device) async {
    await RokuService.deleteDevice(device);
    setState(() {
      _devices.removeWhere((d) => d.ip == device.ip && d.name == device.name);
    });
  }

  void _addDevice() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditDeviceScreen(
          onDeviceSaved: (RokuDevice newDevice) {
            setState(() {
              _devices.add(newDevice);
            });
            RokuService.addDevice(newDevice);
          },
        ),
      ),
    );
  }

  void _editDevice(RokuDevice device) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditDeviceScreen(
          device: device,
          onDeviceSaved: (RokuDevice updatedDevice) {
            setState(() {
              final index = _devices.indexWhere((d) => d.ip == device.ip && d.name == device.name);
              if (index != -1) {
                _devices[index] = updatedDevice;
              }
            });
            RokuService.saveDeviceOrder(_devices);
          },
        ),
      ),
    );
  }

  void _reorderDevices(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final RokuDevice item = _devices.removeAt(oldIndex);
      _devices.insert(newIndex, item);
    });
    RokuService.saveDeviceOrder(_devices);
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
                : ReorderableListView.builder(
                    itemCount: _devices.length,
                    itemBuilder: (context, index) {
                      final device = _devices[index];
                      return ListTile(
                        key: ValueKey(device),
                        title: Text(device.name),
                        subtitle: Text(device.ip),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _editDevice(device);
                            } else if (value == 'delete') {
                              _confirmDeleteDevice(device);
                            }
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
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
                    onReorder: _reorderDevices,
                  ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _addDevice,
            tooltip: 'Add Device',
            child: const Icon(Icons.add, color: Colors.white),
            backgroundColor: Colors.blueGrey[800],
            shape: CircleBorder(),
            heroTag: null,
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _discoverDevices,
            tooltip: 'Refresh',
            child: const Icon(Icons.refresh, color: Colors.white),
            backgroundColor: Colors.blueGrey[800],
            shape: CircleBorder(),
            heroTag: null,
          ),
        ],
      ),
    );
  }
}

class AddEditDeviceScreen extends StatefulWidget {
  final Function(RokuDevice) onDeviceSaved;
  final RokuDevice? device;

  const AddEditDeviceScreen({Key? key, required this.onDeviceSaved, this.device}) : super(key: key);

  @override
  _AddEditDeviceScreenState createState() => _AddEditDeviceScreenState();
}

class _AddEditDeviceScreenState extends State<AddEditDeviceScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _deviceName;
  late String _ipAddress;

  @override
  void initState() {
    super.initState();
    _deviceName = widget.device?.name ?? '';
    _ipAddress = widget.device?.ip ?? '';
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final device = RokuDevice(_ipAddress, _deviceName);
      widget.onDeviceSaved(device);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.device != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Device' : 'Add Device'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                initialValue: _deviceName,
                decoration: InputDecoration(
                  labelText: 'Device Name',
                  hintText: 'Enter device name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a device name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _deviceName = value!;
                },
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _ipAddress,
                decoration: InputDecoration(
                  labelText: 'IP Address',
                  hintText: 'Enter IP address',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an IP address';
                  }
                  // You can add more sophisticated IP address validation here
                  return null;
                },
                onSaved: (value) {
                  _ipAddress = value!;
                },
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(isEditing ? 'Save Changes' : 'Add Device', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[800],
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}