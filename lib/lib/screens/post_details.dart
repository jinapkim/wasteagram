import 'package:flutter/material.dart';

class PostDetails extends StatelessWidget {

  final post;
  const PostDetails({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wasteagram')
      ),
      body: Column(
      children: [
        const SizedBox(height: 50),
        Text(post['date'], style: const TextStyle(fontSize: 30)),
        Padding(
          padding: EdgeInsets.all(45),
          child: Image.network(post['image']),
        ),
        Text('${post['quantity']} items', style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 50),
        Text('${post['latitude']} / ${post['longitude']}', style: const TextStyle(fontSize: 20))
      ]
      )
    );
  }
  
}