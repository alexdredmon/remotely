import 'package:flutter/material.dart';

class RokuButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const RokuButton({
    Key? key,
    required this.onPressed,
    required this.child,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: Colors.blueGrey[800],
          foregroundColor: Colors.white,
        ),
        child: FittedBox(
          fit: BoxFit.contain,
          child: child,
        ),
      ),
    );
  }
}