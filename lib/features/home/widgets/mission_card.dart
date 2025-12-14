import 'package:flutter/material.dart';
import '../../../core/database/models/quest_model.dart';
import '../../../core/localization/app_locale.dart';

class MissionCard extends StatelessWidget {
  final Quest mission;
  final AppLocale locale;
  final VoidCallback onDone;
  final VoidCallback onFail;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MissionCard({
    super.key,
    required this.mission,
    required this.locale,
    required this.onDone,
    required this.onFail,
    required this.onEdit,
    required this.onDelete,
  });

  // ✅ TAMBAHKAN METHOD INI
  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';
  }

  // ✅ TAMBAHKAN METHOD INI
  String _formatTime(DateTime d) {
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isExpired = mission.isExpired;
    final bool canToggle = !isExpired;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isExpired ? Colors.grey.shade400 : Colors.transparent,
          width: isExpired ? 1.5 : 0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      color: mission.isCompleted ? Colors.grey : 
                            isExpired ? Colors.grey.shade600 : Colors.black,
                    ),
                  ),
                ),
                if (isExpired && !mission.isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      locale.expiredBadge,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else if (mission.isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      locale.completedBadge,
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Icon(
                  Icons.calendar_today, 
                  size: 14, 
                  color: isExpired ? Colors.grey : Colors.grey,
                ),
                const SizedBox(width: 6),
                // ✅ GUNAKAN METHOD _formatDate dan _formatTime
                Text(
                  '${locale.deadlineLabel}: ${_formatDate(mission.deadline)} ${_formatTime(mission.deadline)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isExpired ? Colors.grey : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, 
                    color: isExpired ? Colors.grey.shade400 : Colors.blue, 
                    size: 20),
                  onPressed: onEdit,
                  tooltip: locale.edit,
                ),
                IconButton(
                  icon: Icon(Icons.delete, 
                    color: isExpired ? Colors.grey.shade400 : Colors.red, 
                    size: 20),
                  onPressed: onDelete,
                  tooltip: locale.delete,
                ),
                const SizedBox(width: 8),
                
                if (isExpired && !mission.isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.block, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          locale.expiredBadge,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: canToggle && !mission.isCompleted ? onDone : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canToggle ? Colors.green : Colors.grey.shade300,
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
                      ElevatedButton(
                        onPressed: canToggle && mission.isCompleted ? onFail : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canToggle ? Colors.red : Colors.grey.shade300,
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
          ],
        ),
      ),
    );
  }
}