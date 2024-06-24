import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'roku_service.dart';
import 'roku_button.dart';

class RemoteControlScreen extends StatefulWidget {
  final RokuDevice device;

  const RemoteControlScreen({super.key, required this.device});

  @override
  _RemoteControlScreenState createState() => _RemoteControlScreenState();
}

class _RemoteControlScreenState extends State<RemoteControlScreen> {
  void _sendCommand(String command) {
    RokuService.sendCommand(widget.device.ip, command);
    print('Sent command: $command'); // Log the command
  }

  @override
  void initState() {
    super.initState();
    _initVolumeButtonListener();
  }

  void _initVolumeButtonListener() {
    HardwareKeyboard.instance.addHandler(_handleKeyPress);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyPress);
    super.dispose();
  }

  bool _handleKeyPress(KeyEvent event) {
    print('Key event detected: ${event.logicalKey}'); // Log all key events

    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      if (event.physicalKey == PhysicalKeyboardKey.audioVolumeUp) {
        print('Volume Up detected');
        _sendCommand('VolumeUp');
        return true;
      } else if (event.physicalKey == PhysicalKeyboardKey.audioVolumeDown) {
        print('Volume Down detected');
        _sendCommand('VolumeDown');
        return true;
      }
    }
    return false;
  }

  Future<void> _showTextInputBottomSheet(BuildContext context) async {
    String inputText = '';
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Enter Text',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    autofocus: true,
                    onChanged: (value) {
                      inputText = value;
                    },
                    decoration: InputDecoration(
                      hintText: "Enter your text here",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        child: Text('CANCEL', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      ElevatedButton(
                        child: Text('OK', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey[800],
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          if (inputText.isNotEmpty) {
                            RokuService.sendLiteralCommand(widget.device.ip, inputText);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name),
        leading: IconButton(
          icon: Icon(Icons.west),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          RokuButton(
            onPressed: () => _sendCommand('Power'),
            child: const Icon(Icons.power_settings_new),
            isPowerButton: true,
          ),
        ],
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RokuButton(
                  onPressed: () => _sendCommand('Back'),
                  child: const Icon(Icons.west),
                ),
                RokuButton(onPressed: () => _sendCommand('Home'), child: const Icon(Icons.home)),
                RokuButton(
                  onPressed: () => _showTextInputBottomSheet(context),
                  child: const Text('abc', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                RokuButton(
                  onPressed: () => _sendCommand('VolumeUp'),
                  child: const Icon(Icons.volume_up),
                  backgroundColor: Colors.amber[800],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RokuButton(onPressed: () => _sendCommand('Rev'), child: const Icon(Icons.fast_rewind)),
                RokuButton(onPressed: () => _sendCommand('Play'), child: const Icon(Icons.play_arrow)),
                RokuButton(onPressed: () => _sendCommand('Fwd'), child: const Icon(Icons.fast_forward)),
                RokuButton(
                  onPressed: () => _sendCommand('VolumeDown'),
                  child: const Icon(Icons.volume_down),
                  backgroundColor: Colors.amber[800],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(width: 72),
                RokuButton(
                  onPressed: () => _sendCommand('InstantReplay'),
                  child: const Icon(Icons.replay_10),
                ),
                RokuButton(
                  onPressed: () => _sendCommand('Info'),
                  child: const Text('*', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                RokuButton(
                  onPressed: () => _sendCommand('VolumeMute'),
                  child: const Icon(Icons.volume_mute),
                  backgroundColor: Colors.amber[800],
                ),
              ],
            ),
            
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RokuButton(
                  onPressed: () => _sendCommand('Up'),
                  child: const Icon(Icons.arrow_upward),
                  backgroundColor: Colors.cyan[900],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RokuButton(
                      onPressed: () => _sendCommand('Left'),
                      child: const Icon(Icons.arrow_back),
                      backgroundColor: Colors.cyan[900],
                    ),
                    SizedBox(width: 20),
                    RokuButton(
                      onPressed: () => _sendCommand('Select'),
                      child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
                      backgroundColor: Colors.cyan[900],
                    ),
                    SizedBox(width: 20),
                    RokuButton(
                      onPressed: () => _sendCommand('Right'),
                      child: const Icon(Icons.arrow_forward),
                      backgroundColor: Colors.cyan[900],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                RokuButton(
                  onPressed: () => _sendCommand('Down'),
                  child: const Icon(Icons.arrow_downward),
                  backgroundColor: Colors.cyan[900],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}