import 'dart:convert';
import 'dart:io';

class FileHelper {
  static Future<List<Map<String, dynamic>>> readJsonFile(String path) async {
    final file = File(path);

    // Create file with empty array if it doesn't exist
    if (!await file.exists()) {
      await file.create(recursive: true);
      await file.writeAsString('[]');
    }

    try {
      final content = await file.readAsString();
      if (content.trim().isEmpty) return [];

      final decoded = json.decode(content);
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded);
      } else {
        print('⚠️ JSON is not a list at $path');
        return [];
      }
    } catch (e) {
      print('❌ Error reading JSON file at $path: $e');
      return [];
    }
  }

  static Future<void> writeJsonFile(
    String path,
    List<Map<String, dynamic>> data,
  ) async {
    final file = File(path);
    await file.create(recursive: true);
    await file.writeAsString(json.encode(data), flush: true);
  }
}
