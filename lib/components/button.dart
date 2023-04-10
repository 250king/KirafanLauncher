import "package:flutter/material.dart";

class Button extends StatelessWidget {
  const Button({super.key, required this.text, required this.action});

  final String text;

  final void Function() action;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: action,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        minimumSize: const Size.fromHeight(90)
      ),
      child: Text(text)
    );
  }
}
