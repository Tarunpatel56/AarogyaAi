// lib/medicine/routes/app_pages.dart
import 'package:aarogya/features/physio_trainer/physio_trainer_binding.dart';
import 'package:aarogya/medicine/medicine_detail_view.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:aarogya/features/physio_trainer/physio_trainer_binding.dart'; // ADD THIS IMPORT
import 'package:aarogya/features/physio_trainer/physio_trainer_page.dart'; // ADD THIS IMPORT
// ... other imports

abstract class Routes {
  // ...
  static const MEDICINE_DETAIL = '/medicine-detail';
  static const PHYSIO_TRAINER = '/physio-trainer'; // ADD THIS LINE
}

class AppPages {
  // ...
  static final routes = [
    // ... your other GetPages
    GetPage(
      name: Routes.MEDICINE_DETAIL,
      page: () => MedicineDetailView(imagePath: 'assets/medicin.jpg',),
    ),
    // ADD THIS GetPage
    GetPage(
      name: Routes.PHYSIO_TRAINER,
      page: () => PhysioTrainerPage(),
      binding: PhysioTrainerBinding(),
    ),
  ];
}