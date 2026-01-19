import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/task_model.dart';

class TaskApiService {
  static const String baseUrl = 'https://amock.io/api/researchUTH';

  static Future<List<Task>> fetchTasks() async {
    debugPrint('CALL API TASKS');
    final res = await http.get(Uri.parse('$baseUrl/tasks'));

    debugPrint('STATUS: ${res.statusCode}');
    debugPrint('BODY: ${res.body}');

    final body = jsonDecode(res.body);
    final List list = body is List ? body : body['data'];

    return list.map((e) => Task.fromJson(e)).toList();
  }

  static Future<Task> fetchTaskDetail(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/tasks'));

    final body = jsonDecode(res.body);
    final List list = body is List ? body : body['data'];

    return list.map((e) => Task.fromJson(e)).firstWhere((t) => t.id == id);
  }

  static Future<void> deleteTask(int id) async {
    await http.delete(Uri.parse('$baseUrl/task/$id'));
  }
}
