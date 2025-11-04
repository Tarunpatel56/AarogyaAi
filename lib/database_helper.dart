// lib/database_helper.dart
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('medicines.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, filePath);

    // Check if the database exists in the documents directory
    bool dbExists = await databaseExists(path);

    if (!dbExists) {
      // Copy from asset if it doesn't exist
      print("Database not found, copying from assets...");
      try {
        ByteData data = await rootBundle.load(join('assets', filePath));
        List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(path).writeAsBytes(bytes, flush: true);
        print("Database copied to $path");
      } catch (e) {
        print("Error copying database: $e");
      }
    } else {
      print("Database already exists at $path");
    }
    return await openDatabase(path, version: 1);
  }

  // This is the main search function
  Future<Map<String, dynamic>?> searchMedicine(String ocrText) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> allMedicines = await db.query('medicines');
    
    String searchText = ocrText.toLowerCase().replaceAll('\n', ' ');

    // Loop through our DB and find the first match
    for (var medicine in allMedicines) {
      String identifier = (medicine['identifier_text'] as String? ?? '').toLowerCase();
      
      // Check if the text from the image CONTAINS a known medicine identifier
      if (identifier.isNotEmpty && searchText.contains(identifier)) {
        print("Match found: $identifier");
        return medicine; // Return the full medicine details
      }
    }
    
    print("No match found.");
    return null; // No match
  }
}