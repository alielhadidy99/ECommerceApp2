import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/Address/address.dart';
import 'package:ecommerceapp/Admin/adminUploadItems.dart';
import 'package:ecommerceapp/Config/config.dart';
import 'package:ecommerceapp/Models/address.dart';
import 'package:ecommerceapp/Widgets/customAppBar.dart';
import 'package:ecommerceapp/Widgets/loadingWidget.dart';
import 'package:ecommerceapp/Widgets/orderCard.dart';
import 'package:ecommerceapp/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

String getOrderId = "";

class AdminOrderDetails extends StatelessWidget {
  final String orderId;
  final String addressId;
  final String orderBy;

  AdminOrderDetails({this.orderId, this.addressId, this.orderBy});

  @override
  Widget build(BuildContext context) {
    getOrderId = orderId;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: FutureBuilder<DocumentSnapshot>(
            future: EcommerceApp.firestore
                .collection(EcommerceApp.collectionOrders).document(getOrderId).get(),
            builder: (c, snapshot) {
              Map dataMap;
              if (snapshot.hasData) {
                dataMap = snapshot.data.data;
              }
              return snapshot.hasData
                  ? Container(
                      child: Column(
                        children: [
                            AdminStatusBanner(
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
                                .document(orderBy)
                                .collection(EcommerceApp.subCollectionAddress)
                                .document(addressId)
                                .get(),
                            builder: (c, dataSnapshot) {
                              return dataSnapshot.hasData
                                  ? AdminShippingDetails(
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
        ),
      ),
    );
  }
}

class AdminStatusBanner extends StatelessWidget {
  final bool status;

  AdminStatusBanner({this.status});

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
            'Order shiped ' + msg,
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

class AdminShippingDetails extends StatelessWidget {
  final AddressModel model;

  AdminShippingDetails({this.model});

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
                confirmeParcalShifted(context, getOrderId);
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
                    "Confirm || Parcal shifted",
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

  void confirmeParcalShifted(BuildContext context, String mOrderId) {
    EcommerceApp.firestore
        .collection(EcommerceApp.collectionOrders)
        .document(mOrderId)
        .delete();
    getOrderId = "";
    Route route = MaterialPageRoute(builder: (c) => UploadPage());
    Navigator.pushReplacement(context, route);
    Fluttertoast.showToast(msg: "Parcal has been shifted. Confirmed");
  }
}
