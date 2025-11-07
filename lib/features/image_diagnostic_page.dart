// TODO Implement this library.
import 'dart:io';
import 'package:aarogya/services/tflite_service.dart'; // Import the service you created
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageDiagnosticPage extends StatefulWidget {
  const ImageDiagnosticPage({super.key});

  @override
  State<ImageDiagnosticPage> createState() => _ImageDiagnosticPageState();
}

class _ImageDiagnosticPageState extends State<ImageDiagnosticPage> {
  late TfliteService _tfliteService;
  final ImagePicker _picker = ImagePicker();
  String _modelType = 'mri'; 

  // Default model
  XFile? _image;
  Map<String, double>? _result;
  bool _isLoading = false;
  
  // --- NEW ---
  // State variable to hold error messages
  String? _error;
  // -----------

  @override
  void initState() {
    super.initState();
    _tfliteService = TfliteService();
    // Load the default model when the page opens
    _loadModel();
  }

  Future<void> _loadModel() async {
    setState(() {
      _isLoading = true;
      _error = null; // Clear previous errors
    });
    
    try {
      await _tfliteService.loadModel(_modelType);
    } catch (e) {
      // --- NEW ---
      // Catch errors during model loading and show them
      setState(() {
        _error = "Failed to load model: ${e.toString()}";
      });
      // -----------
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _selectModel(String? newModel) {
    if (newModel == null) return Future.value();
    setState(() {
      _modelType = newModel;
      _image = null; // Clear image
      _result = null; // Clear previous result
      _error = null; // Clear previous errors
    });
    // Load the new model
    return _loadModel();
  }

  Future<void> _pickImage(ImageSource source) async {
    // --- NEW ---
    // Clear old results and errors
    setState(() {
      _isLoading = true;
      _image = null;
      _result = null;
      _error = null;
    });
    // -----------

    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) {
        setState(() {
          _isLoading = false; // User cancelled picking
        });
        return;
      }
      
      setState(() {
        _image = image;
      });

      // Run inference
      final result = await _tfliteService.runInference(image);

      // --- NEW ---
      // Check if the service returned null (which means an error)
      if (result == null) {
        setState(() {
          _error = "Failed to get a prediction. Check debug console for details.";
        });
      }
      // -----------

      setState(() {
        _result = result;
        _isLoading = false;
      });

    } catch (e) {
      print("Failed to pick or process image: $e");
      // --- NEW ---
      // Catch any other errors and show them
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      // -----------
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Diagnostic'),
        backgroundColor: Colors.teal, // Matches app theme
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- 1. Model Selection Dropdown ---
              DropdownButtonFormField<String>(
                value: _modelType,
                decoration: const InputDecoration(
                  labelText: 'Select Model Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'mri', child: Text('Brain Tumor (MRI)')),
                  DropdownMenuItem(value: 'skin', child: Text('Skin Disease')),
                  DropdownMenuItem(value: 'xray', child: Text('Lung Disease (X-Ray)')),
                ],
                onChanged: _selectModel,
              ),
              const SizedBox(height: 20),

              // --- 2. Image Picker Buttons ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[400],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[400],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- 3. Loading Indicator ---
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                ),

              // --- NEW: ERROR DISPLAY ---
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12.0),
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.red[700]!),
                  ),
                  child: Text(
                    "Error: $_error",
                    style: TextStyle(
                      color: Colors.red[900],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              // ---------------------------

              // --- 4. Image Display ---
              if (_image != null && !_isLoading && _error == null)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Selected Image:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.file(
                          File(_image!.path),
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),

              // --- 5. Result Display ---
              if (_result != null && !_isLoading)
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: Colors.teal),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Diagnosis Result:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 12),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 18, color: Colors.black87),
                          children: [
                            const TextSpan(
                              text: 'Prediction: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: '${_result!.keys.first}',
                              style: const TextStyle(fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 18, color: Colors.black87),
                          children: [
                            const TextSpan(
                              text: 'Confidence: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: '${_result!.values.first.toStringAsFixed(2)}%',
                              style: const TextStyle(fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}