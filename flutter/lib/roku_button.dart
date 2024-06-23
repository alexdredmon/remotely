import 'package:flutter/material.dart';

class RokuButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const RokuButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(16),
          shape: CircleBorder(),
          backgroundColor: backgroundColor ?? Colors.blueGrey[800],
          foregroundColor: foregroundColor ?? Colors.white,
        ),
        child: FittedBox(
          fit: BoxFit.contain,
          child: child,
        ),
      ),
    );
  }
}