import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/Address/address.dart';
import 'package:ecommerceapp/Config/config.dart';
import 'package:ecommerceapp/Models/address.dart';
import 'package:ecommerceapp/Widgets/customAppBar.dart';
import 'package:ecommerceapp/Widgets/loadingWidget.dart';
import 'package:ecommerceapp/Widgets/myDrawer.dart';
import 'package:ecommerceapp/Widgets/orderCard.dart';
import 'package:ecommerceapp/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

String getOrderId = "";

class OrderDetails extends StatelessWidget {
  final String orderId;

  OrderDetails({this.orderId});

  @override
  Widget build(BuildContext context) {
    getOrderId = orderId;
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(),
        drawer: MyDrawer(),
        body: (SingleChildScrollView(
          child: FutureBuilder<DocumentSnapshot>(
            future: EcommerceApp.firestore
                .collection(EcommerceApp.collectionUser)
                .document(EcommerceApp.sharedPreferences
                    .getString(EcommerceApp.userUID))
                .collection(EcommerceApp.collectionOrders)
                .document(orderId)
                .get(),
            builder: (c, snapshot) {
              Map dataMap;
              if (snapshot.hasData) {
                dataMap = snapshot.data.data;
              }
              return snapshot.hasData
                  ? Container(
                      child: Column(
                        children: [
                          StatusBanner(
                            status: dataMap[EcommerceApp.isSuccess],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "\$ " +
                                    dataMap[EcommerceApp.totalAmount]
                                        .toString(),
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Text('Order ID :' + getOrderId),
                          ),
                          Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Text(
                              'Order at:' +
                                  DateFormat("dd MMMM, yyyy - hh:mm aa").format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(dataMap['orderTime'])),
                                  ),
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 16.0),
                            ),
                          ),
                          Divider(
                            height: 2.0,
                          ),
                          FutureBuilder<QuerySnapshot>(
                            builder: (c, dataSnapshot) {
                              return dataSnapshot.hasData
                                  ? OrderCard(
                                      data: dataSnapshot.data.documents,
                                      itemCount:
                                          dataSnapshot.data.documents.length,
                                    )
                                  : Center(
                                      child: circularProgress(),
                                    );
                            },
                            future: EcommerceApp.firestore
                                .collection("items")
                                .where("shortInfo",
                                    whereIn: dataMap[EcommerceApp.productID])
                                .getDocuments(),
                          ),
                          Divider(
                            height: 2.0,
                          ),
                          FutureBuilder<DocumentSnapshot>(
                            future: EcommerceApp.firestore
                                .collection(EcommerceApp.collectionUser)
                                .document(EcommerceApp.sharedPreferences
                                    .getString(EcommerceApp.userUID))
                                .collection(EcommerceApp.subCollectionAddress)
                                .document(dataMap[EcommerceApp.addressID])
                                .get(),
                            builder: (c, dataSnapshot) {
                              return dataSnapshot.hasData
                                  ? ShippingDetails(
                                      model: AddressModel.fromJson(
                                          dataSnapshot.data.data),
                                    )
                                  : Center(
                                      child: circularProgress(),
                                    );
                            },
                          ),
                        ],
                      ),
                    )
                  : Center(
                      child: circularProgress(),
                    );
            },
          ),
        )),
      ),
    );
  }
}

class StatusBanner extends StatelessWidget {
  final bool status;

  StatusBanner({this.status});

  @override
  Widget build(BuildContext context) {
    String msg;
    IconData iconData;

    status ? iconData = Icons.done : iconData = Icons.cancel;
    status ? msg = "Successful" : msg = "UnSuccessful";
    return Container(
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
      height: 40.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => SystemNavigator.pop(),
            child: Container(
              child: Icon(
                Icons.arrow_drop_down_circle,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            width: 20.0,
          ),
          Text(
            'Order Placed ' + msg,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          SizedBox(
            width: 5.0,
          ),
          CircleAvatar(
            radius: 8.0,
            backgroundColor: Colors.grey,
            child: Icon(
              iconData,
              color: Colors.white,
              size: 14.0,
            ),
          ),
        ],
      ),
    );
  }
}

class ShippingDetails extends StatelessWidget {
  final AddressModel model;

  ShippingDetails({this.model});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 20.0,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(
            "shipment Details",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 90.0, vertical: 5.0),
          width: screenWidth,
          child: Table(
            children: [
              TableRow(children: [
                KeyText(
                  msg: "Name",
                ),
                Text(model.name),
              ]),
              TableRow(children: [
                KeyText(
                  msg: "Phone Number",
                ),
                Text(model.phoneNumber),
              ]),
              TableRow(children: [
                KeyText(
                  msg: "Flat Number",
                ),
                Text(model.flatNumber),
              ]),
              TableRow(children: [
                KeyText(
                  msg: "City",
                ),
                Text(model.city),
              ]),
              TableRow(children: [
                KeyText(
                  msg: "Pin Code",
                ),
                Text(model.pincode),
              ]),
              TableRow(children: [
                KeyText(
                  msg: "Country",
                ),
                Text(model.state),
              ]),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10.0),
          child: Center(
            child: InkWell(
              onTap: () {
                confirmedUserOrderReceived(context, getOrderId);
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
                width: MediaQuery.of(context).size.width - 40.0,
                height: 50.0,
                child: Center(
                  child: Text(
                    "Confirmed || Items Received",
                    style: TextStyle(color: Colors.white, fontSize: 15.0),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  void confirmedUserOrderReceived(BuildContext context, String mOrderId) {
    EcommerceApp.firestore
        .collection(EcommerceApp.collectionUser)
        .document(
            EcommerceApp.sharedPreferences.getString(EcommerceApp.userUID))
        .collection(EcommerceApp.collectionOrders)
        .document(mOrderId)
        .delete();
    getOrderId = "";
    Route route = MaterialPageRoute(builder: (c) => SplashScreen());
    Navigator.pushReplacement(context, route);
    Fluttertoast.showToast(msg: "Order has been Confirmend");
  }
}
