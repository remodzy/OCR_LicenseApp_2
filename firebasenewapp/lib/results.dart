import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui';
import 'package:firebasenewapp/main.dart';
import 'dart:async';

class Result extends StatefulWidget{
  final String resultText; 
  final String title;
  final String faceImage;
  final String signImage;

  Result(this.resultText, this.faceImage, this.signImage, this.title);

  @override
  _Result createState() => new _Result(resultText, signImage, faceImage, title);
}

class _Result extends State<Result>{
  _Result(this._text, this._faceImage, this._signImage, this.title);

  final String _text;
  final String _faceImage;
  final String _signImage;
  final String title;
  
  @override
  void initState() {
    print(_faceImage);
    super.initState();
  }  

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                      alignment: Alignment.topCenter,
                      width: double.maxFinite,
                      child: Image.file(
                            File(_faceImage),
                          ),
                    ),
            Container(
                      alignment: Alignment.topCenter,
                      width: 180,
                      padding: EdgeInsets.all(8),
                      child: _signImage == "null" ? Text('No signature detected!') :Image.file(
                            File(_signImage),
                          ),
                    ),
            Container(
              child: Text(_text),
              padding: EdgeInsets.all(32),
            ),
            Container(
              width: double.infinity,
              child: FlatButton(
                child: Text("Make another detection"),
                color: Colors.red,
                onPressed: (){
                  Navigator.push(context,MaterialPageRoute(builder: (context) => MyApp(),),); 
                },
                ),
            ),          
          ],
        ),
      )
    );
  }

}