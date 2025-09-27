import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/parser.dart';
import '../services/db.dart';
import '../services/notifications.dart';
import '../models/surgery_case.dart';

class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  List<SurgeryCase> parsed = [];
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd-MM-yyyy');
    return Scaffold(
      appBar: AppBar(title: const Text('Nạp file tuần (PDF)')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: loading ? null : _pick,
              icon: const Icon(Icons.file_open),
              label: const Text('Chọn file PDF'),
            ),
          ),
          if (loading) const LinearProgressIndicator(),
          Expanded(
            child: ListView.separated(
              itemCount: parsed.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final c = parsed[i];
                return ListTile(
                  title: Text(c.petName),
                  subtitle: Text('SDT: ${c.phone}  •  Ngày mổ: ${df.format(c.surgeryDate)}  •  D+10: ${df.format(c.dueDate)}'),
                );
              },
            ),
          ),
          if (parsed.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Lưu & Lên lịch nhắc'),
              ),
            )
        ],
      ),
    );
  }

  Future<void> _pick() async {
    setState(() => loading = true);
    try {
      final res = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
      if (res != null && res.files.single.path != null) {
        final file = File(res.files.single.path!);
        final list = await VetcareParser.parsePdf(file);
        setState(() => parsed = list);
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _save() async {
    await VetcareDb().insertMany(parsed);
    for (final c in parsed) {
      final at = DateTime(c.dueDate.year, c.dueDate.month, c.dueDate.day, 8, 0);
      await NotiService().scheduleOneTime(
        c.hashCode & 0x7fffffff,
        at,
        body: 'Ca của ${c.petName} (SDT ${c.phone}) đến hạn cắt chỉ hôm nay.',
      );
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã lưu & lên lịch nhắc.')));
      Navigator.pop(context);
    }
  }
}
