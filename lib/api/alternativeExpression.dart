import 'package:flutter/material.dart';

class Alternativeexpression extends StatefulWidget {
  final String originalMessage;

  Alternativeexpression({required this.originalMessage});


  @override
  State<Alternativeexpression> createState() => _AlternativeexpressionState();
}

class _AlternativeexpressionState extends State<Alternativeexpression> {
  //言い換え表現用配列
  List<String> alternativeExpressions = [];

  void initState(){
    super.initState();
    fetchAlternativeExpressions();
  }
  Future<void> fetchAlternativeExpressions() async{
    setState(() {
      alternativeExpressions= [
        "test1","test2","test3"
      ];
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: alternativeExpressions.length,
          itemBuilder: (context,index){
          return ListTile(
            title: Text(alternativeExpressions[index]),
            onTap:(){
              Navigator.of(context).pop(alternativeExpressions[index]);
            }
          );
          }),
    );
  }
}
