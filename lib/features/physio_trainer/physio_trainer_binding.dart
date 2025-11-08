// lib/features/physio_trainer/physio_trainer_binding.dart
import 'package:get/get.dart';
import 'physio_trainer_controller.dart';

class PhysioTrainerBinding extends Bindings {
  @override
  void dependencies() {
      Get.lazyPut(() => PhysioTrainerController());
  }
}
