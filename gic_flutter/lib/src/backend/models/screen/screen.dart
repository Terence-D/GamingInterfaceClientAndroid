import 'gicControl.dart';

class Screen {
  static const MAX_CONTROL_SIZE = 800;

  int? screenId = -1;
  List<GicControl>? controls = <GicControl>[];
  //background
  int? newControlId = -1;
  int? backgroundColor;
  String? backgroundPath;
  //context;
  String? name;

  Screen({
    this.screenId = -1,
    this.controls = const[],
    this.backgroundColor = 0,
    this.backgroundPath = "",
    this.newControlId = -1,
    this.name = ""});

  factory Screen.fromJson(Map<String, dynamic> json) {
    var list = json['controls'] as List;
    List<GicControl> jsonControls = <GicControl>[];
    list.forEach((value) { jsonControls.add(GicControl.fromJson(value));});

    return Screen(
      screenId: json['screenId'],
      controls: jsonControls,
      backgroundColor: json['backgroundColor'],
      backgroundPath: json['backgroundPath'],
      newControlId: json['newControlId'],
      name: json['name']);
  }

  // factory Screen.fromModel(ScreenViewModel model, double pixelRatio) {
  //   Screen rv = new Screen();
  //   rv.screenId = model.screenId;
  //   rv.name = model.name;
  //   model.controls.forEach((element) {
  //     rv.controls.add(new ControlViewModel.fromModel(element));
  //   });
  //   rv.newControlId = model.newControlId;
  //
  //   if (model.backgroundColor == -1 || model.backgroundColor == null)
  //     rv.backgroundColor = Colors.black;
  //   else
  //     rv.backgroundColor = _convertJavaColor(model.backgroundColor);
  //   rv.backgroundPath = model.backgroundPath;
  //   return rv;
  // }

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
    newControlId = newControlId! + 1;
    return newControlId! - 1;
  }

}
