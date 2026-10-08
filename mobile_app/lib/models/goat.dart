class Goat {
  final String? id;
  final String goatNumber;
  final String owner;
  final String dateOfBirth;
  final String vaccinationDate;
  final int herdSize;
  final String notes;
  final DateTime? createdAt;

  Goat({
    this.id,
    required this.goatNumber,
    required this.owner,
    required this.dateOfBirth,
    required this.vaccinationDate,
    required this.herdSize,
    this.notes = '',
    this.createdAt,
  });

  factory Goat.fromMap(Map<String, dynamic> map) {
    return Goat(
      id: map['id']?.toString(),
      goatNumber: map['goat_number']?.toString() ?? '',
      owner: map['owner']?.toString() ?? '',
      dateOfBirth: map['date_of_birth']?.toString() ?? '',
      vaccinationDate: map['vaccination_date']?.toString() ?? '',
      herdSize: int.tryParse(map['herd_size']?.toString() ?? '') ?? 0,
      notes: map['notes']?.toString() ?? '',
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'goat_number': goatNumber,
      'owner': owner,
      'date_of_birth': dateOfBirth,
      'vaccination_date': vaccinationDate,
      'herd_size': herdSize,
      'notes': notes,
    };
  }
}
