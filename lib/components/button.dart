import "package:flutter/material.dart";

class Button extends StatelessWidget {
  const Button({super.key, required this.text, this.subtext = "", required this.icon, required this.action});

  final String text;

  final String subtext;

  final IconData icon;

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
      child: subtext.isEmpty? ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon)
          ],
        ),
        title: Text(text)
      ): ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon)
          ],
        ),
        title: Text(text),
        subtitle: Text(subtext),
      )
    );
  }
}
