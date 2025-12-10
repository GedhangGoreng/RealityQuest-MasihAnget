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
    // ✅ CEK: Apakah misi sudah expired?
    final bool isExpired = mission.isExpired;
    final bool canToggle = !isExpired; // Hanya bisa toggle kalo belum expired

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
                      color: mission.isCompleted ? Colors.grey : 
                            isExpired ? Colors.grey.shade600 : Colors.black,
                    ),
                  ),
                ),
                // ✅ Badge status dengan kondisi expired
                if (isExpired && !mission.isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '⌛ KEDALUARSA',
                      style: TextStyle(
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
                    child: const Text(
                      '✓ SELESAI',
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
                Icon(
                  Icons.calendar_today, 
                  size: 14, 
                  color: isExpired ? Colors.grey : Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  'Deadline: ${formatDate(mission.deadline)} ${formatTime(mission.deadline)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isExpired ? Colors.grey : Colors.grey,
                    fontWeight: isExpired ? FontWeight.normal : FontWeight.normal,
                  ),
                ),
                if (isExpired) const SizedBox(width: 6),
                if (isExpired) 
                  Icon(Icons.notifications_off, size: 14, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 12),

            // ===== Action Buttons =====
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Edit button (tetap bisa edit meskipun expired)
                IconButton(
                  icon: Icon(Icons.edit, 
                    color: isExpired ? Colors.grey.shade400 : Colors.blue, 
                    size: 20),
                  onPressed: onEdit,
                  tooltip: 'Edit',
                ),
                // Delete button (tetap bisa delete)
                IconButton(
                  icon: Icon(Icons.delete, 
                    color: isExpired ? Colors.grey.shade400 : Colors.red, 
                    size: 20),
                  onPressed: onDelete,
                  tooltip: 'Hapus',
                ),
                const SizedBox(width: 8),
                
                // ✅ AREA TOMBOL UTAMA - BERUBAH TOTAL KALO EXPIRED
                if (isExpired && !mission.isCompleted)
                  // TAMPILAN KALO SUDAH KEDALUARSA
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.block, size: 16, color: Colors.grey),
                        SizedBox(width: 6),
                        Text(
                          'SUDAH KEDALUARSA',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  // TAMPILAN NORMAL (BELUM EXPIRED)
                  Row(
                    children: [
                      // Done button (Y)
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
                      // Fail button (X)
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