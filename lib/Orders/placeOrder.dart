import 'package:ecommerceapp/Config/config.dart';
import 'package:ecommerceapp/Counters/cartitemcounter.dart';
import 'package:ecommerceapp/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PaymentPage extends StatefulWidget {
  final String addressId;
  final double totalAmount;

  PaymentPage({this.addressId, this.totalAmount});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: BoxDecoration(
          gradient: new LinearGradient(
            colors: [
              Colors.black,
              Colors.grey,
            ],
            begin: const FractionalOffset(1.0, 0.0),
            end: const FractionalOffset(0.0, 0.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
        child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [
          Padding(padding: (EdgeInsets.all(8.0)),child: Image.asset("images/cash.png"),),

          SizedBox(height: 10.0,),
          FlatButton(
            color:Colors.pink,
            textColor: Colors.white,
            padding: EdgeInsets.all(8.0),
            splashColor: Colors.deepOrange,
            onPressed: ()=>addOrderDetails(),
            child: Text('Place Order',style: TextStyle(fontSize: 30.0),),
          ),

        ],),),
      ),
    );
  }

  addOrderDetails() {
    WriteOrderDetailsForUser({
      EcommerceApp.addressID: widget.addressId,
      EcommerceApp.totalAmount: widget.totalAmount,
      "orderBy": EcommerceApp.sharedPreferences.getString(EcommerceApp.userUID),
      EcommerceApp.productID: EcommerceApp.sharedPreferences
          .getStringList(EcommerceApp.userCartList),
      EcommerceApp.paymentDetails: "Cash on Delivery",
      EcommerceApp.orderTime: DateTime.now().millisecondsSinceEpoch.toString(),
      EcommerceApp.isSuccess: true,
    });
    WriteOrderDetailsForAdmin({
      EcommerceApp.addressID: widget.addressId,
      EcommerceApp.totalAmount: widget.totalAmount,
      "orderBy": EcommerceApp.sharedPreferences.getString(EcommerceApp.userUID),
      EcommerceApp.productID: EcommerceApp.sharedPreferences
          .getStringList(EcommerceApp.userCartList),
      EcommerceApp.paymentDetails: "Cash on Delivery",
      EcommerceApp.orderTime: DateTime.now().millisecondsSinceEpoch.toString(),
      EcommerceApp.isSuccess: true,
    }).then((value) {
      emptyCartnow();
    });
  }

  Future WriteOrderDetailsForUser(Map<String, dynamic> data) async {
    await EcommerceApp.firestore
        .collection(EcommerceApp.collectionUser)
        .document(
            EcommerceApp.sharedPreferences.getString(EcommerceApp.userUID))
        .collection(EcommerceApp.collectionOrders)
        .document(
            EcommerceApp.sharedPreferences.getString(EcommerceApp.userUID) +
                data['orderTime'])
        .setData(data);
  }

  Future WriteOrderDetailsForAdmin(Map<String, dynamic> data) async {
    await EcommerceApp.firestore
        .collection(EcommerceApp.collectionOrders)
        .document(
            EcommerceApp.sharedPreferences.getString(EcommerceApp.userUID) +
                data['orderTime'])
        .setData(data);
  }

  void emptyCartnow() {
    EcommerceApp.sharedPreferences
        .setStringList(EcommerceApp.userCartList, ['garbageValue']);
    List tempList =
        EcommerceApp.sharedPreferences.getStringList(EcommerceApp.userCartList);
    Firestore.instance
        .collection('users')
        .document(
            EcommerceApp.sharedPreferences.getString(EcommerceApp.userUID))
        .updateData({EcommerceApp.userCartList: tempList}).then((value) {
      EcommerceApp.sharedPreferences
          .setStringList(EcommerceApp.userCartList, tempList);
      Provider.of<CartItemCounter>(context, listen: false).displayResult();
    });
    Fluttertoast.showToast(
        msg: "Congratulation your order has been placed successfully");
    Route route = MaterialPageRoute(builder: (c) => SplashScreen());
    Navigator.pushReplacement(context, route);
  }
}
