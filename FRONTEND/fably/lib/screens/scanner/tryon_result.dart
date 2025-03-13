import 'dart:convert';
import 'dart:io';
import 'dart:typed_data'; // For handling image bytes
import 'package:fably/utils/globals.dart';
import 'package:fably/utils/requests.dart';
import 'package:flutter/material.dart';

class VirtualTryOnResultPage extends StatefulWidget {
  final File? inputImage;
  final String id;

  const VirtualTryOnResultPage({super.key, this.inputImage, required this.id});

  @override
  _VirtualTryOnResultPageState createState() => _VirtualTryOnResultPageState();
}

class _VirtualTryOnResultPageState extends State<VirtualTryOnResultPage> {
  Uint8List? resultImageBytes; // To store the image bytes from the backend
  bool isLoading = false;
  String? errorMessage;
  String image_url = "";

  @override
  void initState() {
    super.initState();
    _fetchTryOnResult();
  }

  Future<void> _fetchTryOnResult() async {
    if (widget.inputImage == null) {
      setState(() {
        errorMessage = "No image provided for try-on.";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });


    // temporarily display the input image as the result image
    widget.inputImage!.readAsBytes().then((bytes) {
      setState(() {
        resultImageBytes = bytes;
      });
    }).catchError((error) {
      setState(() {
        errorMessage = "Failed to load image: $error";
      });
    });

    // --------------------------------------------------------

    
    final imageFile = widget.inputImage;
    final requests = BackendRequests();

    if (imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    // Convert image to Base64
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    String debugMode = "$tryOnDebugMode";
    print("debugMode = $debugMode");

    // JSON payload
    final payload = {
      "item_id": widget.id, // Example ID
      "image": base64Image,
      "debug": debugMode,
    };

    // Send POST request
    final response = await requests.postRequest(
      'virtual_try_on',
      body: payload,
    );

    // Handle the response
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload successful: ${response.body}')),
      );

      image_url = response.body;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: ${response.body}')),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back to the previous screen
          },
        ),
        backgroundColor: Colors.black,
        title: const Text(
          "Virtual Try-On Result",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true, // Centers the title
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child:Column(
            mainAxisAlignment: MainAxisAlignment.center, 
            children:isLoading
            ? <Widget>[
                // Loading Screen
                CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(
                  'Generating Image. This might take a few minuites',
                  textAlign: TextAlign.center, 
                  style: const TextStyle(
                    fontSize: 20 /*, fontWeight: FontWeight.bold*/),
                ),
              ]
              
            : errorMessage != null
              ? <Widget>[
                  Text(
                    errorMessage!,
                    style: TextStyle(color: Colors.red),
                  )
                ]
              : image_url != ""
                ? <Widget>[
                    Image.network(image_url) // Display the received image
                  ]
                  
                : <Widget>[
                    Text('No result to display.')
                  ]
          ),
        ),
      ),
    );
  }
}
