import 'package:firebasenewapp/edit_text_AU.dart';
import 'package:flutter/material.dart';
import 'package:firebasenewapp/results.dart';
import 'dart:io';
import 'dart:ui';
import 'dart:async';

const String labelDNI = "DNI: ";
const String labelVerNumber = "Verification number: ";
const String labelName = "Name: ";
const String labelFLastName = "Father's last name: ";
const String labelMLastName = "Mother's last name: ";
const String labelBirthday = "Birthday: ";
const String labelUbigeo = "Ubigeo: ";
const String labelGender = "Gender: ";
const String labelStatus = "Status: ";


class EditTextDNI extends StatefulWidget{
  //final String imagePath;
  final String editable; 
  final String title;
  final String facePath;
  EditTextDNI(this.editable, this.title, this.facePath);

  @override
  _EditTextDNI createState() => new _EditTextDNI(editable, title, facePath);
}

class _EditTextDNI extends State<EditTextDNI>{
  _EditTextDNI(this._text, this.title, this._facePath);
  //final String path;
  final String _text;
  final String title;
  final String _facePath;
  

  String fullText = "";

  TextEditingController _controllerDNI = new TextEditingController();
  TextEditingController _controllerVerNumber = new TextEditingController();
  TextEditingController _controllerName = new TextEditingController();
  TextEditingController _controllerFLastName = new TextEditingController();
  TextEditingController _controllerMLastName = new TextEditingController();
  TextEditingController _controllerBirthday = new TextEditingController();
  TextEditingController _controllerUbigeo = new TextEditingController();
  TextEditingController _controllerGender = new TextEditingController();
  TextEditingController _controllerStatus = new TextEditingController();

  void _setFullText() {
    setState(() {
                  fullText =  labelDNI + _controllerDNI.text + "\n" +
                              labelVerNumber + _controllerVerNumber.text + "\n" +
                              labelName + _controllerName.text + "\n" +
                              labelFLastName + _controllerFLastName.text + "\n" +
                              labelMLastName + _controllerMLastName.text + "\n" +
                              labelBirthday + _controllerBirthday.text + "\n" +
                              labelUbigeo + _controllerUbigeo.text + "\n" +
                              labelGender + _controllerGender.text + "\n" +
                              labelStatus + _controllerStatus.text + "\n";
                              
                });     
        
  }

  void _initialize() async {

    if(_text.indexOf(labelDNI) != -1)
      _controllerDNI.text = _text.substring(_text.indexOf(labelDNI)+5,_text.indexOf(labelDNI)+_text.substring(_text.indexOf(labelDNI)).indexOf("\n"));
    else _controllerDNI.text="null";

    if(_text.indexOf(labelVerNumber) != -1)
      _controllerVerNumber.text = _text.substring(_text.indexOf(labelVerNumber)+21,_text.indexOf(labelVerNumber)+_text.substring(_text.indexOf(labelVerNumber)).indexOf("\n"));
    else _controllerVerNumber.text="null";

    if(_text.indexOf(labelName) != -1)
      _controllerName.text = _text.substring(_text.indexOf(labelName)+6,_text.indexOf(labelName)+_text.substring(_text.indexOf(labelName)).indexOf("\n"));
    else _controllerName.text="null";

    if(_text.indexOf(labelFLastName) != -1)
    _controllerFLastName.text = _text.substring(_text.indexOf(labelFLastName)+20,_text.indexOf(labelFLastName)+_text.substring(_text.indexOf(labelFLastName)).indexOf("\n"));
    else _controllerFLastName.text="null";
    
    if(_text.indexOf(labelMLastName) != -1)
    _controllerMLastName.text = _text.substring(_text.indexOf(labelMLastName)+20,_text.indexOf(labelMLastName)+_text.substring(_text.indexOf(labelMLastName)).indexOf("\n"));
    else _controllerMLastName.text="null";

    if(_text.indexOf(labelBirthday) != -1)
    _controllerBirthday.text = _text.substring(_text.indexOf(labelBirthday)+10,_text.indexOf(labelBirthday)+_text.substring(_text.indexOf(labelBirthday)).indexOf("\n"));
    else _controllerBirthday.text="null";

    if(_text.indexOf(labelUbigeo) != -1)
      _controllerUbigeo.text = _text.substring(_text.indexOf(labelUbigeo)+8,_text.indexOf(labelUbigeo)+_text.substring(_text.indexOf(labelUbigeo)).indexOf("\n"));
    else _controllerUbigeo.text="null";

    if(_text.indexOf(labelGender) != -1)
      _controllerGender.text = _text.substring(_text.indexOf(labelGender)+8,_text.indexOf(labelGender)+_text.substring(_text.indexOf(labelGender)).indexOf("\n"));
    else _controllerGender.text="null";

    if(_text.indexOf(labelStatus) != -1)
      _controllerStatus.text = _text.substring(_text.indexOf(labelStatus)+8,_text.indexOf(labelStatus)+_text.substring(_text.indexOf(labelStatus)).indexOf("\n"));
    else _controllerStatus.text="null";

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
      body: SingleChildScrollView(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            child: TextField(
              controller: _controllerDNI,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(0,0,0,0),
                labelText: labelDNI,
              ),
            ),
            padding: EdgeInsets.all(8),
          ),
          Container(
            child: TextField(
              controller: _controllerVerNumber,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(0,0,0,0),
                labelText: labelVerNumber,
              ),
            ),
            padding: EdgeInsets.all(8),
          ),
          Container(
            child: TextField(
              controller: _controllerName,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(0,0,0,0),
                labelText: labelName,
              ),
            ),
            padding: EdgeInsets.all(8),
          ),
          Container(
            child: TextField(
              controller: _controllerFLastName,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(0,0,0,0),
                labelText: labelFLastName,
              ),
            ),
            padding: EdgeInsets.all(8),
          ),
          Container(
            child: TextField(
              controller: _controllerMLastName,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(0,0,0,0),
                labelText: labelMLastName,
              ),
            ),
            padding: EdgeInsets.all(8),
          ),
          Container(
            child: TextField(
              controller: _controllerBirthday,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(0,0,0,0),
                labelText: labelBirthday,
              ),
            ),
            padding: EdgeInsets.all(8),
          ),
          Container(
            child: TextField(
              controller: _controllerUbigeo,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(0,0,0,0),
                labelText: labelUbigeo,
              ),
            ),
            padding: EdgeInsets.all(8),
          ),
          Container(
            child: TextField(
              controller: _controllerGender,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(0,0,0,0),
                labelText: labelGender,
              ),
            ),
            padding: EdgeInsets.all(8),
          ),
          Container(
            child: TextField(
              controller: _controllerStatus,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(0,0,0,0),
                labelText: labelStatus,
              ),
            ),
            padding: EdgeInsets.all(8),
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
      )
      
    );
  }

}