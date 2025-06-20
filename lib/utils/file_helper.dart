import 'dart:convert';
import 'dart:developer';
import 'dart:io';

class FileHelper {
  static Future<List<Map<String, dynamic>>> readJsonFile(String path) async {
    final file = File(path);

    try {
      if (!await file.exists()) {
        await file.create(recursive: true);
        await file.writeAsString('[]');
        log('Created new JSON file at $path');
      }

      final content = await file.readAsString();
      if (content.trim().isEmpty) {
        log('Empty JSON file at $path');
        return [];
      }

      final decoded = json.decode(content);
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded);
      } else {
        log('Invalid JSON format at $path: not a list');
        print('⚠️ JSON is not a list at $path');
        return [];
      }
    } catch (e) {
      log('Error reading JSON file at $path: $e');
      print('❌ Error reading JSON file at $path: $e');
      return [];
    }
  }

  static Future<void> writeJsonFile(
    String path,
    List<Map<String, dynamic>> data,
  ) async {
    final file = File(path);
    try {
      await file.create(recursive: true);
      await file.writeAsString(json.encode(data), flush: true);
      log('Wrote ${data.length} items to JSON file at $path');
    } catch (e) {
      log('Error writing JSON file at $path: $e');
      print('❌ Error writing JSON file at $path: $e');
    }
  }
}