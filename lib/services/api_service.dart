import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/giang_vien.dart';
import 'token_storage.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);
  @override
  String toString() => message;
}

class GiangVienPage {
  final List<GiangVien> data;
  final int page;
  final int total;
  final int totalPages;
  final int totalSumClass;
  GiangVienPage(this.data, this.page, this.total, this.totalPages, this.totalSumClass);
}

class ApiService {
  /// Được gọi khi nhận 401 (hết phiên) để đưa về màn đăng nhập.
  static VoidCallback? onUnauthorized;

  static const _timeout = Duration(seconds: 15);

  static Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
    bool auth = true,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path').replace(queryParameters: query);
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (auth) {
      final t = await TokenStorage.read();
      if (t != null) headers['Authorization'] = 'Bearer $t';
    }
    http.Response res;
    try {
      final enc = body == null ? null : jsonEncode(body);
      switch (method) {
        case 'POST':
          res = await http.post(uri, headers: headers, body: enc).timeout(_timeout);
          break;
        case 'PUT':
          res = await http.put(uri, headers: headers, body: enc).timeout(_timeout);
          break;
        case 'DELETE':
          res = await http.delete(uri, headers: headers).timeout(_timeout);
          break;
        default:
          res = await http.get(uri, headers: headers).timeout(_timeout);
      }
    } on TimeoutException {
      throw ApiException('Máy chủ phản hồi quá lâu');
    } catch (_) {
      throw ApiException('Không kết nối được máy chủ');
    }

    dynamic json;
    try {
      json = res.body.isEmpty ? null : jsonDecode(utf8.decode(res.bodyBytes));
    } catch (_) {
      json = null;
    }
    if (res.statusCode >= 200 && res.statusCode < 300) return json;

    if (res.statusCode == 401 && auth) {
      await TokenStorage.clear();
      onUnauthorized?.call();
    }
    final msg = (json is Map && json['message'] != null)
        ? json['message'].toString()
        : 'Lỗi ${res.statusCode}';
    throw ApiException(msg, res.statusCode);
  }

  static Future<String> login(String username, String password) async {
    final j = await _request('POST', '/auth/login',
        body: {'username': username, 'password': password}, auth: false);
    await TokenStorage.save(j['token'] as String);
    return j['username'] as String;
  }

  static Future<String> me() async {
    final j = await _request('GET', '/auth/me');
    return j['username'] as String;
  }

  static Future<GiangVienPage> getGiangVien({
    String search = '',
    int page = 1,
    int limit = 10,
  }) async {
    final j = await _request('GET', '/giangvien', query: {
      'search': search,
      'page': '$page',
      'limit': '$limit',
    });
    return GiangVienPage(
      (j['data'] as List)
          .map((e) => GiangVien.fromJson(e as Map<String, dynamic>))
          .toList(),
      j['page'] as int,
      j['total'] as int,
      j['totalPages'] as int,
      (j['totalSumClass'] as num).toInt(),
    );
  }

  static Future<GiangVien> getOne(String id) async =>
      GiangVien.fromJson(await _request('GET', '/giangvien/$id'));

  static Future<GiangVien> create(GiangVien g) async =>
      GiangVien.fromJson(await _request('POST', '/giangvien', body: g.toJson()));

  static Future<GiangVien> update(String id, GiangVien g) async =>
      GiangVien.fromJson(await _request('PUT', '/giangvien/$id', body: g.toJson()));

  static Future<void> delete(String id) async {
    await _request('DELETE', '/giangvien/$id');
  }
}

