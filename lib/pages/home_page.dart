import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/db.dart';
import '../models/surgery_case.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<SurgeryCase>> _future;

  @override
  void initState() {
    super.initState();
    _future = VetcareDb().casesDueOn(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd-MM-yyyy');
    return Scaffold(
      appBar: AppBar(title: const Text('VetCare — Hôm nay đến hạn')),
      body: FutureBuilder<List<SurgeryCase>>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snap.data!;
          if (list.isEmpty) {
            return const Center(child: Text('Hôm nay không có ca đến hạn.'));
          }
          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final c = list[i];
              return ListTile(
                title: Text(c.petName),
                subtitle: Text('SDT: ${c.phone}  •  D+10: ${df.format(c.dueDate)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.call),
                  onPressed: () async {
                    // TODO: mở tel: bằng url_launcher
                  },
                ),
                onTap: () async {
                  // TODO: mở chi tiết hoặc đánh dấu done
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/import'),
        child: const Icon(Icons.upload_file),
      ),
    );
  }
}
