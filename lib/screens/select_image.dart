import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_orbi/screens/drawing_image.dart';


class SelectImage extends StatelessWidget{

  Future<ui.Image> getImage() async {
    Completer completer = Completer<ui.Image>();
    final picker = ImagePicker();
    var pickedFile = await picker.getImage(source: ImageSource.gallery);
    final Uint8List bytes = await File(pickedFile.path).readAsBytes();
    ui.decodeImageFromList(bytes, (ui.Image img) {return completer.complete(img);});
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: new FloatingActionButton(
          tooltip: 'Pick Image',
          child: Icon(Icons.add),
          onPressed: () async{
            ui.Image _image = await getImage();
            if(_image != null)
              Navigator.push(context, MaterialPageRoute(builder: (context) => DrawingImage(_image)));
          },
        ),
      ),

    );
  }

}
