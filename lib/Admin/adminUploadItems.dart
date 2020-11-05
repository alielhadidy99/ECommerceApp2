import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/Admin/adminShiftOrders.dart';
import 'package:ecommerceapp/Widgets/loadingWidget.dart';
import 'package:ecommerceapp/main.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as ImD;

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  bool get wantKeepAlive => true;
  File imageFile;
  TextEditingController _decsController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _infoController = TextEditingController();
  String productId = DateTime.now().millisecondsSinceEpoch.toString();
  bool uploading = false;
  @override
  Widget build(BuildContext context) {
    return imageFile == null
        ? disaplyAdminHomeScreen()
        : displayAdminUploadScreen();
  }

  disaplyAdminHomeScreen() {
    return Scaffold(
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
        leading: IconButton(
          icon: Icon(
            Icons.border_color,
            color: Colors.white,
          ),
          onPressed: () {
            Route route = MaterialPageRoute(builder: (c) => AdminShiftOrders());
            Navigator.pushReplacement(context, route);
          },
        ),
        actions: [
          FlatButton(
              onPressed: () {
                Route route = MaterialPageRoute(builder: (c) => SplashScreen());
                Navigator.pushReplacement(context, route);
              },
              child: Text(
                'Logout',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold),
              ))
        ],
      ),
      body: getAdminHomeScreenBody(),
    );
  }

  getAdminHomeScreenBody() {
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shop_two,
              color: Colors.white,
              size: 200.0,
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9.0),
                ),
                child: Text(
                  "Add New Items",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white),
                ),
                color: Colors.black12,
                onPressed: () {
                  takeImage(context);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  takeImage(BuildContext mcontext) {
    return showDialog(
        context: mcontext,
        builder: (c) {
          return SimpleDialog(
            title: Text(
              'Item Image',
              style:
                  TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
            ),
            children: [
              SimpleDialogOption(
                child: Text(
                  "Capture with camera",
                  style: TextStyle(
                    color: Colors.lightGreen,
                  ),
                ),
                onPressed: capturePhotoWithCamera,
              ),
              SimpleDialogOption(
                child: Text(
                  "Select from gallery",
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
                onPressed: selectPhotoWithGallery,
              ),
              SimpleDialogOption(
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  void capturePhotoWithCamera() async {
    Navigator.pop(context);
    File image = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 680, maxWidth: 970);
    setState(() {
      imageFile = image;
    });
  }

  void selectPhotoWithGallery() async {
    Navigator.pop(context);
    File image = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      imageFile = image;
    });
  }

  displayAdminUploadScreen() {
    return Scaffold(
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
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: cleraFormInfo,
        ),
        title: Text(
          'New Product',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          FlatButton(
              onPressed: uploading ? null : () => uploadImageAndSaveItemInfo(),
              child: Text(
                'Add',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ))
        ],
      ),
      body: ListView(
        children: [
          uploading ? circularProgress() : Text(''),
          Container(
            height: 230,
            width: MediaQuery.of(context).size.width * 0.8,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: FileImage(imageFile), fit: BoxFit.cover),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 12.0),
          ),
          ListTile(
            leading: Icon(
              Icons.perm_device_info,
              color: Colors.deepPurple,
            ),
            title: Container(
              width: 250,
              child: TextField(
                style: TextStyle(color: Colors.deepPurpleAccent),
                controller: _infoController,
                decoration: InputDecoration(
                  hintText: 'Short Info',
                  hintStyle: TextStyle(color: Colors.deepPurpleAccent),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(
            color: Colors.grey,
          ),
          ListTile(
            leading: Icon(
              Icons.perm_device_info,
              color: Colors.deepPurple,
            ),
            title: Container(
              width: 250,
              child: TextField(
                style: TextStyle(color: Colors.deepPurpleAccent),
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Title',
                  hintStyle: TextStyle(color: Colors.deepPurpleAccent),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(
            color: Colors.grey,
          ),
          ListTile(
            leading: Icon(
              Icons.perm_device_info,
              color: Colors.deepPurple,
            ),
            title: Container(
              width: 250,
              child: TextField(
                style: TextStyle(color: Colors.deepPurpleAccent),
                controller: _decsController,
                decoration: InputDecoration(
                  hintText: 'Description',
                  hintStyle: TextStyle(color: Colors.deepPurpleAccent),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(
            color: Colors.grey,
          ),
          ListTile(
            leading: Icon(
              Icons.perm_device_info,
              color: Colors.deepPurple,
            ),
            title: Container(
              width: 250,
              child: TextField(
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.deepPurpleAccent),
                controller: _priceController,
                decoration: InputDecoration(
                  hintText: 'Price',
                  hintStyle: TextStyle(color: Colors.deepPurpleAccent),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  void cleraFormInfo() {
    setState(() {
      imageFile = null;
      _priceController.clear();
      _decsController.clear();
      _titleController.clear();
      _infoController.clear();
    });
  }

  uploadImageAndSaveItemInfo() async {
    setState(() {
      uploading = true;
    });
    String imageDownloadUrl = await uploadItemImage(imageFile);

    svaeItemInfo(imageDownloadUrl);
  }

  Future<String> uploadItemImage(mimageFile) async {
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child("Items");
    StorageUploadTask storageUploadTask =
        storageReference.child("product $productId.jpg").putFile(mimageFile);
    StorageTaskSnapshot storageTaskSnapshot =
        await storageUploadTask.onComplete;
    String dowloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return dowloadUrl;
  }

  void svaeItemInfo(String imageDownloadUrl) {
    final itemRef = Firestore.instance.collection('items');
    itemRef.document(productId).setData({
      "shortInfo": _infoController.text.trim(),
      "title": _titleController.text.trim(),
      "price": int.parse(_priceController.text),
      "longDescription": _decsController.text.trim(),
      "publishedDate": DateTime.now(),
      "status": "available",
      "thumbnailUrl": imageDownloadUrl,
    });
    setState(() {
      imageFile = null;
      uploading = false;
      productId = DateTime.now().millisecondsSinceEpoch.toString();
      _titleController.clear();
      _decsController.clear();
      _priceController.clear();
      _infoController.clear();
    });
  }
}
