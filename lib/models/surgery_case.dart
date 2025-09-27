class SurgeryCase {
  final int? id; // id trong SQLite
  final String petName;
  final String phone;
  final String classType; // "Tiểu phẫu" | "Đại phẫu"
  final DateTime surgeryDate;
  final DateTime dueDate; // D+10 mặc định
  final String status; // "pending" | "done"

  SurgeryCase({
    this.id,
    required this.petName,
    required this.phone,
    required this.classType,
    required this.surgeryDate,
    required this.dueDate,
    this.status = 'pending',
  });

  SurgeryCase copyWith({
    int? id,
    String? petName,
    String? phone,
    String? classType,
    DateTime? surgeryDate,
    DateTime? dueDate,
    String? status,
  }) => SurgeryCase(
        id: id ?? this.id,
        petName: petName ?? this.petName,
        phone: phone ?? this.phone,
        classType: classType ?? this.classType,
        surgeryDate: surgeryDate ?? this.surgeryDate,
        dueDate: dueDate ?? this.dueDate,
        status: status ?? this.status,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'petName': petName,
        'phone': phone,
        'classType': classType,
        'surgeryDate': surgeryDate.toIso8601String(),
        'dueDate': dueDate.toIso8601String(),
        'status': status,
      };

  factory SurgeryCase.fromMap(Map<String, dynamic> m) => SurgeryCase(
        id: m['id'] as int?,
        petName: m['petName'] as String,
        phone: m['phone'] as String,
        classType: m['classType'] as String,
        surgeryDate: DateTime.parse(m['surgeryDate'] as String),
        dueDate: DateTime.parse(m['dueDate'] as String),
        status: m['status'] as String,
      );
}
