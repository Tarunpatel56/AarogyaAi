// import 'dart:io';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import '../services/tflite_service.dart';

// class DiagnosticController extends GetxController {
//   final picker = ImagePicker();
//   final tfliteService = TfliteService();

//   var selectedModel = 'mri'.obs;
//   var image = Rxn<XFile>();
//   var result = <String, double>{}.obs;
//   var isLoading = false.obs;
//   var error = ''.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     loadModel();
//   }

//   Future<void> loadModel() async {
//     isLoading(true);
//     error('');
//     try {
//       await tfliteService.loadModel(selectedModel.value);
//     } catch (e) {
//       error("Model load failed: $e");
//     } finally {
//       isLoading(false);
//     }
//   }

//   void changeModel(String newModel) {
//     selectedModel.value = newModel;
//     image.value = null;
//     result.clear();
//     loadModel();
//   }

//   Future<void> pickImage(ImageSource source) async {
//     try {
//       isLoading(true);
//       final picked = await picker.pickImage(source: source);
//       if (picked == null) {
//         isLoading(false);
//         return;
//       }
//       image.value = picked;
//       final output = await tfliteService.runInference(picked);
//       if (output == null) {
//         error("Failed to get prediction.");
//       } else {
//         result.assignAll(output);
//       }
//     } catch (e) {
//       error("Error: $e");
//     } finally {
//       isLoading(false);
//     }
//   }
// }
