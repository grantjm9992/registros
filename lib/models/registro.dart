import 'dart:convert';

class Registro {
  final int? id;
  final String motivo;
  final List<String> sentimientos;
  final String pensamiento;
  final String comportamiento;
  final String consecuencia;
  final DateTime createdAt;

  Registro({
    this.id,
    required this.motivo,
    required this.sentimientos,
    required this.pensamiento,
    required this.comportamiento,
    required this.consecuencia,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'motivo': motivo,
      'sentimientos': jsonEncode(sentimientos),
      'pensamiento': pensamiento,
      'comportamiento': comportamiento,
      'consecuencia': consecuencia,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Registro.fromMap(Map<String, dynamic> map) {
    return Registro(
      id: map['id'] as int?,
      motivo: map['motivo'] as String,
      sentimientos: (jsonDecode(map['sentimientos'] as String) as List)
          .map((e) => e as String)
          .toList(),
      pensamiento: map['pensamiento'] as String,
      comportamiento: map['comportamiento'] as String,
      consecuencia: map['consecuencia'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Registro copyWith({
    int? id,
    String? motivo,
    List<String>? sentimientos,
    String? pensamiento,
    String? comportamiento,
    String? consecuencia,
    DateTime? createdAt,
  }) {
    return Registro(
      id: id ?? this.id,
      motivo: motivo ?? this.motivo,
      sentimientos: sentimientos ?? this.sentimientos,
      pensamiento: pensamiento ?? this.pensamiento,
      comportamiento: comportamiento ?? this.comportamiento,
      consecuencia: consecuencia ?? this.consecuencia,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Helper to get sentimientos as a display string
  String get sentimientosDisplay => sentimientos.join(', ');
}
