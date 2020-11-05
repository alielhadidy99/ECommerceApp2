import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/Config/config.dart';
import 'package:ecommerceapp/Counters/cartitemcounter.dart';
import 'package:ecommerceapp/Store/product_page.dart';
import 'package:ecommerceapp/Widgets/customAppBar.dart';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../Widgets/loadingWidget.dart';
import '../Widgets/myDrawer.dart';
import '../Widgets/searchBox.dart';
import '../Models/item.dart';
import 'cart.dart';

double width;

class StoreHome extends StatefulWidget {
  @override
  _StoreHomeState createState() => _StoreHomeState();
}

class _StoreHomeState extends State<StoreHome> {
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(),
        drawer: MyDrawer(),
        body: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              delegate: SearchBoxDelegate(),
              pinned: true,
            ),
            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection('items')
                  .limit(15)
                  .orderBy('publishedDate', descending: true)
                  .snapshots(),
              builder: (context, dataSnapshot) {
                return !dataSnapshot.hasData
                    ? SliverToBoxAdapter(
                        child: Center(
                          child: circularProgress(),
                        ),
                      )
                    : SliverStaggeredGrid.countBuilder(
                        crossAxisCount: 1,
                        staggeredTileBuilder: (c) => StaggeredTile.fit(1),
                        itemBuilder: (context, index) {
                          ItemModel model = ItemModel.fromJson(
                              dataSnapshot.data.documents[index].data);
                          return sourceInfo(model, context);
                        },
                        itemCount: dataSnapshot.data.documents.length);
              },
            ),
          ],
        ),
      ),
    );
  }
}

Widget sourceInfo(ItemModel model, BuildContext context,
    {Color background, removeCartFunction}) {
  return InkWell(
    onTap: () {
      Route route = MaterialPageRoute(
          builder: (c) => ProductPage(
                itemModel: model,
              ));
      Navigator.pushReplacement(context, route);
    },
    splashColor: Colors.pink,
    child: Padding(
      padding: EdgeInsets.all(6),
      child: Container(
        height: 190,
        width: width,
        child: Row(
          children: [
            Image.network(
              model.thumbnailUrl,
              width: 140,
              height: 140,
            ),
            SizedBox(
              width: 4,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Text(
                            model.title,
                            style: TextStyle(color: Colors.black, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Text(
                            model.shortInfo,
                            style:
                                TextStyle(color: Colors.black54, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.rectangle, color: Colors.blue),
                        alignment: Alignment.topLeft,
                        width: 40.0,
                        height: 43.0,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "50",
                                style: TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal),
                              ),
                              Text(
                                "OFF",
                                style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: (EdgeInsets.only(top: 0.0)),
                            child: Row(
                              children: [
                                Text(
                                  r"Original price: $ ",
                                  style: TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      fontSize: 14.0,
                                      color: Colors.grey),
                                ),
                                Text(
                                  (model.price + model.price).toString(),
                                  style: TextStyle(
                                      fontSize: 15.0,
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: (EdgeInsets.only(top: 5.0)),
                            child: Row(
                              children: [
                                Text(
                                  r"New price: ",
                                  style: TextStyle(
                                      fontSize: 14.0, color: Colors.grey),
                                ),
                                Text(
                                  "\$ ",
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 16.0),
                                ),
                                Text(
                                  (model.price).toString(),
                                  style: TextStyle(
                                      fontSize: 15.0, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  Flexible(
                    child: Container(),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: removeCartFunction == null
                        ? IconButton(
                            icon: Icon(
                              Icons.add_shopping_cart,
                              color: Colors.pinkAccent,
                            ),
                            onPressed: () {
                              checkItemInCart(model.shortInfo, context);
                            },
                          )
                        : IconButton(
                            icon: Icon(
                              Icons.remove_shopping_cart,
                              color: Colors.pinkAccent,
                            ),
                            onPressed: () {
                              removeCartFunction();
                              Route route = MaterialPageRoute(
                                  builder: (c) => StoreHome());
                              Navigator.pushReplacement(context, route);
                            },
                          ),
                  ),
                  Divider(
                    height: 5.0,
                    color: Colors.pink,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget card({Color primaryColor = Colors.redAccent, String imgPath}) {
  return Container(
    height: 150.0,
    width: width * .34,
    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: <BoxShadow>[
          BoxShadow(
              offset: Offset(0, 5), blurRadius: 10.0, color: Colors.grey[200]),
        ]),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: Image.network(
        imgPath,
        height: 150.0,
        width: width * .34,
        fit: BoxFit.fill,
      ),
    ),
  );
}

void checkItemInCart(String shortInfoId, BuildContext context) {
  EcommerceApp.sharedPreferences
          .getStringList(EcommerceApp.userCartList)
          .contains(shortInfoId)
      ? Fluttertoast.showToast(msg: "Item already in cart")
      : addItemTocart(shortInfoId, context);
}

addItemTocart(String shortInfoId, BuildContext context) {
  List tempList =
      EcommerceApp.sharedPreferences.getStringList(EcommerceApp.userCartList);
  tempList.add(shortInfoId);
  EcommerceApp.firestore
      .collection(EcommerceApp.collectionUser)
      .document(EcommerceApp.sharedPreferences.getString(EcommerceApp.userUID))
      .updateData({
    EcommerceApp.userCartList: tempList,
  }).then((value) {
    Fluttertoast.showToast(msg: "Item Added to cart successfully");
    EcommerceApp.sharedPreferences
        .setStringList(EcommerceApp.userCartList, tempList);
    Provider.of<CartItemCounter>(context, listen: false).displayResult();
  });
}
