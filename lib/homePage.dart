import 'dart:io';
import 'dart:ui';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
{
  String result="";
  File image;
  ImagePicker imagePicker;


  pickImageFromGallery() async
  {
    PickedFile pickedFile = await imagePicker.getImage(source: ImageSource.gallery);

    image = File(pickedFile.path);

    setState(() {
      image;

      //do image labeling - extract text from image
      performImageLabeling();
    });
  }

  captureImageWithCamera() async
  {
    PickedFile pickedFile = await imagePicker.getImage(source: ImageSource.camera);

    image = File(pickedFile.path);

    setState(() {
      image;

      //do image labeling - extract text from image
      performImageLabeling();
    });
  }

  performImageLabeling() async
  {
    final FirebaseVisionImage firebaseVisionImage = FirebaseVisionImage.fromFile(image);

    final TextRecognizer recognizer = FirebaseVision.instance.textRecognizer();

    VisionText visionText = await recognizer.processImage(firebaseVisionImage);

    result = "";

    setState(() {
      for(TextBlock block in visionText.blocks)
      {
        final String txt = block.text;

        for(TextLine line in block.lines)
        {
          for(TextElement element in line.elements)
          {
            result += element.text+" ";
          }
        }

        result += "\n\n";
      }
    });
  }

  @override
  void initState() {
    super.initState();

    imagePicker = ImagePicker();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/back.jpg'), fit: BoxFit.cover),
        ),
        child: Column(
          children: [
            SizedBox(width: 100,),

            //show result
            Container(
              height: 280,
              width: 250,
              margin: EdgeInsets.only(top: 70),
              padding: EdgeInsets.only(left: 28, bottom: 5, right: 18),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    result,
                    style: TextStyle(fontSize: 16.0),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/note.jpg'),
                    fit: BoxFit.cover),
              ),
            ),

            Container(
              margin: EdgeInsets.only(top: 20, right: 140),
              child: Stack(
                children: [
                  Stack(
                    children: [

                      Center(
                        child: Image.asset(
                          'assets/pin.png',
                          height: 240,
                          width: 240,
                        ),
                      ),

                    ],
                  ),


                  Center(
                    child: FlatButton(
                      onPressed: ()
                      {
                        pickImageFromGallery();
                      },
                      onLongPress: ()
                      {
                        captureImageWithCamera();
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 25),
                        child: image != null
                            ? Image.file(image, width: 140, height: 192, fit: BoxFit.fill,)
                            : Container(
                                width: 240,
                                height: 200,
                                child: Icon(Icons.camera_front, size: 100, color: Colors.grey,),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
