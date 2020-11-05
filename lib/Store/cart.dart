import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/Address/address.dart';

import 'package:ecommerceapp/Config/config.dart';
import 'package:ecommerceapp/Counters/cartitemcounter.dart';
import 'package:ecommerceapp/Counters/totalMoney.dart';
import 'package:ecommerceapp/Models/item.dart';
import 'package:ecommerceapp/Store/storehome.dart';

import 'package:ecommerceapp/Widgets/customAppBar.dart';
import 'package:ecommerceapp/Widgets/loadingWidget.dart';
import 'package:ecommerceapp/Widgets/myDrawer.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:provider/provider.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double totalAmount;

  @override
  void initState() {
    super.initState();
    totalAmount = 0;
    Provider.of<TotalAmount>(context, listen: false).displayTotal(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      drawer: MyDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (EcommerceApp.sharedPreferences
                  .getStringList(EcommerceApp.userCartList)
                  .length ==
              1) {
            Fluttertoast.showToast(msg: "your cart is Empty");
          } else {
            Route route = MaterialPageRoute(
                builder: (c) => Address(totalAmount: totalAmount));
            Navigator.pushReplacement(context, route);
          }
        },
        label: Text("Check Out"),
        backgroundColor: Colors.pinkAccent,
        icon: Icon(Icons.navigate_next),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Consumer2<TotalAmount, CartItemCounter>(
              builder: (context, amountProvider, cartProvider, c) {
                return Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: cartProvider.count == 0
                        ? Container()
                        : Text(
                            "Total price \$ ${amountProvider.totalAmount.toString()}",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20.2,
                                fontWeight: FontWeight.w500),
                          ),
                  ),
                );
              },
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: EcommerceApp.firestore
                .collection("items")
                .where('shortInfo',
                    whereIn: EcommerceApp.sharedPreferences
                        .getStringList(EcommerceApp.userCartList))
                .snapshots(),
            builder: (context, snaphot) {
              return !snaphot.hasData
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: circularProgress(),
                      ),
                    )
                  : snaphot.data.documents.length == 0
                      ? beginbuildingCart()
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              ItemModel model = ItemModel.fromJson(
                                  snaphot.data.documents[index].data);
                              if (index == 0) {
                                totalAmount = 0;
                                totalAmount = model.price + totalAmount;
                              } else {
                                totalAmount = model.price + totalAmount;
                              }
                              if (snaphot.data.documents.length - 1 == index) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((timeStamp) {
                                  Provider.of<TotalAmount>(context,
                                          listen: false)
                                      .displayTotal(totalAmount);
                                });
                              }
                              return sourceInfo(model, context,
                                  removeCartFunction: () =>
                                      removeItemFromUserCart(model.shortInfo));
                            },
                            childCount: snaphot.hasData
                                ? snaphot.data.documents.length
                                : 0,
                          ),
                        );
            },
          ),
        ],
      ),
    );
  }

  beginbuildingCart() {
    return SliverToBoxAdapter(
      child: Card(
        color: Theme.of(context).primaryColor.withOpacity(0.5),
        child: Container(
          height: 100.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.insert_emoticon,
                color: Colors.white,
              ),
              Text("Cart is empty"),
              Text("Start adding items to your cart"),
            ],
          ),
        ),
      ),
    );
  }

  removeItemFromUserCart(String shortInfo) {
    List tempList =
        EcommerceApp.sharedPreferences.getStringList(EcommerceApp.userCartList);
    tempList.remove(shortInfo);
    EcommerceApp.firestore
        .collection(EcommerceApp.collectionUser)
        .document(
            EcommerceApp.sharedPreferences.getString(EcommerceApp.userUID))
        .updateData({
      EcommerceApp.userCartList: tempList,
    }).then((value) {
      Fluttertoast.showToast(msg: "Item removed successfully");
      EcommerceApp.sharedPreferences
          .setStringList(EcommerceApp.userCartList, tempList);
      Provider.of<CartItemCounter>(context, listen: false).displayResult();
      totalAmount = 0;
    });
  }
}
