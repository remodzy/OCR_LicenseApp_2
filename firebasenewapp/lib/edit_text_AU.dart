import 'package:flutter/material.dart';
import 'package:firebasenewapp/results.dart';
import 'dart:io';
import 'dart:ui';
import 'dart:async';

const String labelName = "Name: ";
const String labelLastName = "Last name: ";
const String labelNumber = "License number: ";
const String labelDOB = "DOB: ";

class EditTextAU extends StatefulWidget{

  final String editable; 
  final String title;
  final String facePath;
  EditTextAU(this.editable, this.title, this.facePath);

  @override
  _EditTextAU createState() => new _EditTextAU(editable, title, facePath);
}

class _EditTextAU extends State<EditTextAU>{
  _EditTextAU(this._text, this.title, this._facePath);
  final String _text;
  final String title;
  final String _facePath;
  

  String fullText = "";

  TextEditingController _controllerName = new TextEditingController();
  TextEditingController _controllerLastName = new TextEditingController();
  TextEditingController _controllerNumber = new TextEditingController();
  TextEditingController _controllerDOB = new TextEditingController();

  void _setFullText() {
    setState(() {
                  fullText = labelName + _controllerName.text + "\n" +
                              labelLastName + _controllerLastName.text + "\n" +
                              labelNumber + _controllerNumber.text + "\n" +
                              labelDOB + _controllerDOB.text + "\n";
                });     
        
  }

  void _initialize() async {

    if(_text.indexOf(labelName) != -1)
      _controllerName.text = _text.substring(_text.indexOf(labelName)+6,_text.indexOf(labelName)+_text.substring(_text.indexOf(labelName)).indexOf("\n"));
    else _controllerName.text="null";

    if(_text.indexOf(labelLastName) != -1)
    _controllerLastName.text = _text.substring(_text.indexOf(labelLastName)+11,_text.indexOf(labelLastName)+_text.substring(_text.indexOf(labelLastName)).indexOf("\n"));
    else _controllerLastName.text="null";
    
    if(_text.indexOf(labelNumber) != -1)
    _controllerNumber.text = _text.substring(_text.indexOf(labelNumber)+16,_text.indexOf(labelNumber)+_text.substring(_text.indexOf(labelNumber)).indexOf("\n"));
    else _controllerNumber.text="null";

    if(_text.indexOf(labelDOB) != -1)
    _controllerDOB.text = _text.substring(_text.indexOf(labelDOB)+5,_text.indexOf(labelDOB)+_text.substring(_text.indexOf(labelDOB)).indexOf("\n"));
    else _controllerDOB.text="null";

  }  


  @override
  void initState() {
    _initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            child: TextField(
              controller: _controllerName,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(0,0,0,0),
                labelText: 'Name:',
              ),
            ),
            padding: EdgeInsets.all(32),
          ),
          Container(
            child: TextField(
              controller: _controllerLastName,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(0,0,0,0),
                labelText: 'Last Name:',
              ),
            ),
            padding: EdgeInsets.all(32),
          ),
          Container(
            child: TextField(
              controller: _controllerNumber,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(0,0,0,0),
                labelText: 'License Number:',
              ),
            ),
            padding: EdgeInsets.all(32),
          ),
          Container(
            child: TextField(
              controller: _controllerDOB,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(0,0,0,0),
                labelText: 'DOB:',
              ),
            ),
            padding: EdgeInsets.all(32),
          ),
          Container(
            width: double.infinity,
            child: FlatButton(
              child: Text("DONE"),
              color: Colors.red,
              onPressed: (){
                _setFullText();
                Navigator.push(context,MaterialPageRoute(builder: (context) => Result(fullText, _facePath,"Result Screen"),),); 
              },
              ),
          ),
        ],
      ),
    );
  }

}