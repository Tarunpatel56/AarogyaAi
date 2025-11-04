import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../utils/text_utils.dart';

class MedicineAnalyzer extends StatefulWidget {
  MedicineAnalyzer({super.key});

  @override
  State<MedicineAnalyzer> createState() => _MedicineAnalyzerState();
}

class _MedicineAnalyzerState extends State<MedicineAnalyzer> {
  final _picker = ImagePicker();

  XFile? _image;

  pickImage(bool isCamera) async {
    final pickedFile = await _picker.pickImage(
      source: isCamera ? ImageSource.camera : ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("Medicine Analyzer"))),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal:  20),
            
              height: Get.height * 0.35,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                  image: _image == null
                      ? AssetImage("assets/medicin.jpg")
                      : FileImage(File(_image!.path)),
                  fit: BoxFit.cover,
                ),
              ),

              child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        pickImage(true);
                      },
                      icon: Icon(Icons.camera_alt_outlined, size: 45),
                    ),

                    IconButton(
                      onPressed: () {
                        pickImage(false);
                      },
                      icon: Icon(Icons.photo_library_outlined, size: 45),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              margin: const EdgeInsets.all(20),
               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              // height: Get.height / 2,
              width: double.maxFinite,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.grey.shade200,
              ),
              child: Column(
                children: [
                  SizedBox(height: Get.height * 0.02),
                  Text(
                    "Analysis Results",
                    style: AppTextStyles.headingTextStyle,
                  ),
                  SizedBox(height: Get.height * 0.03),
            
                  CircularPercentIndicator(
                    radius: 90,
                    lineWidth: 20,
                    percent: 0.4,
                    progressBorderColor: Colors.deepPurple,
                    backgroundColor: Colors.deepPurple.shade100,
                    progressColor: Colors.yellow,
            
                    circularStrokeCap: CircularStrokeCap.round,
                    center: Text("40%"),
                  ),
                  Text("Analying"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
