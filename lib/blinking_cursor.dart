import 'package:flutter/material.dart';

class BlinkingCursor extends StatefulWidget {
  final double height; // Dynamic height parameter
  const BlinkingCursor({super.key, this.height = 45});

  @override
  State<BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<BlinkingCursor> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    // 1. Duration ko 300ms kiya taake blink fast ho jaye
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // 2. Abrupt toggle logic: Ya to cursor poora dikhega ya bilkul gayab (No fading/light color)
    _controller.addListener(() {
      setState(() {
        _isVisible = _controller.value < 0.5;
      });
    });

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Visibility(
      visible: _isVisible,
      maintainSize: true,      // Size maintain rakhne se text type karte hue vibration/jhatka nahi lagega
      maintainAnimation: true,
      maintainState: true,
      child: Container(
        margin: const EdgeInsets.only(left: 4),
        width: 4.0,            // 3. Width ko thoda zyada kar diya taake bold dikhe
        height: widget.height, // Parent se mili hui height setup
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white : Colors.black, // Solid exact colors
          borderRadius: BorderRadius.circular(2.0),
        ),
      ),
    );
  }
}