import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/Config/config.dart';
import 'package:ecommerceapp/DialogBox/errorDialog.dart';
import 'package:ecommerceapp/DialogBox/loadingDialog.dart';
import 'package:ecommerceapp/Store/storehome.dart';
import 'package:ecommerceapp/Widgets/customTextField.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String userImageUrl = '';
  File _imageFile;
  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    double _screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              height: 8,
            ),
            InkWell(
              onTap: _selectAndPickImage,
              child: CircleAvatar(
                radius: _screenWidth * 0.15,
                backgroundImage:
                    _imageFile == null ? null : FileImage(_imageFile),
                child: _imageFile == null
                    ? Icon(
                        Icons.add_a_photo,
                        size: _screenWidth * 0.15,
                        color: Colors.grey,
                      )
                    : null,
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    hintText: 'Name',
                    controller: _nameController,
                    data: Icons.person,
                    isObsecure: false,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  CustomTextField(
                    hintText: 'Email',
                    controller: _emailController,
                    data: Icons.email,
                    isObsecure: false,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  CustomTextField(
                    hintText: 'Password',
                    controller: _passwordController,
                    data: Icons.lock,
                    isObsecure: true,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  CustomTextField(
                    hintText: 'Confirm password',
                    controller: _confirmPasswordController,
                    data: Icons.lock,
                    isObsecure: true,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                ],
              ),
            ),
            RaisedButton(
              onPressed: () {
                uploadAndSaveImage();
              },
              color: Colors.black,
              child: Text(
                'Register',
                style: TextStyle(color: Colors.white),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            SizedBox(
              height: 15.0,
            ),
            Container(
              height: 4.0,
              width: _screenWidth * 0.8,
              color: Colors.black26,
            ),
            SizedBox(
              height: 15.0,
            )
          ],
        ),
      ),
    );
  }

  Future<void> _selectAndPickImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = image;
    });
  }

  Future<void> uploadAndSaveImage() async {
    if (_imageFile == null) {
      showDialog(
          context: context,
          builder: (c) {
            return ErrorAlertDialog(
              message: 'Plesae select an image',
            );
          });
    } else {
      _passwordController.text == _confirmPasswordController.text
          ? _emailController.text.isNotEmpty &&
                  _passwordController.text.isNotEmpty &&
                  _confirmPasswordController.text.isNotEmpty &&
                  _nameController.text.isNotEmpty
              ? uploadToStorage()
              : displayDialog('Please fill up the registration complete form..')
          : displayDialog("Password do not match.");
    }
  }

  displayDialog(String msg) {
    showDialog(
        context: context,
        builder: (c) {
          return ErrorAlertDialog(
            message: msg,
          );
        });
  }

  uploadToStorage() async {
    showDialog(
        context: context,
        builder: (c) {
          return LoadingAlertDialog(
            message: 'Registering, Please wait.....',
          );
        });
    String imageFileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child(imageFileName);
    StorageUploadTask storageUploadTask = storageReference.putFile(_imageFile);
    StorageTaskSnapshot storageTaskSnapshot =
        await storageUploadTask.onComplete;
    await storageTaskSnapshot.ref.getDownloadURL().then((value) {
      userImageUrl = value;
      _registerUser();
    });
  }

  void _registerUser() async {
    FirebaseUser firebaseUser;
    await _auth
        .createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    )
        .then((value) {
      firebaseUser = value.user;
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c) {
            return ErrorAlertDialog(
              message: error.message.toString(),
            );
          });
    });

    if (firebaseUser != null) {
      saveUserToFirestore(firebaseUser).then((value) {
        Navigator.pop(context);
        Route route = MaterialPageRoute(builder: (c) => StoreHome());
        Navigator.pushReplacement(context, route);
      });
    }
  }

  Future saveUserToFirestore(FirebaseUser firebaseUser) async {
    Firestore.instance.collection('users').document(firebaseUser.uid).setData({
      "uid": firebaseUser.uid,
      "email": firebaseUser.email,
      "name": _nameController.text.trim(),
      "url": userImageUrl,
      EcommerceApp.userCartList: ["garbageValue"]
    });
    await EcommerceApp.sharedPreferences.setString('uid', firebaseUser.uid);
    await EcommerceApp.sharedPreferences
        .setString(EcommerceApp.userEmail, firebaseUser.email);
    await EcommerceApp.sharedPreferences
        .setString(EcommerceApp.userName, _nameController.text.trim());
    await EcommerceApp.sharedPreferences
        .setString(EcommerceApp.userAvatarUrl, userImageUrl);
    await EcommerceApp.sharedPreferences
        .setStringList(EcommerceApp.userCartList, ['garbageValue']);
  }
}
