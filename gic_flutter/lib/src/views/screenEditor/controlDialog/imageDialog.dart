import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageDialog extends StatefulWidget {
  @override
  _ImageDialogState createState() => _ImageDialogState();
}

class _ImageDialogState extends State<ImageDialog> {
  _ImageDialogState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: Text('Pick Image'),
          ),
          _ImageList(),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _ImageServer.loadImages().then((value) => setState(() {}));
  }
}

class _ImageList extends StatelessWidget {
  _ImageList();

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return Material(
              child: InkWell(
            onTap: () {
              Navigator.pop(context, _ImageServer.getFilenameByIndex(index));
            },
            child: Container(
              child: ClipRRect(
                child: _ImageServer.getImageByIndex(index),
              ),
            ),
          ));
        },
        childCount: _ImageServer.length(),
      ),
    );
  }
}

/// this class handles the loading of custom and built in images
class _ImageServer {
  static List<Widget>? _images;
  static List<String>? _imagePaths;

  static Widget getImageByIndex(int index) {
    return _images![index];
  }

  static getFilenameByIndex(int index) {
    return _imagePaths![index];
  }
  static int length() => _images!.length;

  static Future<void> loadImages() async {
    _images = [];
    _imagePaths = [];
    //first we load in any custom images
    Directory filesDir = await getApplicationSupportDirectory();
    await filesDir.list(recursive: false).forEach((element) {
      if (element.path.contains("button_")) {
        //valid image
        _images!.add(Image.file(File(element.path), width: 120.0, height: 80.0));
        _imagePaths!.add(element.path);
      }
    });

    //now load in the defaults
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    manifestMap.keys.where((String key) => key.contains('images/controls/')).forEach((element) {
        _images!.add(Image(image:AssetImage(element),
            width: 120.0, height: 80.0));
        File file = File(element);
        String basename = path.basenameWithoutExtension(file.path);
        _imagePaths!.add(basename);
    });
  }
}
