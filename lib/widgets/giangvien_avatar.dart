import 'dart:convert';

import 'package:flutter/material.dart';

/// Ảnh đại diện giảng viên. Chưa có ảnh thì hiện chữ cái đầu của tên,
/// nền màu suy ra từ chuỗi tên để mỗi người có màu ổn định.
class GiangVienAvatar extends StatelessWidget {
  final String image;
  final String name;
  final double radius;

  const GiangVienAvatar({
    super.key,
    required this.image,
    this.name = '',
    this.radius = 24,
  });

  static const _palette = [
    Color(0xFF00897B),
    Color(0xFF1E88E5),
    Color(0xFF8E24AA),
    Color(0xFFF4511E),
    Color(0xFF43A047),
    Color(0xFF3949AB),
    Color(0xFFD81B60),
    Color(0xFF6D4C41),
  ];

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    // Tên người Việt: lấy chữ cái của tên (từ cuối), thêm họ nếu có.
    final last = parts.last[0];
    final first = parts.length > 1 ? parts.first[0] : '';
    return (first + last).toUpperCase();
  }

  Color get _color {
    var h = 0;
    for (final c in name.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return _palette[h % _palette.length];
  }

  Widget _fallback() {
    final text = _initials;
    return CircleAvatar(
      radius: radius,
      backgroundColor: text.isEmpty ? Colors.grey.shade300 : _color,
      child: text.isEmpty
          ? Icon(Icons.person, size: radius, color: Colors.white)
          : Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: radius * 0.7,
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (image.isEmpty) return _fallback();
    try {
      final bytes = base64Decode(image.split(',').last);
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey.shade200,
        backgroundImage: MemoryImage(bytes),
      );
    } catch (_) {
      return _fallback();
    }
  }
}
