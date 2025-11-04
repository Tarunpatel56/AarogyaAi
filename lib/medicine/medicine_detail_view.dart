import 'package:aarogya/medicine/medicin_controler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/medicine_controller.dart';

class MedicineDetailView extends StatelessWidget {
  final MedicineController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final medicine = controller.foundMedicine.value;

    return Scaffold(
      appBar: AppBar(
        title: Text("Medicine Details"),
        backgroundColor: Colors.blue[900],
      ),
      body: medicine == null
          ? Center(child: Text("No medicine details available."))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Image.asset("assets/medicine_placeholder.png", height: 120),
                  SizedBox(height: 20),
                  Text(
                    medicine.medicineName,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900]),
                  ),
                  SizedBox(height: 20),
                  _buildDetailCard("Usage / Indications", medicine.usageInfo),
                  _buildDetailCard("Dosage Information", medicine.dosageInfo),
                  _buildDetailCard("Side Effects / Warnings", medicine.warningInfo),
                  SizedBox(height: 30),
                  Text(
                    "Disclaimer: Not a substitute for medical advice.",
                    style: TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailCard(String title, String data) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900])),
            SizedBox(height: 8),
            Text(data, style: TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
