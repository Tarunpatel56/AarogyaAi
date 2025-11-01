import 'package:get/get.dart';

class SnackBarUtils {
 static void showSnack(
    {String? title, String? message}
  ) {
     Get.showSnackbar(
        GetSnackBar(
          title:  title??"AppName",
          message: message?? "Something went wrong",
          duration: Duration(seconds: 3),
        ),
      );
  }
}
