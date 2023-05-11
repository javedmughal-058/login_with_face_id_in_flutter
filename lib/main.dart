///first


// import 'package:flutter/material.dart';
// import 'package:login_with_face_id_in_flutter/local_auth.dart';
//
// import 'new.dart';
//
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Login With Face Recognition',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home:  const FaceDetectorScreen(),
//     );
//   }
// }
//
// class MyHomePage extends StatelessWidget {
//   const MyHomePage({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//         child: Scaffold(
//           backgroundColor: Colors.black,
//           body: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Image.asset('images/lock.png'),
//                 const Text('Tap on the button to authenticate with the device\'s local authentication system', style: TextStyle(color: Colors.grey),),
//                 const SizedBox(height: 20,),
//                 ElevatedButton(
//                     style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.orange)),
//                     onPressed: () async {
//
//                       await LocalAuthApi.authenticate();
//                         // print('Verified');
//
//                     }, child: const Text('Login With Face Recognition')),
//               ],
//             ),
//           ),
//         ));
//   }
// }








///second

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:login_with_face_id_in_flutter/next_page.dart';
import 'dart:math' as math;

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _cameras = await availableCameras();
  runApp(const MyApp());
}

/// CameraApp is the Main Application.
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);



  @override
  State<MyApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<MyApp> {

  int selectedCameraIndex =1;
  late double mirror = 0;
  late CameraController controller;
  late File image;
  bool imageHasData = false;
  @override
  void initState() {
    super.initState();
    controller = CameraController(_cameras[1], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
          // Handle access errors here.
            break;
          default:
          // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    mirror = selectedCameraIndex == 1 ? math.pi : 0;
    if (!controller.value.isInitialized) {
      return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(body: Center(child: Text('Error, Camera not Initialized'),)));
    }
    else if(imageHasData){
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(mirror),
            child: Image.file(
              image,
              fit: BoxFit.cover,
            ),
          ),
          floatingActionButton: retryButton(),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: CameraPreview(controller,),
        floatingActionButton: _buildCaptureButton(controller),

      ),
    );
  }



  Widget retryButton(){
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: FloatingActionButton(
        onPressed: () {
          controller.resumePreview();
          setState(() {
            imageHasData = false;
          });
        },
        child: const Icon(Icons.assignment_return_outlined),
      ),
    );
  }

  Widget _buildCaptureButton(CameraController controller) {
    void _navigateToNextScreen(BuildContext context) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => NextPage(image)));
    }
    Future<void> _captureImage() async {
      try {
        XFile img = await controller.takePicture();
        File file = File(img.path);
        setState(() {
          image = file;

        });

        final inputImage = InputImage.fromFilePath(file.path);
        final FaceDetector faceDetector = GoogleMlKit.vision.faceDetector(
          FaceDetectorOptions(
            enableContours: true,
            enableClassification: true,
            enableTracking: true,
          ),
        );
        final faces = await faceDetector.processImage(inputImage);
        for (Face face in faces) {
          print('Face detected: ${face.boundingBox}');
        }

      } catch (e) {
        print(e);
      }
    }


    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: FloatingActionButton(
        onPressed: () {
          _captureImage().then((_) {
            controller.pausePreview();
            print("clicking data ---------------------------------- $image");
              // Navigator.of(context).push(MaterialPageRoute(builder: (context) =>  NextPage(image)));
            // _navigateToNextScreen(context);
              // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (c) => NextPage(image)));

            setState(() {
              imageHasData = true;
            });

          });
        },
        child: const Icon(Icons.camera),
      ),
    );


  }

}