import 'package:flutter/material.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:firebasenewapp/edit_text_AU.dart';
import 'package:firebasenewapp/edit_text_DNI.dart';
import 'package:image/image.dart' as img;
import 'package:firebasenewapp/results.dart';
import 'dart:io';
import 'dart:ui';
import 'dart:async';

class DetailScreen extends StatefulWidget {
  final String imagePath;
  final String imageResizedPath;
  final String title;
  final int select;
  final img.Image imgImage;

  DetailScreen(this.imagePath, this.imageResizedPath,this.imgImage,this.title, this.select);

  @override
  _DetailScreenState createState() => new _DetailScreenState(imagePath, imageResizedPath, imgImage, title, select);
}

class _DetailScreenState extends State<DetailScreen> {
  _DetailScreenState(this.path, this.resizedPath,this.imgImage, this.title, this.select);

  final String path;
  final String resizedPath;
  String imagePath;
  final String title;
  final int select;
  final imgImage;

  Size _imageSize;
  List<TextElement> _elements = [];
  String recognizedText = "Loading ...";  
  Rect boundingBox = Rect.fromPoints(Offset(0,0), Offset(0,0));

  img.Image copyCrop(img.Image src, int x, int y, int w, int h) {
  // Make sure crop rectangle is within the range of the src image.
  x = x.clamp(0, src.width - 1.0).toInt();
  y = y.clamp(0, src.height - 1.0).toInt();
  if (x + w > src.width) {
    w = src.width - x;
  }
  if (y + h > src.height) {
    h = src.height - y;
  }
  
  var dst = img.Image(w, h, channels: src.channels, exif: src.exif, iccp: src.iccProfile);

  for (var yi = 0, sy = y; yi < h; ++yi, ++sy) {
    for (var xi = 0, sx = x; xi < w; ++xi, ++sx) {
      dst.setPixel(xi, yi, src.getPixel(sx, sy));
    }
  }

  return dst;
}

  void _faceDetection() async{
    int startTime = new DateTime.now().millisecondsSinceEpoch;    
    
    img.Image imageResized = img.copyResize(imgImage, width: 500, interpolation: img.Interpolation.cubic);

    File(resizedPath).writeAsBytesSync(img.encodePng(imageResized));
    final resizedImageFile = File(resizedPath);   

    FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(resizedImageFile);

    final FaceDetector faceDetector = 
      FirebaseVision.instance.faceDetector();
    
    
    final List<Face> faces = await faceDetector.processImage(visionImage);    

    if(faces.length>1){
      if(faces[0].boundingBox.width>faces[1].boundingBox.width) boundingBox = faces[0].boundingBox;
      else boundingBox = faces[1].boundingBox;
    }
    else boundingBox = faces[0].boundingBox;
    print("BoundingBox:");
    print(boundingBox);

    imageResized = copyCrop(imageResized,(boundingBox.topLeft.dx-0.15*boundingBox.width).toInt(),(boundingBox.topLeft.dy-0.2*boundingBox.height).toInt(),(1.3*boundingBox.width).toInt(),(1.4*boundingBox.height).toInt());
    imageResized = img.copyResize(imageResized, width: 150, interpolation: img.Interpolation.cubic);  
    
    File(resizedPath).writeAsBytesSync(img.encodePng(imageResized));  
    
    int endTime = new DateTime.now().millisecondsSinceEpoch;
    print("Face Detection took ${endTime - startTime}");
  }


  void _initializeVision() async {
    int startTime = new DateTime.now().millisecondsSinceEpoch;
    final File imageFile = File(path);

    if (imageFile != null) {
      await _getImageSize(imageFile);
    }

    _faceDetection();

    FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(imageFile);    

    final TextRecognizer textRecognizer =
        FirebaseVision.instance.textRecognizer();

    final VisionText visionText =
        await textRecognizer.processImage(visionImage);

    String pattern1,pattern2;    
    String match1,match2,match3,match4,match5,match6;
    
    RegExp regEx1, regEx2;
    RegExp matchEx1, matchEx2, matchEx3, matchEx4, matchEx5, matchEx6;
    String textCapture;
    int linecount;

    if(select == 0){
      pattern1 = r"\d{3} \d{3} \d{3}";
      pattern2 = r"[A-Z]";   
      match1 = r"(?:o|D|O|0)river";
      match2 = r"(?:o|D|O|0)(?:o|D|O|0)(?:B|6|8|e|E)";
      match3 = r"DOB";
      
          //r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";
      regEx1 = RegExp(pattern1);
      regEx2 = RegExp(pattern2);
      matchEx1 = RegExp(match1);
      matchEx2 = RegExp(match2);
      matchEx3 = RegExp(match3);

      textCapture = "";
      linecount = 0;      
      double sumDY = 0;
      double minDX = _imageSize.width;              
      int index=0;

      for (TextBlock block in visionText.blocks) {
        print("Block");
      for (TextLine line in block.lines) {
        print(line.text); 
        if(matchEx1.hasMatch(line.text)){
          print("Match Driver: ");
          for(TextElement element in line.elements){          
          sumDY+= element.boundingBox.bottomRight.dy;
          if(element.boundingBox.topLeft.dx<minDX) minDX = element.boundingBox.topLeft.dx;
        }
        sumDY = sumDY/line.elements.length;
        }
        
        if(sumDY!=0){   
          print("Mínimo:");
          print(minDX);       
          for(TextElement element in line.elements){
            print(element.boundingBox.topLeft.dx);
            if((element.boundingBox.topLeft.dy > sumDY + 20) && (element.boundingBox.topLeft.dy < sumDY + 235) && (regEx2.hasMatch(line.text)) && (element.boundingBox.topLeft.dx < minDX + 100) && (element.boundingBox.topLeft.dy > minDX - 100)){
              _elements.add(element);
              if(index==0){
                textCapture+="Last name: "+element.text + '\n';
                index++;
              }
              else textCapture+="Name: "+element.text + '\n';              
            }            
          }
        }
        
        if(regEx1.hasMatch(line.text)){
          print("Match Number: ");
          for(int i = 0; i<regEx1.allMatches(line.text).length; i++){
              textCapture += "License number: "+regEx1.allMatches(line.text).map((e) => e.group(0)).elementAt(i).toString() + '\n';
          }
          
          for (TextElement element in line.elements) {
            _elements.add(element);  

          }
        }

        if(matchEx2.hasMatch(line.text)){
          print("Match Date: ");
          print(line.text.substring(line.text.indexOf(matchEx2)+4,line.text.length));
          
          for (TextElement element in line.elements) {
            _elements.add(element);            
          }
          
          textCapture +="DOB: "+line.text.substring(line.text.indexOf(matchEx2)+4,line.text.length) + '\n';
          
        }        
        
        linecount++;
      }
      linecount = 0;
    }
    }
    if(select == 1){
      
    pattern1 = r"\d{1,2} \d{1,2} \d{4}";
    pattern2 = r"(?<!\d)\d{6}(?!\d)";    
    match1 = r"(?:o|D|O|0)NI";
    match2 = r"Primer";
    match3 = r"Segundo";
    match4 = r"Nom";
    match5 = r"Nac";
    match6 = r"(?:^|(?<=[^a-zA-Z0-9< ]))[a-zA-Z](?=[^a-zA-Z0-9< ]|$)";
    
        //r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";
    regEx1 = RegExp(pattern1);
    regEx2 = RegExp(pattern2);
    matchEx1 = RegExp(match1);
    matchEx2 = RegExp(match2);
    matchEx3 = RegExp(match3);
    matchEx4 = RegExp(match4);
    matchEx5 = RegExp(match5);
    matchEx6 = RegExp(match6);
    textCapture = "";

    linecount = 0;
    for (TextBlock block in visionText.blocks) {      
      for (TextLine line in block.lines) {
        print(line.text);
        if (matchEx1.hasMatch(line.text)) {
          textCapture += "DNI: "+ line.text.substring(line.text.indexOf(matchEx1)+4,line.text.indexOf(matchEx1)+12) + '\n';
          try{ 
            textCapture += "Verification number: " + line.text.substring(line.text.indexOf("-")+1,line.text.indexOf("-")+2) + '\n';
          }
          catch(e){
            textCapture += "null\n";
          }
          
          for (TextElement element in line.elements) {

            _elements.add(element);
          }
        }

        if (matchEx2.hasMatch(line.text)) {
          for (TextElement element in block.lines[linecount+1].elements) {
            _elements.add(element);
            textCapture+="Father's last name: "+element.text + '\n';
          }
        }

        if (matchEx3.hasMatch(line.text)) {
          for (TextElement element in block.lines[linecount+1].elements) {
            _elements.add(element);
            textCapture+="Mother's last name: "+element.text + '\n';
          }
        }

        if (matchEx4.hasMatch(line.text)) {
          for (TextElement element in block.lines[linecount+1].elements) {
            _elements.add(element);
            textCapture+="Name: "+element.text + '\n';
          }
        }

        if (matchEx5.hasMatch(line.text)) {
          try{
            for(int i = 0; i<regEx1.allMatches(block.lines[linecount+1].text).length; i++){
              textCapture += "Birthday: " + regEx1.allMatches(block.lines[linecount+1].text).map((e) => e.group(0)).elementAt(i).toString() + '\n';
          }

          for (TextElement element in block.lines[linecount+1].elements) {
            _elements.add(element);
          }
          }
          catch(e){
            textCapture += "Birthday: null\n";
          }
          
        }

        if(regEx2.hasMatch(line.text)){
          for (TextElement element in line.elements) {
            _elements.add(element);
          }          
            textCapture+= "Ubigeo: " + regEx2.allMatches(line.text).map((e) => e.group(0)).elementAt(0).toString() + '\n';
        }

        
        if (matchEx6.hasMatch(line.text)) {
          if(line.text.length==1){
            for (TextElement element in line.elements) {

            switch(element.text) { 
              case "M": { 
                  _elements.add(element);
                  textCapture+='Gender: Male\n';
              } 
              break; 
              
              case "F": { 
                  _elements.add(element);
                  textCapture+='Gender: Female\n'; 
              } 
              break; 

              case "S": { 
                  _elements.add(element);
                  textCapture+='Status: Single\n';
              } 
              break; 
              
              case "C": { 
                  _elements.add(element);
                  textCapture+='Status: Married\n'; 
              } 
              break; 

              case "V": { 
                  _elements.add(element);
                  textCapture+='Status: Widow(er)\n';
              } 
              break; 
              
              case "D": { 
                  _elements.add(element);
                  textCapture+='Status: divorced\n'; 
              } 
              break; 
            } 
          }
          }          
        }     
        linecount++;
      }
      linecount = 0;
    }
    }

    
      setState(() {
        recognizedText = textCapture;
      });
    
    int endTime = new DateTime.now().millisecondsSinceEpoch;
    print("Detection took ${endTime - startTime}");
  }

  Future<void> _getImageSize(File imageFile) async {
    final Completer<Size> completer = Completer<Size>();

    final Image image = Image.file(imageFile);
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      }),
    );

    final Size imageSize = await completer.future;
    setState(() {
      _imageSize = imageSize;
    });
  }

  @override
  void initState() {    
    _initializeVision();
    super.initState();    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: _imageSize != null
          ? Stack(
              children: <Widget>[
                Center(                  
                  child: Container(
                    alignment: Alignment.topCenter,
                    width: double.maxFinite,
                    color: Colors.black,
                    child: CustomPaint(
                      foregroundPainter:
                          TextDetectorPainter(_imageSize, _elements, boundingBox),
                      child: AspectRatio(
                        aspectRatio: _imageSize.aspectRatio,
                        child: Image.file(
                          File(path),
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Card(
                    elevation: 8,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              "Identified texts",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            height: 200,
                            child: SingleChildScrollView(
                              child: Text(
                                recognizedText,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                            FlatButton(
                            child: Text("Edit"),
                            color: Colors.red,
                            onPressed: (){
                              if(select==0){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditTextAU(recognizedText,"Edit Text Screen", resizedPath),
                                  ),
                                );
                              }   
                              if(select==1){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditTextDNI(recognizedText,"Edit Text Screen", resizedPath),
                                  ),
                                );
                              }                            
                            },
                            ),
                            FlatButton(
                            child: Text("OK"),
                            color: Colors.red,
                            onPressed: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Result(recognizedText, resizedPath,"Result Screen"),
                                  ),
                                );                               
                            },
                            ),
                          ],
                          ),                          
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Container(
              color: Colors.black,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
    );
  }
}

class TextDetectorPainter extends CustomPainter {
  TextDetectorPainter(this.absoluteImageSize, this.elements, this.boundingBox);

  final Size absoluteImageSize;
  final List<TextElement> elements;
  final Rect boundingBox;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    Rect scaleRect(TextContainer container) {
      return Rect.fromLTRB(
        container.boundingBox.left * scaleX,
        container.boundingBox.top * scaleY,
        container.boundingBox.right * scaleX,
        container.boundingBox.bottom * scaleY,
      );
    }

    Rect faceRect(Rect bounding) {
      return Rect.fromLTRB(
        bounding.left*scaleX*absoluteImageSize.width/500,
        bounding.top*scaleY*absoluteImageSize.width/500,
        bounding.right*scaleX*absoluteImageSize.width/500,
        bounding.bottom*scaleY*absoluteImageSize.width/500,
      );
    }

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.red
      ..strokeWidth = 2.0;

    for (TextElement element in elements) {
      canvas.drawRect(scaleRect(element), paint);
    }
    canvas.drawRect(faceRect(boundingBox), paint);
  }

  @override
  bool shouldRepaint(TextDetectorPainter oldDelegate) {
    return true;
  }
}