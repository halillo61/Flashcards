import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class FileHelper {
  /// 📌 Kullanıcıdan `Downloads` klasörüne kayıt yeri seçmesini isteyen fonksiyon
  static Future<void> exportWordList(String fileName, Map<String, dynamic> data) async {
    try {
      // 📌 Depolama izni iste
      var status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        print("❌ Depolama izni verilmedi! Kullanıcıdan tekrar izin iste.");
        openAppSettings();  // Kullanıcıyı ayarlara yönlendir
        return;
      }


      // 📌 Kullanıcıya nereye kaydedileceğini sor
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) {
        print("⚠️ Kullanıcı bir klasör seçmedi!");
        return;
      }

      // 📌 Seçilen klasörün içine dosyayı kaydet
      final file = File('$selectedDirectory/$fileName');
      await file.writeAsString(jsonEncode(data));
      print("✅ Dosya başarıyla kaydedildi: ${file.path}");
    } catch (e) {
      print("❌ Dosya yazma hatası: $e");
    }
  }

  /// 📌 Kullanıcıdan `.json` dosyası seçmesini isteyen fonksiyon
  static Future<Map<String, dynamic>?> importWordList() async {
    try {
      // 📌 Kullanıcıdan JSON dosyası seçmesini iste
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null) {
        print("⚠️ Kullanıcı dosya seçmedi!");
        return null;
      }

      File file = File(result.files.single.path!);

      if (!await file.exists()) {
        print("❌ Seçilen dosya bulunamadı!");
        return null;
      }

      final content = await file.readAsString();
      print("📂 Okunan dosya içeriği: $content");

      final Map<String, dynamic> jsonData = jsonDecode(content);

      if (jsonData.isEmpty) {
        print("⚠️ Dosya boş!");
        return null;
      }

      print("✅ Dosya başarıyla içe aktarıldı!");
      return jsonData;
    } catch (e) {
      print("❌ Dosya içe aktarma hatası: $e");
      return null;
    }
  }
}