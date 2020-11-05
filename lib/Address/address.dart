import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/Config/config.dart';
import 'package:ecommerceapp/Counters/changeAddresss.dart';
import 'package:ecommerceapp/Models/address.dart';
import 'package:ecommerceapp/Orders/placeOrder.dart';
import 'package:ecommerceapp/Widgets/customAppBar.dart';
import 'package:ecommerceapp/Widgets/loadingWidget.dart';
import 'package:ecommerceapp/Widgets/myDrawer.dart';
import 'package:ecommerceapp/Widgets/wideButton.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'addAddress.dart';

class Address extends StatefulWidget {
  final double totalAmount;
  @override
  _AddressState createState() => _AddressState();

  const Address({Key key, this.totalAmount}) : super(key: key);
}

class _AddressState extends State<Address> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Select adress",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0),
                ),
              ),
            ),
            Consumer<AddressChanger>(builder: (context, address, c) {
              return Flexible(
                  child: StreamBuilder<QuerySnapshot>(
                stream: EcommerceApp.firestore
                    .collection(EcommerceApp.collectionUser)
                    .document(EcommerceApp.sharedPreferences
                        .getString(EcommerceApp.userUID))
                    .collection(EcommerceApp.subCollectionAddress)
                    .snapshots(),
                builder: (context, snapshot) {
                  return !snapshot.hasData
                      ? Center(child: circularProgress())
                      : snapshot.data.documents.length == 0
                          ? noAddressCard()
                          : ListView.builder(
                              itemCount: snapshot.data.documents.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return AddressCard(
                                  currentIndex: address.count,
                                  value: index,
                                  addressId:
                                      snapshot.data.documents[index].documentID,
                                  totalAmount: widget.totalAmount,
                                  model: AddressModel.fromJson(
                                      snapshot.data.documents[index].data),
                                );
                              },
                            );
                },
              ));
            }),
          ],
        ),
        appBar: MyAppBar(),
        drawer: MyDrawer(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Route route = MaterialPageRoute(builder: (c) => AddAddress());
            Navigator.pushReplacement(context, route);
          },
          label: Text("Add new address"),
          backgroundColor: Colors.pinkAccent,
          icon: Icon(Icons.add_location),
        ),
      ),
    );
  }

  noAddressCard() {
    return Card(
      color: Colors.pink.withOpacity(0.5),
      child: Container(
        height: 100.0,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_location,
              color: Colors.white,
            ),
            Text('No shipment address has been saved'),
            Text(
                "Pleasa add your shipment address so that we can deliver product"),
          ],
        ),
      ),
    );
  }
}

class AddressCard extends StatefulWidget {
  final AddressModel model;
  final int currentIndex;
  final int value;
  final String addressId;
  final double totalAmount;

  AddressCard(
      {this.model,
      this.currentIndex,
      this.value,
      this.addressId,
      this.totalAmount});

  @override
  _AddressCardState createState() => _AddressCardState();
}

class _AddressCardState extends State<AddressCard> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () {
        Provider.of<AddressChanger>(context, listen: false)
            .displayResult(widget.value);
      },
      child: Card(
        color: Colors.pinkAccent.withOpacity(0.4),
        child: Column(
          children: [
            Row(
              children: [
                Radio(
                  groupValue: widget.currentIndex,
                  value: widget.value,
                  activeColor: Colors.pink,
                  onChanged: (val) {
                    Provider.of<AddressChanger>(context, listen: false)
                        .displayResult(val);
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.0),
                      width: screenWidth * 0.8,
                      child: Table(
                        children: [
                          TableRow(children: [
                            KeyText(
                              msg: "Name",
                            ),
                            Text(widget.model.name),
                          ]),
                          TableRow(children: [
                            KeyText(
                              msg: "Phone Number",
                            ),
                            Text(widget.model.phoneNumber),
                          ]),
                          TableRow(children: [
                            KeyText(
                              msg: "Flat Number",
                            ),
                            Text(widget.model.flatNumber),
                          ]),
                          TableRow(children: [
                            KeyText(
                              msg: "City",
                            ),
                            Text(widget.model.city),
                          ]),
                          TableRow(children: [
                            KeyText(
                              msg: "Pin Code",
                            ),
                            Text(widget.model.pincode),
                          ]),
                          TableRow(children: [
                            KeyText(
                              msg: "Country",
                            ),
                            Text(widget.model.state),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            widget.value == Provider.of<AddressChanger>(context).count
                ? WideButton(
                    message: 'Proceed',
                    onPressed: () {
                      Route route = MaterialPageRoute(
                          builder: (c) => PaymentPage(
                                addressId: widget.addressId,
                                totalAmount: widget.totalAmount,
                              ));
                      Navigator.push(context, route);
                    },
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}

class KeyText extends StatelessWidget {
  final String msg;

  KeyText({this.msg});

  @override
  Widget build(BuildContext context) {
    return Text(
      msg,
      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
    );
  }
}
