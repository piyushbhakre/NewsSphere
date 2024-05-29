import 'package:flutter/material.dart';

class SettingsDialog extends StatefulWidget {
  final Map<String, bool> categories;
  final Function(Map<String, bool>) onSave;

  SettingsDialog({required this.categories, required this.onSave});

  @override
  _SettingsDialogState createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> with SingleTickerProviderStateMixin {
  late Map<String, bool> categories;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    categories = Map<String, bool>.from(widget.categories);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: AlertDialog(
        title: Text(
          'Select Categories',
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: categories.keys.map((String key) {
            return AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(1.0, 0.0),
                    end: Offset(0.0, 0.0),
                  ).animate(animation),
                  child: child,
                );
              },
              child: SwitchListTile(
                key: ValueKey<String>(key),
                title: Text(
                  key.capitalize(),
                  style: TextStyle(fontSize: 18.0),
                ),
                value: categories[key]!,
                onChanged: (bool value) {
                  setState(() {
                    categories[key] = value;
                  });
                },
                activeColor: Colors.deepPurple,
              ),
            );
          }).toList(),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.redAccent, fontSize: 16.0),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(
              'Save',
              style: TextStyle(color: Colors.green, fontSize: 16.0),
            ),
            onPressed: () {
              widget.onSave(categories);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return this[0].toUpperCase() + this.substring(1);
  }
}
