import 'package:flutter/material.dart';

class SeasonToggleButton extends StatelessWidget {
  final bool isActive;
  final String label;
  final VoidCallback onPressed;
  final Color activeColor;
  final IconData? activeIcon;

  const SeasonToggleButton({
    required this.isActive,
    required this.label,
    required this.onPressed,
    this.activeColor = Colors.black,
    this.activeIcon = Icons.check,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? activeColor : Colors.white60,
        minimumSize: const Size(65, 35),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive)
            Icon(
              activeIcon,
              color: isActive ? Colors.black : Colors.grey,
              size: 18,
            ),
          if (isActive) const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color:  isActive ? Colors.black : Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

