import 'package:flutter/material.dart';
import 'device_service.dart';
import 'macro_service.dart';

class MacroDrawer extends StatefulWidget {
  final TvDevice device;
  final VoidCallback onStartRecording;

  const MacroDrawer({
    Key? key,
    required this.device,
    required this.onStartRecording,
  }) : super(key: key);

  @override
  _MacroDrawerState createState() => _MacroDrawerState();
}

class _MacroDrawerState extends State<MacroDrawer> {
  List<Macro> _macros = [];

  @override
  void initState() {
    super.initState();
    _loadMacros();
  }

  Future<void> _loadMacros() async {
    final macros = await MacroService.getMacros();
    setState(() {
      _macros = macros;
    });
  }

  void _executeMacro(Macro macro) async {
    for (String action in macro.actions) {
      if (action.startsWith('Literal_')) {
        await DeviceService.sendLiteralCommand(widget.device.ip, action.substring(8));
      } else {
        await DeviceService.sendCommand(widget.device.ip, action);
      }
      await Future.delayed(Duration(milliseconds: 100)); // Small delay between actions
    }
  }

  void _deleteMacro(Macro macro) async {
    await MacroService.deleteMacro(macro.title);
    _loadMacros();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Macros',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _macros.length,
              itemBuilder: (context, index) {
                final macro = _macros[index];
                return ListTile(
                  leading: Icon(Icons.play_arrow, color: Colors.cyan[700]),
                  title: Text(macro.title),
                  onTap: () => _executeMacro(macro),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red[500],
                    ),
                    onPressed: () => _deleteMacro(macro),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              child: Text(
                'Record New Macro',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan[900],
                minimumSize: Size(double.infinity, 50), // full width
              ),
              onPressed: widget.onStartRecording,
            ),
          ),
        ],
      ),
    );
  }
}