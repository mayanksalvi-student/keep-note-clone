import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';

class KeepNoteCard extends StatelessWidget {
  final String title;
  final String content;
  final bool isPinned;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onPinTap;
  final Color? color;
  final List<String> labels;

  const KeepNoteCard({super.key, 
    required this.title,
    required this.content,
    required this.onTap,
    this.onLongPress,
    this.onPinTap,
    this.isPinned = false,
    this.color,
    this.labels = const [],
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Expanded(
              child: Text(
                content,
                style: TextStyle(fontSize: 14),
                overflow: TextOverflow.fade,
              ),
            ),
            if (labels.isNotEmpty)
              Wrap(
                spacing: 6,
                children: labels
                    .map((label) => Chip(label: Text(label)))
                    .toList(),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(),
                IconButton(
                  icon: Icon(
                    isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    size: 18,
                  ),
                  onPressed: onPinTap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
