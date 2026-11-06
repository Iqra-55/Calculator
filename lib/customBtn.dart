import 'package:flutter/material.dart';

class CustomBtn extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color textColor;
  final Color bgColor;

  const CustomBtn({
    super.key,
    required this.text,
    required this.onPressed,
    required this.textColor,
    required this.bgColor,
  });

  @override
  State<CustomBtn> createState() => _CustomBtnState();
}

class _CustomBtnState extends State<CustomBtn> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => isPressed = true);
      },
      onTapUp: (_) {
        setState(() => isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() => isPressed = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        decoration: BoxDecoration(
          // Soft rounded rectangle - image 2 style
          borderRadius: BorderRadius.circular(isLandscape ? 16 : 20),
          color: widget.bgColor,
          boxShadow: isPressed
              ? [
                  BoxShadow(
                    color: Colors.black26,
                    offset: const Offset(1.5, 1.5),
                    blurRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: isDarkMode ? Colors.black54 : Colors.black12,
                    offset: const Offset(3, 3),
                    blurRadius: 4,
                  ),
                  BoxShadow(
                    color: isDarkMode ? Colors.white10 : Colors.white,
                    offset: const Offset(-2, -2),
                    blurRadius: 4,
                  ),
                ],
        ),
        child: SizedBox.expand(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: isLandscape ? 14 : 26,
                    fontWeight: FontWeight.w600,
                    color: widget.textColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}