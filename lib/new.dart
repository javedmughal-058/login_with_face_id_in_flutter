import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class FaceDetectorScreen extends StatefulWidget {

   const FaceDetectorScreen({Key? key}) : super(key: key);

  @override
  _FaceDetectorScreenState createState() => _FaceDetectorScreenState();
}

class _FaceDetectorScreenState extends State<FaceDetectorScreen> {

  late List<CameraDescription> _cameras;
  late CameraController _cameraController;
  late FaceDetector _faceDetector;
  bool _isDetecting = false;




  @override
  Future<void> initState() async {
    super.initState();
    _cameras = await availableCameras();
    _cameraController = CameraController(_cameras[1], ResolutionPreset.max);

    _faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(
        enableContours: true,
        enableClassification: true,
        enableTracking: true,
      ),
    );

    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      await _cameraController.initialize();
      _cameraController.startImageStream(_onImageStream);
    } catch (e) {
      // handle errors
    }
  }

  void _onImageStream(CameraImage cameraImage) async {
    if (_isDetecting) return;
    _isDetecting = true;

    final inputImage = InputImage.fromBytes(
      bytes: cameraImage.planes[0].bytes,
      inputImageData: InputImageData(
        size: Size(
          cameraImage.width.toDouble(),
          cameraImage.height.toDouble(),
        ),
        imageRotation: InputImageRotation.rotation0deg,
        inputImageFormat: InputImageFormat.yuv420, planeData: [],
      ),
    );

    final faces = await _faceDetector.processImage(inputImage);

    if (faces.isNotEmpty) {
      // extract the face's features and compare them to the stored features for the user
      // if the features match, log the user in
      print(faces);
    }

    _isDetecting = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Detector'),
      ),
      body: CameraPreview(_cameraController),
    );
  }

  @override
  void dispose() {
    _cameraController.stopImageStream();
    _cameraController.dispose();
    _faceDetector.close();
    super.dispose();
  }
}
