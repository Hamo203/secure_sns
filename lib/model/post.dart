class Post {
  String postid;

  String postAccount;
  String description;
  String imagePath;
  DateTime createdTime;
  bool buttonPush;
  int favoriteCount;
  int retweetCount;
  Post(
      {this.postid = '',
        this.description = '',
        this.postAccount = '',
        required this.createdTime,
        this.buttonPush=false,
        this.favoriteCount=0,
        this.retweetCount=0,
        this.imagePath =' '
      });
}