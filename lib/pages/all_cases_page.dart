import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/db.dart';
import '../models/surgery_case.dart';

class AllCasesPage extends StatelessWidget {
  const AllCasesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd-MM-yyyy');
    return Scaffold(
      appBar: AppBar(title: const Text('Tất cả ca hậu phẫu')),
      body: FutureBuilder<List<SurgeryCase>>(
        future: VetcareDb().allCases(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final list = snap.data!;
          if (list.isEmpty) return const Center(child: Text('Chưa có dữ liệu.'));
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final c = list[i];
              return ListTile(
                title: Text(c.petName),
                subtitle: Text('SDT: ${c.phone} • ${c.classType} • D+10: ${df.format(c.dueDate)} • ${c.status}'),
              );
            },
          );
        },
      ),
    );
  }
}
