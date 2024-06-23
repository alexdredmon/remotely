import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'roku_service.dart';
import 'roku_button.dart';

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
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    RokuButton(onPressed: () => _sendCommand('Power'), child: const Text('Power')),
                    RokuButton(onPressed: () => _sendCommand('Home'), child: const Text('Home')),
                    RokuButton(onPressed: () => _sendCommand('Back'), child: const Text('Back')),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RokuButton(onPressed: () => _sendCommand('Up'), child: const Icon(Icons.arrow_upward)),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RokuButton(onPressed: () => _sendCommand('Left'), child: const Icon(Icons.arrow_back)),
                        SizedBox(width: 20),
                        RokuButton(onPressed: () => _sendCommand('Select'), child: const Text('OK')),
                        SizedBox(width: 20),
                        RokuButton(onPressed: () => _sendCommand('Right'), child: const Icon(Icons.arrow_forward)),
                      ],
                    ),
                    SizedBox(height: 10),
                    RokuButton(onPressed: () => _sendCommand('Down'), child: const Icon(Icons.arrow_downward)),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        RokuButton(onPressed: () => _sendCommand('VolumeDown'), child: const Icon(Icons.volume_down)),
                        RokuButton(onPressed: () => _sendCommand('VolumeMute'), child: const Icon(Icons.volume_mute)),
                        RokuButton(onPressed: () => _sendCommand('VolumeUp'), child: const Icon(Icons.volume_up)),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        RokuButton(onPressed: () => _sendCommand('Rev'), child: const Icon(Icons.fast_rewind)),
                        RokuButton(onPressed: () => _sendCommand('Play'), child: const Icon(Icons.play_arrow)),
                        RokuButton(onPressed: () => _sendCommand('Fwd'), child: const Icon(Icons.fast_forward)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}