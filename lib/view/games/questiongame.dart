import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:secure_sns/model/Question.dart';

//main でQuestionWidget()よびだし

class QuestionWidget extends StatefulWidget{
  const QuestionWidget({
    Key? key,
    }):super(key: key);
  @override
  State<StatefulWidget> createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget>{
  int _questionNumber=1;
  int _score=0;
  bool _isLocked = false;
  late PageController _controller ; //ページ遷移用のコントローラ

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
  }

  //問題表示用ページ
  @override
  Widget build(BuildContext context) {
   return Scaffold(
     body: Column(
       children: [
         const SizedBox(height:10),
         Text('Question $_questionNumber/${questions.length}'),
         const Divider(thickness: 1,color: Colors.grey,),
         Expanded(child: PageView.builder(
           itemCount: questions.length,
           controller: _controller,
           physics: const NeverScrollableScrollPhysics(),
           itemBuilder: (BuildContext context, int index) {
             final _question = questions[index];
             return buildQuestion(_question);
           },),),
         _isLocked ? buildElevatedButton() : const SizedBox.shrink(),
         const SizedBox(height: 20,),
       ],
     ),
   );
  }


  Column buildQuestion(Question question){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32,),
        //問題文表示
        Text(question.text,style: const TextStyle(fontSize: 25),),
        const SizedBox(height:32),
        //選択肢提示
        Expanded(child: OptionWidget(
          question:question,
          onClickedOption: (option){
            if(question.isLocked){
              return;
            }else{
              setState(() {
                question.isLocked=true;
                question.selectedOption=option;
              });
              _isLocked=question.isLocked;
              //正解だったらスコア++;
              if (question.selectedOption!.isCorrect){
                _score++;
              }
            }
          },
        ))

      ],
    );
  }
  //画面遷移のボタン
  ElevatedButton buildElevatedButton(){
    return ElevatedButton(
        onPressed:(){
      if(_questionNumber < questions.length) {
        _controller.nextPage(
          duration: const Duration(milliseconds: 250),
          curve:Curves.easeInExpo,
        );
        setState(() {
          _questionNumber++;
          _isLocked=false;
        });
      } else {
        //問題が全部終わったらresult Pageに遷移する
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ResultPage(score: _score)));
      }
    } ,
        child: Text(_questionNumber<questions.length ? 'Next Page': 'See the Result'));
  }
}


//選択肢表示用のWidget
class OptionWidget extends StatelessWidget{
  final Question question;
  final ValueChanged<Option> onClickedOption;
  const OptionWidget({
    Key? key,
    required this.question,
    required this.onClickedOption
  }):super(key: key);

  @override
  Widget build(BuildContext context)=> SingleChildScrollView(
    child: Column(
      //選択肢のリスト
      children: question.options.map((option) => buildOption(context, option)).toList(),
    ),
  );

  Widget buildOption(BuildContext context, Option option){
    final Color color = getColorForOption(option,question);
    return GestureDetector(
      onTap: ()=> onClickedOption(option),
      child: Container(
        height: 50,
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //選択肢の文
            Text(option.text,style: const TextStyle(fontSize: 20),),
            getIconForOption(option,question)
          ],
        ),
      ),
    );
  }

  Color getColorForOption(Option option,Question question){
    final isSelected = option ==question.selectedOption;
    if(question.isLocked){
      if(isSelected){
        //枠の色　合ってたらみどり、間違ってたら赤
        return option.isCorrect? Colors.green : Colors.red;
      }else if(option.isCorrect){
        return Colors.green;
      }
    }
    return Colors.grey.shade300;
  }

  //○×のアイコン装飾を付ける
  Widget getIconForOption(Option option,Question question){
    final isSelected =option ==question.selectedOption;
    if(question.isLocked){
      if(isSelected){
        return option.isCorrect
            ? const Icon(Icons.check_circle,color: Colors.green,)
            : const Icon(Icons.cancel,color: Colors.red,);
      }else if(option.isCorrect){
        return const Icon(Icons.check_circle,color: Colors.green,);
      }
    }
    return const SizedBox.shrink();
  }

  }
class ResultPage extends StatelessWidget{
  const ResultPage ({Key? key,required this.score}) : super (key: key);
  final int score;
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(
        child: Text('You got $score/${questions.length}'),
      )
    );
  }
}


