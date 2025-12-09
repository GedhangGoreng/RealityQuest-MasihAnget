// lib/features/home/widgets/mission_card.dart
import 'package:flutter/material.dart';
import '../../../core/database/models/quest_model.dart';

class MissionCard extends StatelessWidget {
  final Quest mission;
  final VoidCallback onDone;
  final VoidCallback onFail;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MissionCard({
    super.key,
    required this.mission,
    required this.onDone,
    required this.onFail,
    required this.onEdit,
    required this.onDelete,
  });

  String formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';
  }

  String formatTime(DateTime d) {
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Title + Status =====
            Row(
              children: [
                Expanded(
                  child: Text(
                    mission.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      decoration: mission.isCompleted 
                          ? TextDecoration.lineThrough 
                          : TextDecoration.none,
                      color: mission.isCompleted ? Colors.grey : Colors.black,
                    ),
                  ),
                ),
                // ✅ Badge status
                if (mission.isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '✓ Selesai',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // ===== Deadline Info =====
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  'Deadline: ${formatDate(mission.deadline)} ${formatTime(mission.deadline)}',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ===== Action Buttons =====
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Edit button
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                  onPressed: onEdit,
                  tooltip: 'Edit',
                ),
                // Delete button
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: onDelete,
                  tooltip: 'Hapus',
                ),
                const SizedBox(width: 8),
                // Done button (Y)
                ElevatedButton(
                  onPressed: mission.isCompleted ? null : onDone,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(45, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('✓', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 6),
                // Fail button (X)
                ElevatedButton(
                  onPressed: !mission.isCompleted ? null : onFail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(45, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('✗', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}