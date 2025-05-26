import 'package:flutter/material.dart';

class Option extends StatelessWidget {
  final IconData? icon;
  final String label;
  final String? description; // Added description
  final bool selected;
  final VoidCallback onTap;
  final Widget? leadingWidget;

  const Option({
    super.key,
    this.icon,
    required this.label,
    this.description, // Added description
    required this.selected,
    required this.onTap,
    this.leadingWidget,
  }) : assert(
         icon != null ||
             leadingWidget != null ||
             description !=
                 null, // Allow if only label and description are present
         'Either icon, leadingWidget or description must be provided if label is the only other required field for visual output',
       );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? Colors.black12 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            if (leadingWidget != null)
              leadingWidget!
            else if (icon != null)
              Icon(icon, color: Colors.black87),
            if (leadingWidget != null ||
                icon != null) // Add spacing only if there's a leading element
              const SizedBox(width: 16),
            Expanded(
              // Use Expanded to allow text to wrap and take available space
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (description != null && description!.isNotEmpty) ...[
                    const SizedBox(
                      height: 4,
                    ), // Space between label and description
                    Text(
                      description!,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
