import 'package:flutter/material.dart';
import 'package:gic_flutter/model/intl/intlLauncher.dart';
import 'package:gic_flutter/views/accentButton.dart';
import 'package:gic_flutter/views/main/mainVM.dart';

class ScreenList extends StatelessWidget {

  final List<ScreenListItem> _screens;
  final IntlLauncher _translations;
  final List<TextEditingController> _screenNameController = new List<TextEditingController>();

  ScreenList(this._screens, this._translations);

  @override
  Widget build(BuildContext context) {
    _screenNameController.clear();
    for (var i = 0; i < _screens.length; i++) {
      TextEditingController tec = new TextEditingController();
      tec.text = _screens[i].name;
      _screenNameController.add(tec);
    }

    return Expanded(
      child: ListView.builder(
          itemCount: _screenNameController.length,
          itemBuilder: (context, index) {
            return screenCard(index, context);
          }),
    ); //
  }

  Container screenCard(int index, BuildContext context) {
//    GlobalKey screenCard;
//    if (index == 0)
//      screenCard = _screenListKey;
//    else
//      screenCard = new GlobalObjectKey("manageScreenList" + index.toString());
    return Container(
        height: 160,
        width: double.maxFinite,
//        key: screenCard,
        child: Card(
          elevation: 5,
          child:
          new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              screenName(index),
              screenButtons(index, context)
            ],
          ),
        )
    );
  }

  Container screenButtons(int index, BuildContext context) {
//    GlobalKey export;
//    GlobalKey update;
//    GlobalKey edit;
//    GlobalKey delete;
//    if (index == 0) {
//      export = _screenListExportKey;
//      update = _screenListUpdateKey;
//      edit = _screenListEditKey;
//      delete = _screenListDeleteKey;
//    } else {
//      export = new GlobalObjectKey("export" + index.toString());
//      update = new GlobalObjectKey("update" + index.toString());
//      edit = new GlobalObjectKey("edit" + index.toString());
//      delete = new GlobalObjectKey("delete" + index.toString());
//    }
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new AccentButton(
              child: Text(_translations.text(LauncherText.start)),
//            key: update,
              onPressed: () {
//              (presentation as ManagePresentation).updateScreenName(
//                  index, screenNameController[index].text);
              },
            ),
            new IconButton(
              icon: Icon(Icons.edit),
              tooltip:_translations.text(LauncherText.buttonEdit),
//            key: edit,
              onPressed: () {
//              (presentation as ManagePresentation).editScreen(index);
              },
            ),
            new IconButton(
              icon: Icon(Icons.share),
              tooltip: _translations.text(LauncherText.buttonExport),
//            key: export,
              onPressed: () {
//              (presentation as ManagePresentation).exportScreen(index);
              },
            ),
            new IconButton(
              color: Theme.of(context).errorColor,
              icon: Icon(Icons.delete_forever),
              tooltip: _translations.text(LauncherText.buttonDelete),
//            key: delete,
              onPressed: () {
//              _confirmDialog(index, _viewModel.screens[index].name);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget screenName(int index) {
    return
      Expanded(
          child:
          Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  new Flexible(
                    child: new TextFormField(
                      controller: _screenNameController[index],
                      decoration: InputDecoration(
                          hintText: _translations.text(LauncherText.screenName)),
                    ),
                  ),
                  new IconButton(
                    icon: Icon(Icons.save),
                    tooltip:_translations.text(LauncherText.buttonUpdate),
//            key: update,
                    onPressed: () {
//              (presentation as ManagePresentation).updateScreenName(
//                  index, screenNameController[index].text);
                    },
                  ),
                ],
              )
          )
      );
  }
}