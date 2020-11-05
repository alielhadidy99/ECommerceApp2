import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/Admin/adminOrderCard.dart';
import 'package:ecommerceapp/Config/config.dart';
import 'package:ecommerceapp/Widgets/myDrawer.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Widgets/loadingWidget.dart';
import '../Widgets/orderCard.dart';

class AdminShiftOrders extends StatefulWidget {
  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<AdminShiftOrders> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
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
          ),
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
          title: Text(
            'My Orders',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.arrow_drop_down_circle,
                color: Colors.white,
              ),
              onPressed: () {
                SystemNavigator.pop();
              },
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection("orders").snapshots(),
          builder: (c, snapshot) {
            return snapshot.hasData
                ? ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (c, index) {
                      return FutureBuilder<QuerySnapshot>(
                        future: Firestore.instance
                            .collection("items")
                            .where("shortInfo",
                                whereIn: snapshot.data.documents[index]
                                    .data[EcommerceApp.productID])
                            .getDocuments(),
                        builder: (c, snap) {
                          return snap.hasData
                              ? AdminOrderCard(
                                  itemCount: snap.data.documents.length,
                                  data: snap.data.documents,
                                  orderId:
                                      snapshot.data.documents[index].documentID,
                            orderBy: snapshot.data.documents[index].data['orderBy'],
                            addressId: snapshot.data.documents[index].data['addressID'],
                                )
                              : Center(
                                  child: circularProgress(),
                                );
                        },
                      );
                    },
                  )
                : Center(
                    child: circularProgress(),
                  );
          },
        ),
      ),
    );
  }
}
