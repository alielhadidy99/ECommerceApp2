import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/Admin/adminOrderDetails.dart';
import 'package:ecommerceapp/Models/item.dart';
import 'package:ecommerceapp/Orders/OrderDetailsPage.dart';
import 'package:ecommerceapp/Widgets/orderCard.dart';

import 'package:flutter/material.dart';

import '../Store/storehome.dart';

int counter = 0;

class AdminOrderCard extends StatelessWidget {
  final int itemCount;
  final List<DocumentSnapshot> data;
  final String orderId;
  final String addressId;
  final String orderBy;

  AdminOrderCard(
      {this.itemCount, this.data, this.orderId, this.addressId, this.orderBy});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Route route;
        if (counter == 0) {
          counter = counter + 1;
          route = MaterialPageRoute(
              builder: (c) => AdminOrderDetails(
                  orderId: orderId, orderBy: orderBy, addressId: addressId));
        }
        Navigator.pushReplacement(context, route);
      },
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
        padding: EdgeInsets.all(10.0),
        margin: EdgeInsets.all(10.0),
        height: itemCount * 190.0,
        child: ListView.builder(
          itemBuilder: (c, index) {
            ItemModel model = ItemModel.fromJson(data[index].data);
            return sourceOrderInfo(model, context);
          },
          itemCount: itemCount,
          physics: NeverScrollableScrollPhysics(),
        ),
      ),
    );
  }
}


