class Account{
  String userid;

  String username;
  String name;
  String? bio;
  DateTime? createdDate;
  DateTime? birthday;
  String profilePhotoUrl;
  List? followers;
  List? retweets;
  Account({this.username='',this.name='',this.bio,this.userid='', this.createdDate,this.birthday,this.profilePhotoUrl="",this.followers,this.retweets} );

}