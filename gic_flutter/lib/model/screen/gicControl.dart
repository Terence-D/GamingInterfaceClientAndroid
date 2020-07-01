import 'command.dart';

class GicControl {
  static const int TYPE_BUTTON = 0;
  static const int TYPE_TEXT = 1;
  static const int TYPE_IMAGE = 2;
  static const int TYPE_SWITCH = 3;
  static const int TYPE_BUTTON_QUICK = 4;

  //this is required for the toggle button, there are 4 stages to track:
  //0 - switched off ready for mouse down
  //1 - switched off, ready for mouse up
  //2 - switched on, ready for mouse down,
  //3 - switched on, ready for mouse up
  //after 3, we reset back to 0
  int stage = 0;
  Command command;// = new Command();
  String text = "NONE";
  double left = 140;
  int width = 320;
  double top = 200;
  int height = 120;
  int fontColor = 0;//Colors.white;// Colors.WHITE;
  int primaryColor = -1;
  int secondaryColor = -1;
  int fontSize = 36;
  int viewType = 0;
  int primaryImageResource = 0;//R.drawable.button_blue;
  int secondaryImageResource = 0;//R.drawable.button_blue_dark;
  String primaryImage = "";
  String secondaryImage = "";
  String fontName = "";
  int fontType = 0;
  Command commandSecondary;// = new Command();

  GicControl ({
    this.stage, 
    this.command,
    this.text,
    this.left,
    this.width,
    this.top,
    this.height,
    this.fontColor,
    this.primaryColor,
    this.secondaryColor,
    this.fontSize,
    this.viewType,
    this.primaryImageResource,
    this.secondaryImageResource,
    this.primaryImage,
    this.secondaryImage,
    this.fontName,
    this.fontType,
    this.commandSecondary
  });

  factory GicControl.fromJson(Map<String, dynamic> json) {
    return GicControl(
      stage: json['stage'],
        command: Command.fromJson(json['command']),
        text: json['text'],
        left: json['left'],
        width: json['width'],
        top: json['top'],
        height: json['height'],
        fontColor: json['fontColor'],
        primaryColor: json['primaryColor'],
        secondaryColor: json['secondaryColor'],
        fontSize: json['fontSize'],
        viewType: json['viewType'],
        primaryImageResource: json['primaryImageResource'],
        secondaryImageResource: json['secondaryImageResource'],
        primaryImage: json['primaryImage'],
        secondaryImage: json['secondaryImage'],
        fontName: json['fontName'],
        fontType: json['fontType'],
        commandSecondary: Command.fromJson(json['commandSecondary']),
    );
  }

  Map<String, dynamic> toJson() =>
  {
    'stage': stage,
    'command': command,
    'text': text,
    'left': left,
    'width': width,
    'top': top,
    'height': height,
    'fontColor': fontColor,
    'primaryColor': primaryColor,
    'secondaryColor': secondaryColor,
    'fontSize': fontSize,
    'viewType': viewType,
    'primaryImageResource': primaryImageResource,
    'secondaryImageResource': secondaryImageResource,
    'primaryImage': primaryImage,
    'secondaryImage': secondaryImage,
    'fontName': fontName,
    'fontType': fontType,
    'commandSecondary': commandSecondary
  };
}