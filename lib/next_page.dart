import 'dart:io';

import 'package:flutter/material.dart';

class NextPage extends StatelessWidget {
  final File imageData;
  const NextPage(this.imageData,  {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    // print(widget.image);
    return Scaffold(
      body: AspectRatio(
        aspectRatio: 16/9,
        child: Image.file(
          imageData,
          fit: BoxFit.cover,
        ),),
    );
  }
}
