
class Post {
  late String date;
  late String image; 
  late String quantity;
  late String latitude;
  late String longitude;
  late String timeAdded;

  Map<String, dynamic> getPostData() {
    return {
      'date': this.date, 
      'image': this.image, 
      'quantity': this.quantity, 
      'latitude': this.latitude, 
      'longitude': this.longitude,
      'timeAdded': this.timeAdded
    };
  }

}

