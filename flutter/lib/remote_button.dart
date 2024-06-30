import 'package:flutter/material.dart';

class RemoteButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isPowerButton;

  const RemoteButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.isPowerButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 70,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPowerButton
                  ? Colors.red[800]
                  : backgroundColor ?? Colors.blueGrey[800],
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                customBorder: CircleBorder(),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}