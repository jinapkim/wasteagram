import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../screens/post_details.dart';

class PostList extends StatelessWidget {
  
  late Function updateCount;

  PostList({Key? key, required this.updateCount}) : super(key: key);
  late num wasteCount;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
        .collection('Posts')
        .orderBy('timeAdded', descending: true).snapshots(),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.data.docs.length > 0) {

          // Get total number of waste items
          wasteCount = 0;
          snapshot.data.docs.forEach((item){
            wasteCount = wasteCount + int.parse(item['quantity']);
          });

          // Pass data to app.dart
          SchedulerBinding.instance.addPostFrameCallback((_) { 
            updateCount(wasteCount);
          });

          return ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: snapshot.data.docs.length,
            itemBuilder: ((BuildContext context, int index) {
              var post = snapshot.data.docs[index];
              return Card(
                child: ListTile(
                  leading: Image.network(post['image']),
                  title: Text(post['date']),
                  trailing: Text(post['quantity']),
                  onTap: (() {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => PostDetails(post: post))
                    );
                  })
                )
              );

            }),
          );
        } else {
          wasteCount = 0;
          SchedulerBinding.instance.addPostFrameCallback((_) { 
            updateCount(wasteCount);
          });
          return const Center(child: CircularProgressIndicator());
        }
      });
  }
}