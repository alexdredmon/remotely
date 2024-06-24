import 'package:flutter/material.dart';

class RokuButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isPowerButton;

  const RokuButton({
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
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.5,
                colors: isPowerButton
                    ? [Colors.red[900]!, Colors.red[800]!]
                    : [Colors.blueGrey[900]!, Colors.blueGrey[900]!],
                stops: [0.0, 1.0],
              ),
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
