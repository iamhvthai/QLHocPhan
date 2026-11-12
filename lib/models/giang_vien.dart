class GiangVien {
  final String id;
  final String idgv;
  final String fullname;
  final String image;
  final int sumClass;

  const GiangVien({
    required this.id,
    required this.idgv,
    required this.fullname,
    required this.image,
    required this.sumClass,
  });

  factory GiangVien.fromJson(Map<String, dynamic> j) => GiangVien(
        id: (j['id'] ?? '').toString(),
        idgv: (j['IDGV'] ?? '').toString(),
        fullname: (j['Fullname'] ?? '').toString(),
        image: (j['Image'] ?? '').toString(),
        sumClass: (j['SumClass'] as num?)?.toInt() ?? 0,
      );

  /// Chỉ gửi đúng 4 trường theo đề.
  Map<String, dynamic> toJson() => {
        'IDGV': idgv,
        'Fullname': fullname,
        'Image': image,
        'SumClass': sumClass,
      };
}

