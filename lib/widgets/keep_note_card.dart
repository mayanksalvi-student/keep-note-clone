import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';

class KeepNoteCard extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onTap;
  final VoidCallback? onLongPress; // Optional long press callback
  final VoidCallback? onPinTap; // Optional pin tap callback
  final bool isPinned;
  final int color;
  final List<String> labels;

  const KeepNoteCard({super.key, 
    required this.title,
    required this.content,
    required this.onTap,
    this.onLongPress,
    this.onPinTap, // <-- yaha add karna important hai
    this.isPinned = false,
    this.color = 0xFFFFFFFF,
    this.labels = const [],
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(color),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(1, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppFonts.noteTitle),
            SizedBox(height: 8),
            Expanded(
              child: Text(
                content,
                style: AppFonts.noteContent,
                overflow: TextOverflow.fade,
              ),
            ),
            if (labels.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Wrap(
                  spacing: 6.0,
                  runSpacing: 6.0,
                  children: labels
                      .map((label) => Chip(
                            label: Text(label),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ))
                      .toList(),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Aap agar chahen to yeh line hata sakte hain kyunki already upar title hai
                // Text(title, style: AppFonts.noteTitle),
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
