// lib/features/quest/add_quest_page.dart
import 'package:flutter/material.dart';
import '../../core/database/models/quest_model.dart';
import '../../core/localization/app_locale.dart'; // ✅ IMPORT

class AddQuestPage extends StatefulWidget {
  final Quest? initial;
  final Function(Quest) onSave;
  final AppLocale locale; // ✅ TAMBAH PARAMETER

  const AddQuestPage({
    super.key, 
    this.initial, 
    required this.onSave,
    required this.locale, // ✅ REQUIRED
  });

  @override
  State<AddQuestPage> createState() => _AddQuestPageState();
}

class _AddQuestPageState extends State<AddQuestPage> {
  late TextEditingController titleController;
  DateTime? chosenDate;
  TimeOfDay? chosenTime;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.initial?.title ?? '');
    chosenDate = widget.initial?.deadline;
    chosenTime = widget.initial?.deadline != null
        ? TimeOfDay.fromDateTime(widget.initial!.deadline)
        : null;
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  void pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: chosenDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => chosenDate = picked);
  }

  void pickTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: chosenTime ?? now,
    );
    if (picked != null) setState(() => chosenTime = picked);
  }

  void save() {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.locale.isEnglish 
              ? 'Mission name cannot be empty!' 
              : 'Nama misi tidak boleh kosong!'),
        ),
      );
      return;
    }

    final deadline = chosenDate != null && chosenTime != null
        ? DateTime(
            chosenDate!.year,
            chosenDate!.month,
            chosenDate!.day,
            chosenTime!.hour,
            chosenTime!.minute,
          )
        : chosenDate ?? DateTime.now().add(const Duration(days: 1));

    final quest = Quest(
      title: title,
      isCompleted: widget.initial?.isCompleted ?? false,
      deadline: deadline,
      rewardCoins: 1,
    );

    widget.onSave(quest);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initial == null 
            ? widget.locale.addQuestTitle 
            : widget.locale.editQuestTitle),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== NAMA MISI =====
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: widget.locale.missionName,
                hintText: widget.locale.missionHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // ===== TANGGAL =====
            Text(
              widget.locale.deadlineDate,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: pickDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.purple),
                    const SizedBox(width: 12),
                    Text(
                      chosenDate == null
                          ? widget.locale.selectDate
                          : '${chosenDate!.day}-${chosenDate!.month}-${chosenDate!.year}',
                      style: TextStyle(
                        fontSize: 16,
                        color: chosenDate == null ? Colors.grey : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ===== WAKTU =====
            Text(
              widget.locale.deadlineTime,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: pickTime,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.purple),
                    const SizedBox(width: 12),
                    Text(
                      chosenTime == null
                          ? widget.locale.selectTime
                          : '${chosenTime!.hour.toString().padLeft(2, '0')}:${chosenTime!.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 16,
                        color: chosenTime == null ? Colors.grey : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ===== REWARD =====
            Text(
              widget.locale.reward,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Row(
                children: [
                  Icon(Icons.monetization_on, color: Colors.amber),
                  SizedBox(width: 8),
                  Text(
                    '1 Koin',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // ===== SIMPAN =====
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  widget.locale.saveMission,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}