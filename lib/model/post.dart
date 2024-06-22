class Post {
  String id;
  String discription;
  DateTime? createdTime;
  String postAccount;
  bool buttonPush;
  Post(
      {this.id = '',
        this.discription = '',
        this.postAccount = '',
        this.createdTime,
        this.buttonPush=false,
      });
}