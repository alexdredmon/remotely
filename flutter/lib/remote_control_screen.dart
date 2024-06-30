import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'device_service.dart';
import 'remote_button.dart';

class RemoteControlScreen extends StatefulWidget {
  final TvDevice device;

  const RemoteControlScreen({super.key, required this.device});

  @override
  _RemoteControlScreenState createState() => _RemoteControlScreenState();
}

class _RemoteControlScreenState extends State<RemoteControlScreen> {
  void _sendCommand(String command) {
    DeviceService.sendCommand(widget.device.ip, command);
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
                          backgroundColor: Colors.red[800],
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      ElevatedButton(
                        child: Text('OK', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan[900],
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          if (inputText.isNotEmpty) {
                            DeviceService.sendLiteralCommand(widget.device.ip, inputText);
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
          RemoteButton(
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
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            RemoteButton(
                              onPressed: () => _sendCommand('Back'),
                              child: const Icon(Icons.west),
                            ),
                            RemoteButton(onPressed: () => _sendCommand('Home'), child: const Icon(Icons.home)),
                            RemoteButton(
                              onPressed: () => _showTextInputBottomSheet(context),
                              child: const Text('abc', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            RemoteButton(onPressed: () => _sendCommand('Rev'), child: const Icon(Icons.fast_rewind)),
                            RemoteButton(onPressed: () => _sendCommand('Play'), child: const Icon(Icons.play_arrow)),
                            RemoteButton(onPressed: () => _sendCommand('Fwd'), child: const Icon(Icons.fast_forward)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(width: 72),
                            RemoteButton(
                              onPressed: () => _sendCommand('InstantReplay'),
                              child: const Icon(Icons.replay_10),
                            ),
                            RemoteButton(
                              onPressed: () => _sendCommand('Info'),
                              child: const Icon(Icons.settings),
                              backgroundColor: Colors.cyan[900],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            RemoteButton(
                              onPressed: () => _sendCommand('VolumeMute'),
                              child: const Icon(Icons.volume_mute),
                              backgroundColor: Colors.amber[900],
                            ),
                            RemoteButton(
                              onPressed: () => _sendCommand('VolumeDown'),
                              child: const Icon(Icons.volume_down),
                              backgroundColor: Colors.amber[900],
                            ),
                            RemoteButton(
                              onPressed: () => _sendCommand('VolumeUp'),
                              child: const Icon(Icons.volume_up),
                              backgroundColor: Colors.amber[900],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RemoteButton(
                              onPressed: () => _sendCommand('Up'),
                              child: const Icon(Icons.arrow_upward),
                              backgroundColor: Colors.cyan[900],
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                RemoteButton(
                                  onPressed: () => _sendCommand('Left'),
                                  child: const Icon(Icons.arrow_back),
                                  backgroundColor: Colors.cyan[900],
                                ),
                                SizedBox(width: 20),
                                RemoteButton(
                                  onPressed: () => _sendCommand('Select'),
                                  child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
                                  backgroundColor: Colors.cyan[900],
                                ),
                                SizedBox(width: 20),
                                RemoteButton(
                                  onPressed: () => _sendCommand('Right'),
                                  child: const Icon(Icons.arrow_forward),
                                  backgroundColor: Colors.cyan[900],
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            RemoteButton(
                              onPressed: () => _sendCommand('Down'),
                              child: const Icon(Icons.arrow_downward),
                              backgroundColor: Colors.cyan[900],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}