import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/viewModel.dart';
import 'package:gic_flutter/src/theme/dimensions.dart' as dim;
import 'package:gic_flutter/src/views/donate/donateVM.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../basePage.dart';
import 'donatePresentation.dart';

class DonateView extends BasePage {
  @override
  DonateViewState createState() {
    return DonateViewState();
  }
}

const String _kCoffee = 'coffee';
const String _kStar = 'star';
const List<String> _kProductIds = <String>[
  _kCoffee,
  _kStar,
];

class DonateViewState extends BaseState<DonateView> {
  DonateVM viewModel = DonateVM();

  //IAP stuff
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>> _subscription;
  List<String> _notFoundIds = [];
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];
  List<String> _consumables = [];
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = true;
  String _queryProductError;

  @override
  void initState() {
    presentation = DonatePresentation(this);
    super.initState();
  }

  @override
  void dispose() {
    // if (Platform.isIOS) {
    //   var iosPlatformAddition = _inAppPurchase
    //       .getPlatformAddition<InAppPurchaseIosPlatformAddition>();
    //   iosPlatformAddition.setDelegate(null);
    // }
    _subscription.cancel();
    super.dispose();
  }

  @override
  void onLoadComplete(ViewModel viewModel) {
    setState(() {
      this.viewModel = viewModel;
    });
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> stack = [];
    if (_queryProductError == null) {
      stack.add(
        ListView(
          children: [
            _buildConnectionCheckTile(),
            _buildProductList(),
            _buildRestoreButton(),
          ],
        ),
      );
    } else {
      stack.add(Center(
        child: Text(_queryProductError),
      ));
    }
    if (_purchasePending) {
      stack.add(
        Stack(
          children: [
            Opacity(
              opacity: 0.3,
              child: const ModalBarrier(dismissible: false, color: Colors.grey),
            ),
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      );
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('IAP Example'),
        ),
        body: Stack(
          children: stack,
        ),
      ),
    );

    // String title = " ";
    // if (viewModel != null && viewModel.toolbarTitle != null) {
    //   title = viewModel.toolbarTitle;
    // }
    // return Scaffold(
    //     appBar: AppBar(
    //       automaticallyImplyLeading: true,
    //       title: Text(title),
    //     ),
    //     body: SingleChildScrollView(
    //       child: Container(
    //         margin: EdgeInsets.all(dim.activityMargin),
    //         child: Column(crossAxisAlignment: CrossAxisAlignment.center,
    //           children: <Widget>[
    //             header(viewModel.title, Theme.of(context).textTheme.headline4),
    //             Text(viewModel.intro),
    //             // TextButton(onPressed: _openWikiPage, child: _onClickWiki),
    //             // TextButton(onPressed: _openWikiPage, child: _onClickWiki),
    //             // TextButton(onPressed: _openWikiPage, child: _onClickWiki),
    //           ],
    //         ),
    //       ),
    //     ),
    // );
  }

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  Future<void> _initStoreInfo() async {
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // handle error here.
    });

    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      setState(() {
        _isAvailable = isAvailable;
        _products = [];
        _purchases = [];
        _notFoundIds = [];
        _consumables = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    // if (Platform.isIOS) {
    //   var iosPlatformAddition = _inAppPurchase
    //       .getPlatformAddition<InAppPurchaseIosPlatformAddition>();
    //   await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    // }

    ProductDetailsResponse productDetailResponse =
    await _inAppPurchase.queryProductDetails(_kProductIds.toSet());
    if (productDetailResponse.error != null) {
      setState(() {
        _queryProductError = productDetailResponse.error.message;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = [];
        _notFoundIds = productDetailResponse.notFoundIDs;
        _consumables = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {
        _queryProductError = null;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = [];
        _notFoundIds = productDetailResponse.notFoundIDs;
        _consumables = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }
  }

  Card _buildConnectionCheckTile() {
    if (_loading) {
      return Card(child: ListTile(title: const Text('Trying to connect...')));
    }
    final Widget storeHeader = ListTile(
      leading: Icon(_isAvailable ? Icons.check : Icons.block,
          color: _isAvailable ? Colors.green : ThemeData.light().errorColor),
      title: Text(
          'The store is ' + (_isAvailable ? 'available' : 'unavailable') + '.'),
    );
    final List<Widget> children = <Widget>[storeHeader];

    if (!_isAvailable) {
      children.addAll([
        Divider(),
        ListTile(
          title: Text('Not connected',
              style: TextStyle(color: ThemeData.light().errorColor)),
          subtitle: const Text(
              'Unable to connect to the payments processor. Has this app been configured correctly? See the example README for instructions.'),
        ),
      ]);
    }
    return Card(child: Column(children: children));
  }

  Card _buildProductList() {
    if (_loading) {
      return Card(
          child: (ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Fetching products...'))));
    }
    if (!_isAvailable) {
      return Card();
    }
    final ListTile productHeader = ListTile(title: Text('Products for Sale'));
    List<ListTile> productList = <ListTile>[];

    Map<String, PurchaseDetails> purchases =
    Map.fromEntries(_purchases.map((PurchaseDetails purchase) {
      if (purchase.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchase);
      }
      return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
    }));
    productList.addAll(_products.map(
          (ProductDetails productDetails) {
        PurchaseDetails previousPurchase = purchases[productDetails.id];
        return ListTile(
            title: Text(
              productDetails.title,
            ),
            subtitle: Text(
              productDetails.description,
            ),
            trailing: TextButton(
              child: Text(productDetails.price),
              style: TextButton.styleFrom(
                backgroundColor: Colors.green[800],
                primary: Colors.white,
              ),
              onPressed: () {
                final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
                _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
              },
            ));
      },
    ));

    return Card(
        child:
        Column(children: <Widget>[productHeader, Divider()] + productList));
  }

  Widget _buildRestoreButton() {
    if (_loading) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            child: Text('Restore purchases'),
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              primary: Colors.white,
            ),
            onPressed: () => _inAppPurchase.restorePurchases(),
          ),
        ],
      ),
    );
  }

  void showPendingUI() {
    setState(() {
      _purchasePending = true;
    });
  }

  void deliverProduct(PurchaseDetails purchaseDetails) async {
    // IMPORTANT!! Always verify purchase details before delivering the product.
    setState(() {
      _purchases.add(purchaseDetails);
      _purchasePending = false;
    });
  }

  void handleError(IAPError error) {
    setState(() {
      _purchasePending = false;
    });
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.
    return Future<bool>.value(true);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // handle invalid purchase here if  _verifyPurchase` failed.
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          handleError(purchaseDetails.error);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            deliverProduct(purchaseDetails);
          } else {
            _handleInvalidPurchase(purchaseDetails);
            return;
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    });
  }}
