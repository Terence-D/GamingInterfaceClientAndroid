import 'GicControl.dart';

class Screen {
  static const MAX_CONTROL_SIZE = 800;

  int screenId = -1;
  List<GicControl> controls = new List<GicControl>();
  //background
  int newControlId = -1;
  int backgroundColor;
  String backgroundPath;
  //context;
  String name;

  Screen({this.screenId, this.controls, this.backgroundColor, this.backgroundPath, this.newControlId, this.name});

  factory Screen.fromJson(Map<String, dynamic> json) {
    var list = json['controls'] as List;
    List<GicControl> jsonControls = list.map((i) => GicControl.fromJson(i)).toList();

    return Screen(
      screenId: json['screenId'],
      controls: jsonControls,
      backgroundColor: json['backgroundColor'],
      backgroundPath: json['backgroundPath'],
      newControlId: json['newControlId'],
      name: json['name']);
  }



  // Screen.fromMappedJson(Map<String, dynamic> json) :
  //     screenId = json['screenId'],
  //     controls = json['controls'],
  //     backgroundColor = json['backgroundColor'],
  //     backgroundPath = json['backgroundPath'],
  //     newControlId = json['newControlId'],
  //     name = json['name'];

  Map<String, dynamic> toJson() =>
      {
        'screenId': screenId,
        'controls': controls,
        'backgroundColor': backgroundColor,
        'backgroundPath': backgroundPath,
        'newControlId': newControlId,
        'name': name,
      };

  int getNewControlId() {
    newControlId++;
    return newControlId - 1;
  }

//  getBackground() {
//    if (backgroundPath.isEmpty()) {
//      //load a color
//      //ColorDrawable color = new ColorDrawable();
//      color.setColor(backgroundColor);
//      background = color;
//    } else {
//      //load an image
//      Bitmap bitmap = BitmapFactory.decodeFile(backgroundPath);
//      if (bitmap == null) {
//        background = new ColorDrawable(Color.BLACK);
//      } else {
//        Drawable bitmapDrawable = new BitmapDrawable(context.getResources(), bitmap);
//        background = bitmapDrawable;
//      }
//    }
//
//    return background;
//  }

//  @Override
//  public void setBackground(Drawable background) {
//    if (background != null)
//      this.background = background;
//  }

//  @Override
//  public Drawable getImage(String fileName) {
////        if (fileName.contains(screenId + "_control")) {
//    Bitmap bitmap = BitmapFactory.decodeFile(fileName);
//    Drawable bitmapDrawable = new BitmapDrawable(context.getResources(), bitmap);
//    return bitmapDrawable;
////        }
//    //return null;
//  }

//  @Override
//  public void addControl(GICControl control) {
//    customControls.add(control);
//  }
}
