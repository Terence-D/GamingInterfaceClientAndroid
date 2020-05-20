import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:gic_flutter/model/intl/localizations.dart';
import 'package:gic_flutter/model/viewModel.dart';
import 'package:gic_flutter/views/HighlighterHelp.dart';
import 'package:highlighter_coachmark/highlighter_coachmark.dart';

import '../basePage.dart';
import 'managePresentation.dart';
import 'manageVM.dart';

class ManageView extends BasePage {
  @override
  ManageViewState createState() {
    return ManageViewState();
  }
}

class ManageViewState extends BaseState<ManageView> {
  ManageVM _viewModel;

  GlobalKey _newKey = GlobalObjectKey("manageNew");
  GlobalKey _screenListKey = GlobalObjectKey("manageScreenList0");
  GlobalKey _screenListExportKey = GlobalObjectKey("manageScreenExport0");
  GlobalKey _screenListUpdateKey = GlobalObjectKey("manageScreenUpdate0");
  GlobalKey _screenListEditKey = GlobalObjectKey("manageScreenEdit0");
  GlobalKey _screenListDeleteKey = GlobalObjectKey("manageScreenDelete0");
  GlobalKey _importKey = GlobalObjectKey("manageImport");

  List<TextEditingController> screenNameController = new List<TextEditingController>();

  Queue<HighligherHelp> highlights = new Queue();

  @override
  void initState() {
    presentation = new ManagePresentation(this);
    super.initState();
  }

  @override
  void onLoadComplete(ViewModel viewModel) {
    setState(() {
      this._viewModel = viewModel;
      screenNameController = new List<TextEditingController>();
      for (var i = 0; i < _viewModel.screens.length; i++) {
        TextEditingController tec = new TextEditingController();
        tec.text = _viewModel.screens[i].name;
        screenNameController.add(tec);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text(_viewModel.toolbarTitle),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.help_outline),
                onPressed: () {
                  _loadHelp();
                }),
            // overflow menu
            PopupMenuButton<int>(
                onSelected: _menuSelectAction,
                itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<int>>[
                  PopupMenuItem<int>(
                      value: 0,
                      child: Text(_viewModel.btnImport)
                  )
                ]
            )
          ],
        ),
        body: Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                    itemCount: screenNameController.length,
                    itemBuilder: (context, index) {
                      return screenCard(index);
                    }),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
            key: _newKey,
            onPressed: () {
              (presentation as ManagePresentation).newScreen();
            },
            label: Text(_viewModel.btnNew)
        )
    ); //
  }

  void _menuSelectAction(int choice) {
    (presentation as ManagePresentation).importScreen();
  }

  Container screenCard(int index) {
    GlobalKey screenCard;
    if (index == 0)
      screenCard = _screenListKey;
    else
      screenCard = new GlobalObjectKey("manageScreenList" + index.toString());

    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
      height: 160,
      width: double.maxFinite,
      key: screenCard,
      child: Card(
        elevation: 5,
        child:
        new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              screenName(index),
              screenButtons(index)
            ],
          ),
      )
    );
  }

  Container screenButtons(int index) {
    GlobalKey export;
    GlobalKey update;
    GlobalKey edit;
    GlobalKey delete;
    if (index == 0) {
      export = _screenListExportKey;
      update = _screenListUpdateKey;
      edit = _screenListEditKey;
      delete = _screenListDeleteKey;
    } else {
      export = new GlobalObjectKey("export" + index.toString());
      update = new GlobalObjectKey("update" + index.toString());
      edit = new GlobalObjectKey("edit" + index.toString());
      delete = new GlobalObjectKey("delete" + index.toString());
    }
    return Container(
      child: new ButtonBar(
        children: <Widget>[
          new FlatButton(
            child: Text(_viewModel.btnUpdate),
            key: update,
            onPressed: () {
              (presentation as ManagePresentation).updateScreenName(index, screenNameController[index].text);
            },
          ),
          new FlatButton(
            child: Text(_viewModel.btnEdit),
            key: edit,
            onPressed: () {
              (presentation as ManagePresentation).editScreen(index);
            },
          ),
          new FlatButton(
            child: Text(_viewModel.btnExport),
            key: export,
            onPressed: () {
              (presentation as ManagePresentation).exportScreen(index);
            },
          ),
          new FlatButton(
            color: Theme.of(context).errorColor,
            key: delete,
            child: Text(_viewModel.btnDelete),
            onPressed: () {
              (presentation as ManagePresentation).deleteScreen(index);
            },
          ),
        ],
      ),
    );
  }

  Widget screenName(int index) {
    return
      Expanded(
        child:
      Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              new Flexible(
               child: new TextFormField(
                 controller: screenNameController[index],
                 decoration: InputDecoration(hintText: _viewModel.screenName),
               ),
              ),
            ],
          )
    )
      );
    }

  void _loadHelp() {
    highlights = new Queue();
    highlights.add(new HighligherHelp(
        _viewModel.helpScreenList,
        _screenListKey,
        .5,
        MainAxisAlignment.center));
    highlights.add(new HighligherHelp(
        _viewModel.helpUpdate,
        _screenListUpdateKey,
        1,
        MainAxisAlignment.center));
    highlights.add(new HighligherHelp(
        _viewModel.helpEdit,
        _screenListEditKey,
        1,
        MainAxisAlignment.center));
    highlights.add(new HighligherHelp(
        _viewModel.helpExport,
        _screenListExportKey,
        1,
        MainAxisAlignment.center));
    highlights.add(new HighligherHelp(
        _viewModel.helpDelete,
        _screenListDeleteKey,
        1,
        MainAxisAlignment.center));
    highlights.add(new HighligherHelp(
        _viewModel.helpImport,
        _importKey,
        1,
        MainAxisAlignment.center));
    highlights.add(new HighligherHelp(
        _viewModel.helpNew,
        _newKey,
        1,
        MainAxisAlignment.center));

    _showHelp();
  }

  void _showHelp() {
    if (highlights.isNotEmpty) {
      HighligherHelp toShow = highlights.removeFirst();
      _helpDisplay(toShow.text, toShow.highlight, toShow.highlightSize, toShow.alignment);
    }
  }

  void _helpDisplay(
    String text, GlobalKey key, lengthModifier, MainAxisAlignment alignment) {
    CoachMark coachMarkFAB = CoachMark();
    RenderBox target = key.currentContext.findRenderObject();

    Rect markRect = target.localToGlobal(Offset.zero) & target.size;

    double _length = markRect.longestSide;
    if (lengthModifier > 0) _length = markRect.longestSide * lengthModifier;

    markRect = Rect.fromLTWH(markRect.left, markRect.top, _length, markRect.height);

    coachMarkFAB.show(
        targetContext: _newKey.currentContext,
        markRect: markRect,
        children: [
          Column(
              mainAxisAlignment: alignment,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(text,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    )),
                RaisedButton(
                    child: new Text(Intl.of(context).mainNext),
                    onPressed: () {
                      _showHelp();
                    }),
              ])
        ],
        duration: null,
        onClose: () {});
  }
}