import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as Path;
import 'package:flutter/services.dart';
import '../app.dart';
import '../models/post.dart';


class NewPost extends StatefulWidget {

  final String imagePath;

  NewPost({Key? key, required this.imagePath}) : super(key: key);

  @override
  State<NewPost> createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {

  final _formKey = GlobalKey<FormState>();
  LocationData? locationData;
  var locationService = Location();
  final Post newPost = Post();
  final firestore = FirebaseFirestore.instance;
  final firestorage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    retrieveLocation();
  }

  void retrieveLocation() async {
    try {
      var _serviceEnabled = await locationService.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await locationService.requestService();
        if (!_serviceEnabled) {
          print('Failed to enable service. Returning.');
          return;
        }
      }

      var _permissionGranted = await locationService.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await locationService.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          print('Location service permission not granted. Returning.');
          return;
        }
      }

      locationData = await locationService.getLocation();
    } on PlatformException catch (e) {
      print('Error: ${e.toString()}, code: ${e.code}');
      locationData = null;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Wasteagram')
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              width: 250,
              height: 350,
              child: Image.file(File(widget.imagePath)),
            ),
            Form(
              key: _formKey,
              child: TextFormField(
                textAlign: TextAlign.center,
                autofocus: true, 
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Number of items'
                ),
                onSaved:(newValue) {
                  newPost.quantity = newValue!;
                },
                validator:(value) {
                  if (value!.isEmpty) {
                    return 'Please enter a number';
                  }
                  return null;
                },
              )
            ),
            SizedBox(height:40),
            Semantics(
              label: 'Tap to upload post',
              child: FloatingActionButton.extended(
                label: Text('Upload'), 
                backgroundColor: Color.fromARGB(255, 50, 88, 145),
                icon: const Icon( 
                  Icons.cloud_circle_rounded,
                  size: 40.0,
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    // Get latitude and longitude
                    final locationData = this.locationData;
                    if (locationData != null){
                      newPost.latitude = locationData.latitude.toString();
                      newPost.longitude = locationData.longitude.toString();

                    } else {
                      newPost.latitude = '-';
                      newPost.longitude = '-';
                    }
                    
                    // Get date
                    DateTime currDate = DateTime.now();
                    newPost.date = '${currDate.month.toString()} - ${currDate.day.toString()} - ${currDate.year.toString()}';
                    newPost.timeAdded = currDate.toString();
                    print(newPost.timeAdded);

                    // Save image to database
                    Reference storageReference = firestorage.ref().child(Path.basename(widget.imagePath) + DateTime.now().toString());
                    await storageReference.putFile(File(widget.imagePath));
                    
                    // Get URL for image
                    final url = await storageReference.getDownloadURL();

                    newPost.image = url;

                    // Save all data to database 
                    firestore.collection('Posts').add(
                      newPost.getPostData()
                    );

                    // Go back to home screen 
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => MyApp())
                    );
                  }
                }
              )
            )
          ]
        )
      )
    );

  }
  
}