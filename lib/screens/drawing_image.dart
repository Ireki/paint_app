import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:test_orbi/painter/painter_image.dart';
import 'package:permission_handler/permission_handler.dart';


class DrawingImage extends StatelessWidget {
  PainterController _controller;
  ui.Image _image;

  DrawingImage(ui.Image image){
    _image = image;
    _controller = _newController();

  }

  PainterController _newController() {
    PainterController controller = new PainterController();
    controller.thickness = 5.0;
    controller.backgroundImage = _image;
    return controller;
  }


  @override
  Widget build(BuildContext context) {
    List<Widget> actions = <Widget>[
        new IconButton(
            icon: new Icon(Icons.undo),
            tooltip: 'Undo',
            onPressed: () {
              if (_controller.isEmpty) {
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) =>
                    new Text('Nothing to undo'));
              }
              else _controller.undo();
            }),
        new IconButton(
            icon: new Icon(Icons.delete),
            tooltip: 'Clear',
            onPressed: _controller.clear),
        new IconButton(
            icon: new Icon(Icons.check),
            onPressed: () async {
              final imageName = await saveImage(_controller.finish());
              showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) =>
                  new Text('Image saved as  ${imageName}'));
            },

        )
      ];

    return new Scaffold(
      appBar: new AppBar(
          actions: actions,
          bottom: new PreferredSize(
            child: new DrawBar(_controller),
            preferredSize: new Size(MediaQuery.of(context).size.width, 30.0),
          )),
      body: new Center(
          child:  Painter(_controller)
      ),
    );
  }

  Future<String> saveImage(PictureDetails picture) async {
    final imagePng = await picture.toPNG();
    final imageName = "Image"+Random().nextInt(10000000).toString();
    if(await Permission.storage.request().isGranted){
      final requsest = await ImageGallerySaver.saveImage(
          imagePng,
          name: imageName);
    }
    return imageName;
  }
}

class DrawBar extends StatelessWidget {
  final PainterController _controller;

  DrawBar(this._controller);

  @override
  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Flexible(child: new StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return new Container(
                  child: new Slider(
                    value: _controller.thickness,
                    onChanged: (double value) => setState(() {
                      _controller.thickness = value;
                    }),
                    min: 1.0,
                    max: 20.0,
                    activeColor: Colors.white,
                  ));
            })),
        new ColorPickerButton(_controller, true),
      ],
    );
  }
}

class ColorPickerButton extends StatefulWidget {
  final PainterController _controller;
  final bool _background;

  ColorPickerButton(this._controller, this._background);

  @override
  _ColorPickerButtonState createState() => new _ColorPickerButtonState();
}

class _ColorPickerButtonState extends State<ColorPickerButton> {
  @override
  Widget build(BuildContext context) {
    return new IconButton(
        icon: new Icon(Icons.brush, color: _color),
        tooltip: 'Change draw color',
        onPressed: _pickColor);
  }

  void _pickColor() {
    Color pickerColor = _color;
    Navigator.of(context)
        .push(new MaterialPageRoute(
        fullscreenDialog: true,
        builder: (BuildContext context) {
          return new Scaffold(
              appBar: new AppBar(
                title: const Text('Pick color'),
              ),
              body: new Container(
                  alignment: Alignment.center,
                  child: new ColorPicker(
                    pickerColor: pickerColor,
                    onColorChanged: (Color c) => pickerColor = c,
                  )
              )
          );
        }))
        .then((_) {
      setState(() {
        _color = pickerColor;
      });
    });
  }
  Color get _color => widget._controller.drawColor;

  set _color(Color color) {
      widget._controller.drawColor = color;
  }
}