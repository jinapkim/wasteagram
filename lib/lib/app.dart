import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../screens/new_post.dart';
import 'widgets/post_list.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wasteagram',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const MyHomePage(title: 'Wasteagram'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final ImagePicker picker = ImagePicker();
  File? image;
  num wasteCount = 0;

  getImage(ImageSource source) async {

    final navigator = Navigator.of(context);
    final image = await picker.pickImage(source: source);
    if (image == null) return;

    navigator.push(MaterialPageRoute(
      builder: (context) => NewPost(imagePath: image.path)
    ));
  }

  updateCount(num count) {

      setState(() {
        wasteCount = count;
      });
    
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        //title: Text(widget.title),
        title: Row(
          children: [
            const Expanded(child: const Text('Wasteagram')),
            Text('Total items: $wasteCount')
        ]),
      ),
      body: PostList(updateCount: updateCount),
      floatingActionButton: Semantics(
        button: true,
        label: 'Select or take a photo',
        child: FloatingActionButton(
            onPressed: (() => showModalBottomSheet(
              context: context, 
              builder: (context) => Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.camera_alt_rounded),
                    title: const Text('Camera'),
                    onTap: (()  {
                      Navigator.pop(context);
                      getImage(ImageSource.camera);
                    })
                  ),
                  ListTile(
                    leading: const Icon(Icons.image_outlined),
                    title: const Text('Gallery'),
                    onTap: (()  {
                      Navigator.pop(context);
                      getImage(ImageSource.gallery);
                    })
                  )
                ],
              )
            )
            ),
            tooltip: 'Increment',
            child: const Icon(Icons.camera_alt_rounded)
        )
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

}
