import 'package:aarogya/medicine/medicine_detail_view.dart';
import 'package:aarogya/medicine/medicine_model.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:aarogya/database_helper.dart';
import '../models/medicine_model.dart';

class MedicineController extends GetxController {
  final RxString statusMessage = "Scan a medicine to get details".obs;
  final Rxn<MedicineModel> foundMedicine = Rxn<MedicineModel>();
  final RxBool isAnalyzing = false.obs;
  final RxDouble progressValue = 0.0.obs;


  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();
  final FlutterTts _flutterTts = FlutterTts();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  final OnDeviceTranslator _translator = OnDeviceTranslator(
    sourceLanguage: TranslateLanguage.english,
    targetLanguage: TranslateLanguage.hindi,
  );

  final String _targetLanguageCode = "hi-IN";

  @override
  void onInit() {
    super.onInit();
    _downloadTranslationModel();
    _flutterTts.setLanguage(_targetLanguageCode);
  }

  Future<void> _downloadTranslationModel() async {
    var modelManager = OnDeviceTranslatorModelManager();
    if (!await modelManager.isModelDownloaded(TranslateLanguage.hindi.bcpCode)) {
      statusMessage.value = "Downloading Hindi model...";
      await modelManager.downloadModel(TranslateLanguage.hindi.bcpCode);
      statusMessage.value = "Model downloaded. Ready to scan.";
    }
  }

  Future<void> scanAndAnalyze() async {
  try {
    // Reset
    progressValue.value = 0.0;
    statusMessage.value = "Opening camera...";
    isAnalyzing.value = true;

    // --- Step 1: Open Camera ---
    progressValue.value = 0.1;
    final XFile? file = await _picker.pickImage(source: ImageSource.camera);
    if (file == null) {
      statusMessage.value = "No image selected.";
      isAnalyzing.value = false;
      progressValue.value = 0.0;
      return;
    }

    // --- Step 2: Convert to InputImage ---
    progressValue.value = 0.3;
    statusMessage.value = "Reading text from image...";
    final inputImage = InputImage.fromFilePath(file.path);

    // --- Step 3: OCR Recognition ---
    progressValue.value = 0.5;
    final recognized = await _textRecognizer.processImage(inputImage);
    String ocrText = recognized.text;

    if (ocrText.isEmpty) {
      statusMessage.value = "No text found.";
      await _speak("कोई टेक्स्ट नहीं मिला।");
      isAnalyzing.value = false;
      progressValue.value = 0.0;
      return;
    }

    // --- Step 4: Database Search ---
    progressValue.value = 0.7;
    statusMessage.value = "Searching database for a match...";
    final result = await _dbHelper.searchMedicine(ocrText);

    if (result != null) {
      MedicineModel medicine = MedicineModel.fromMap(result);
      foundMedicine.value = medicine;

      statusMessage.value = "Found: ${medicine.medicineName}";

      // --- Step 5: Translation ---
      progressValue.value = 0.9;
      statusMessage.value = "Translating details to Hindi...";

      String usageHi = await _translator.translateText(medicine.usageInfo);
      String dosageHi = await _translator.translateText(medicine.dosageInfo);
      String warningHi = await _translator.translateText(medicine.warningInfo);

      await _speakDetails(
        medicine.medicineName,
        usageHi,
        dosageHi,
        warningHi,
      );

      // --- Step 6: Done ---
      progressValue.value = 1.0;
      statusMessage.value = "Analysis Complete ✅";

      Get.to(() => MedicineDetailView(imagePath: file.path));
    } else {
      statusMessage.value = "Medicine not recognized.";
      await _speak("दवा नहीं पहचानी गई।");
      progressValue.value = 0.0;
    }
  } catch (e) {
    statusMessage.value = "Error: $e";
    progressValue.value = 0.0;
  } finally {
    isAnalyzing.value = false;
  }
}


  // Future<void> scanAndAnalyze() async {
  //   try {
  //     statusMessage.value = "Opening camera...";
  //     isAnalyzing.value = true;

  //     final XFile? file = await _picker.pickImage(source: ImageSource.camera);
  //     if (file == null) {
  //       statusMessage.value = "No image selected.";
  //       isAnalyzing.value = false;
  //       return;
  //     }

  //     final inputImage = InputImage.fromFilePath(file.path);
  //     statusMessage.value = "Reading text from image...";
  //     final recognized = await _textRecognizer.processImage(inputImage);
  //     String ocrText = recognized.text;

  //     if (ocrText.isEmpty) {
  //       statusMessage.value = "No text found.";
  //       await _speak("कोई टेक्स्ट नहीं मिला।");
  //       isAnalyzing.value = false;
  //       return;
  //     }

  //     statusMessage.value = "Searching database for a match...";
  //     final result = await _dbHelper.searchMedicine(ocrText);

  //     if (result != null) {
  //       MedicineModel medicine = MedicineModel.fromMap(result);
  //       foundMedicine.value = medicine;

  //       statusMessage.value = "Found: ${medicine.medicineName}";

  //       statusMessage.value = "Translating to Hindi...";
  //       String usageHi = await _translator.translateText(medicine.usageInfo);
  //       String dosageHi = await _translator.translateText(medicine.dosageInfo);
  //       String warningHi = await _translator.translateText(medicine.warningInfo);

  //       await _speakDetails(
  //         medicine.medicineName,
  //         usageHi,
  //         dosageHi,
  //         warningHi,
  //       );

  //       Get.to(MedicineDetailView());
  //     } else {
  //       statusMessage.value = "Medicine not recognized.";
  //       await _speak("दवा नहीं पहचानी गई।");
  //     }
  //   } catch (e) {
  //     statusMessage.value = "Error: $e";
  //   } finally {
  //     isAnalyzing.value = false;
  //   }
  // }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> _speakDetails(String name, String usage, String dosage, String warnings) async {
    await _flutterTts.stop();
    await _flutterTts.speak("दवा का नाम: $name");
    await Future.delayed(Duration(milliseconds: 300));
    await _flutterTts.speak("इसका उपयोग: $usage");
    await Future.delayed(Duration(milliseconds: 300));
    await _flutterTts.speak("खुराक: $dosage");
    await Future.delayed(Duration(milliseconds: 300));
    await _flutterTts.speak("चेतावनी और दुष्प्रभाव: $warnings");
  }

  @override
  void onClose() {
    _textRecognizer.close();
    _translator.close();
    super.onClose();
  }
}
