import 'dart:developer';
import 'package:ecommerce_cli/models/user.dart';
import 'package:ecommerce_cli/utils/file_helper.dart';

class UserService {
  final String filePath = 'data/users.json';
  List<User> users = [];

  Future<void> loadUsers() async {
    try {
      final jsonList = await FileHelper.readJsonFile(filePath);
      users = jsonList.map((json) => User.fromJson(json)).toList();
      log('Loaded ${users.length} users from $filePath');
    } catch (e) {
      log('Error loading users: $e');
      print('❌ Failed to load users: $e');
    }
  }

  Future<void> saveUsers() async {
    try {
      final jsonList = users.map((u) => u.toJson()).toList();
      await FileHelper.writeJsonFile(filePath, jsonList);
      log('Saved ${users.length} users to $filePath');
    } catch (e) {
      log('Error saving users: $e');
      print('❌ Failed to save users: $e');
    }
  }

  Future<User?> login(String username, String password) async {
    try {
      final user = users.firstWhere(
        (u) => u.username == username && u.password == password,
        orElse: () => throw Exception('User not found'),
      );
      return user;
    } catch (e) {
      log('Login failed for username: $username');
      return null;
    }
  }

  Future<void> addUser(String username, String password, String role) async {
    try {
      if (users.any((u) => u.username == username)) {
        throw Exception('Username already exists');
      }
      final user = User(
        id: _generateId(),
        username: username,
        password: password,
        role: role,
      );
      users.add(user);
      await saveUsers();
      print('✅ User added: $user');
      log('Added user: $user');
    } catch (e) {
      log('Error adding user: $e');
      print('❌ Failed to add user: $e');
    }
  }

  Future<void> updateUser(int index, String username, String password, String role) async {
    try {
      if (index < 0 || index >= users.length) {
        throw Exception('Invalid user index');
      }
      if (users.any((u) => u.username == username && u != users[index])) {
        throw Exception('Username already exists');
      }
      final oldUser = users[index];
      users[index] = User(
        id: oldUser.id,
        username: username,
        password: password,
        role: role,
      );
      await saveUsers();
      print('✅ User updated: ${users[index]}');
      log('Updated user: ${users[index]}');
    } catch (e) {
      log('Error updating user: $e');
      print('❌ Failed to update user: $e');
    }
  }

  Future<void> deleteUser(int index) async {
    try {
      if (index < 0 || index >= users.length) {
        throw Exception('Invalid user index');
      }
      final user = users.removeAt(index);
      await saveUsers();
      print('✅ User deleted: $user');
      log('Deleted user: $user');
    } catch (e) {
      log('Error deleting user: $e');
      print('❌ Failed to delete user: $e');
    }
  }

  void listUsers() {
    if (users.isEmpty) {
      print('⚠️ No users found.');
      return;
    }
    print('\n📋 User List');
    print('┌─────┬────────────────────────────┬────────────┐');
    print('│ No. │ Username                   │ Role       │');
    print('├─────┼────────────────────────────┼────────────┤');
    for (var i = 0; i < users.length; i++) {
      final u = users[i];
      final usernameTruncated = u.username.length > 26 ? '${u.username.substring(0, 23)}...' : u.username.padRight(26);
      final roleFormatted = u.role.padRight(10);
      print('│ $i${" " * (3 - i.toString().length)} │ $usernameTruncated │ $roleFormatted │');
    }
  }

  String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();
}