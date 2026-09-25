import 'dart:convert';

enum QrType { website, text, wifi, contact, email, phone }

extension QrTypeX on QrType {
  String get label {
    switch (this) {
      case QrType.website:
        return 'Website';
      case QrType.text:
        return 'Text';
      case QrType.wifi:
        return 'Wi-Fi';
      case QrType.contact:
        return 'Contact';
      case QrType.email:
        return 'Email';
      case QrType.phone:
        return 'Phone';
    }
  }

  static QrType fromString(String value) {
    return QrType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => QrType.text,
    );
  }
}

/// A saved or generated QR code entry.
class QrItem {
  final String id;
  final QrType type;
  final String title;
  final String data; // The raw string encoded in the QR code
  final DateTime createdAt;
  final int colorValue; // Color used to render the QR
  final int styleIndex; // Style variant index (0-3)
  final bool logoEnabled;
  final bool isScanned; // true if this came from scanning, false if created

  QrItem({
    required this.id,
    required this.type,
    required this.title,
    required this.data,
    required this.createdAt,
    this.colorValue = 0xFF2F7AFE,
    this.styleIndex = 0,
    this.logoEnabled = true,
    this.isScanned = false,
  });

  QrItem copyWith({
    String? title,
    int? colorValue,
    int? styleIndex,
    bool? logoEnabled,
  }) {
    return QrItem(
      id: id,
      type: type,
      title: title ?? this.title,
      data: data,
      createdAt: createdAt,
      colorValue: colorValue ?? this.colorValue,
      styleIndex: styleIndex ?? this.styleIndex,
      logoEnabled: logoEnabled ?? this.logoEnabled,
      isScanned: isScanned,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'data': data,
        'createdAt': createdAt.toIso8601String(),
        'colorValue': colorValue,
        'styleIndex': styleIndex,
        'logoEnabled': logoEnabled,
        'isScanned': isScanned,
      };

  factory QrItem.fromJson(Map<String, dynamic> json) => QrItem(
        id: json['id'] as String,
        type: QrTypeX.fromString(json['type'] as String? ?? 'text'),
        title: json['title'] as String? ?? '',
        data: json['data'] as String? ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        colorValue: json['colorValue'] as int? ?? 0xFF2F7AFE,
        styleIndex: json['styleIndex'] as int? ?? 0,
        logoEnabled: json['logoEnabled'] as bool? ?? true,
        isScanned: json['isScanned'] as bool? ?? false,
      );

  static String encodeList(List<QrItem> items) =>
      jsonEncode(items.map((e) => e.toJson()).toList());

  static List<QrItem> decodeList(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => QrItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
