import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

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
          final String imagePath =
              _ImageServer.getImageByIndex(index);
          return
            Material(
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context, imagePath);
                  },
                  child: Container(
                    child: ClipRRect(
                      child: Image(image:AssetImage(imagePath),
                          width: 120.0, height: 80.0),
                    ),),
                )
            );
        },
        childCount: _ImageServer.length(),
      ),
    );
  }
}

/// this class handles the loading of custom and built in images
class _ImageServer {
  static List<String> _imagePaths;

  static String getImageByIndex(int index) {
    return _imagePaths[index];
  }

  static int length() => _imagePaths.length;

  static Future<void> loadImages() async {
    _imagePaths = [];
    //first we load in any custom images
    Directory filesDir = await getApplicationSupportDirectory();
    await filesDir.list(recursive: false).forEach((element) {
      if (element.path.contains("button_")) {
        //valid image
        _imagePaths.add(element.path);
      }
    });

    //now load in the defaults
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    _imagePaths.addAll(manifestMap.keys
        .where((String key) => key.contains('images/controls/'))
        .toList());
  }
}
