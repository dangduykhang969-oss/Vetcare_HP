import 'dart:io';
import 'package:intl/intl.dart';
import 'package:pdf_text/pdf_text.dart';
import '../models/surgery_case.dart';

class VetcareParser {
  static final _re = RegExp(
    r'(?:T[2-7]|CN)?\s*(?<date>\d{2}-\d{2}-\d{4})\s+(?<phone>0\d{8,11})\s+(?<class>Tiểu phẫu|Đại phẫu)\s+(?<pet>.+?)\s+(Triệt|Mổ|Xử lý|Cạo|May|Nhét|Rút)',
    caseSensitive: false,
  );

  static Future<List<SurgeryCase>> parsePdf(File pdfFile) async {
    final doc = await PDFDoc.fromFile(pdfFile);
    final text = await doc.text;
    final lines = text
        .split('\n')
        .map((e) => e.trim().replaceAll(RegExp(r'\s+'), ' '))
        .where((e) => e.isNotEmpty)
        .toList();

    final DateFormat fmt = DateFormat('dd-MM-yyyy');
    final List<SurgeryCase> out = [];

    for (final ln in lines) {
      final m = _re.firstMatch(ln);
      if (m != null) {
        final dstr = m.namedGroup('date')!;
        final phone = m.namedGroup('phone')!;
        final cls = m.namedGroup('class')!;
        final pet = m.namedGroup('pet')!.replaceAll(RegExp(r'[;,]$'), '').trim();
        final d = fmt.parse(dstr);
        final due = d.add(const Duration(days: 10));
        out.add(SurgeryCase(
          petName: pet,
          phone: phone,
          classType: cls,
          surgeryDate: d,
          dueDate: due,
        ));
      }
    }
    return out;
  }
}
