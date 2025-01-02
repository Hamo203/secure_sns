class Diary {
  DateTime createdDate;
  String place;
  String emotion;
  String emotionreason;

  String diaryAccount;
  String description;
  String imagePath;


  bool buttonPush;
  int favoriteCount;

  Diary(
      {
        this.diaryAccount = '',
        required this.createdDate,
        this.place='',
        this.description = '',
        this.emotion ='',
        this.emotionreason='',

        this.buttonPush=false,
        this.favoriteCount=0,
        this.imagePath =' ',

      });
}