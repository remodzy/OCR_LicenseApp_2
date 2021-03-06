import 'package:flutter/material.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:firebasenewapp/edit_text_AU.dart';
import 'package:firebasenewapp/edit_text_DNI.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:firebasenewapp/results.dart';
import 'package:tflite/tflite.dart';
import 'dart:io';
import 'dart:ui';
import 'dart:async';

const String ssd = "SSD MobileNet";

class DetailScreen extends StatefulWidget {
  final String imagePath;
  final String imageResizedPath;
  final String signPath;
  final String title;
  final int select;
  final img.Image imgImage;

  DetailScreen(this.imagePath, this.imageResizedPath, this.signPath, this.imgImage,this.title, this.select);

  @override
  _DetailScreenState createState() => new _DetailScreenState(imagePath, imageResizedPath, signPath, imgImage, title, select);
}

class _DetailScreenState extends State<DetailScreen> {
  _DetailScreenState(this.path, this.resizedPath, this.signPath,this.imgImage, this.title, this.select);

  final String path;
  final String resizedPath;
  String signPath;
  String imagePath;
  final String title;
  final int select;
  final imgImage;

  Size _imageSize;
  List<TextElement> _elements = [];
  String recognizedText = "Loading...";  
  Rect boundingBox = Rect.fromPoints(Offset(0,0), Offset(0,0));
  Rect signBoundingBox = Rect.fromPoints(Offset(0,0), Offset(0,0));
  
  List _recognitions;

  ssdMobileNet(File image) async {
    final recognitions = await Tflite.detectObjectOnImage( 
        path: image.path, numResultsPerClass: 1, threshold: 0.2);
    setState(() {
      _recognitions = recognitions;
      //recognizedText = "";
      //recognizedText += "Signature confidence: "+recognitions[0]['confidenceInClass'].toString()+"\n";
    }); 
    print("TFLITE: "+_recognitions.toString());

    if(_recognitions.length>0){
      final int x = (_recognitions[0]['rect']['x']*_imageSize.width).toInt();
      final int y = (_recognitions[0]['rect']['y']*_imageSize.height).toInt();
      final int w = (_recognitions[0]['rect']['w']*_imageSize.width).toInt();
      final int h = (_recognitions[0]['rect']['h']*_imageSize.height).toInt();

    img.Image signImage = copyCrop(imgImage,x,y,w,h);
    
    File(signPath).writeAsBytesSync(img.encodePng(signImage));
    }
    else signPath="null";
  }

  tinyYolov2(File image) async {
    var recognitions;
    if (_imageSize.height>_imageSize.width){
      File rotatedImage = await FlutterExifRotation.rotateImage(path: image.path);

      recognitions = await Tflite.detectObjectOnImage( 
        path: rotatedImage.path, 
        model: "YOLO",      
        imageMean: 0.0,       
        imageStd: 255.0,      
        threshold: 0.1,       // defaults to 0.1
        numResultsPerClass: 2,// defaults to 5
        blockSize: 32,        // defaults to 32
        numBoxesPerBlock: 5,  // defaults to 5
        asynch: true  );
    }
    else{
      recognitions = await Tflite.detectObjectOnImage( 
        path: image.path, 
        model: "YOLO",      
        imageMean: 0.0,       
        imageStd: 255.0,      
        threshold: 0.1,       // defaults to 0.1
        numResultsPerClass: 2,// defaults to 5
        blockSize: 32,        // defaults to 32
        numBoxesPerBlock: 5,  // defaults to 5
        asynch: true  );
    }
    setState(() {
      _recognitions = recognitions;
      //recognizedText = "";
      //recognizedText += "Signature confidence: "+recognitions[0]['confidenceInClass'].toString()+"\n";
    }); 
    print("TFLITE: "+_recognitions.toString());

    if(_recognitions.length>0){
      final int x = (_recognitions[0]['rect']['x']*_imageSize.width).toInt();
      final int y = (_recognitions[0]['rect']['y']*_imageSize.height).toInt();
      final int w = (_recognitions[0]['rect']['w']*_imageSize.width).toInt();
      final int h = (_recognitions[0]['rect']['h']*_imageSize.height).toInt();
    
    if (_imageSize.height>_imageSize.width){
      img.Image signImage = copyCrop(imgImage,y,_imageSize.width.toInt()-w-x,h,w);
    
      await File(signPath).writeAsBytesSync(img.encodePng(signImage));
    } else{
      img.Image signImage = copyCrop(imgImage,x,y,w,h);
    
      await File(signPath).writeAsBytesSync(img.encodePng(signImage));
    }    
    
    signBoundingBox = Rect.fromPoints(Offset(x.toDouble(),y.toDouble()), Offset((x+w).toDouble(),(y+h).toDouble()));

    }
    else signPath="null";
  }

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

    //ssdMobileNet(imageFile);
    tinyYolov2(imageFile);
    
    _faceDetection();

    FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(imageFile);    

    final TextRecognizer textRecognizer =
        FirebaseVision.instance.textRecognizer();

    final VisionText visionText =
        await textRecognizer.processImage(visionImage);
    print(visionText.text);
    String pattern1,pattern2;    
    String match1,match2,match3,match4,match5,match6;
    
    RegExp regEx1, regEx2;
    RegExp matchEx1, matchEx2, matchEx3, matchEx4, matchEx5, matchEx6;
    String textCapture;
    int linecount;

    if(select == 0){
      pattern1 = r"\d{3} \d{3} \d{3}";
      pattern2 = r"[A-Z]";   
      match1 = r"(?:o|D|O|0|)river";
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
          print("M??nimo:");
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

    Rect nameBBox = Rect.fromPoints(Offset(0,0), Offset(0,0));
    Rect birthBBox = Rect.fromPoints(Offset(0,0), Offset(0,0));
    Rect dniBBox = Rect.fromPoints(Offset(0,0), Offset(0,0));

    bool isDNIExist = false;
    bool isNameExist = false;
    bool isBirthExist = false;

    bool nameFirstFailed = false;

    linecount = 0;
    for (TextBlock block in visionText.blocks) {  
      print("Block:");   
      for (TextLine line in block.lines) {
        print(line.text);

        if (matchEx1.hasMatch(line.text)) {
          for(TextElement element in line.elements){
            if(element.text.indexOf(matchEx1)!=-1){
              isDNIExist = true;
              dniBBox = Rect.fromPoints(Offset(element.boundingBox.topLeft.dx,element.boundingBox.topLeft.dy), Offset(element.boundingBox.bottomRight.dx,element.boundingBox.bottomRight.dy));
            }
          } 
        }

        if (matchEx4.hasMatch(line.text)) {
          for(TextElement element in line.elements){
            if(element.text.indexOf(matchEx4)!=-1){
              isNameExist = true;
              nameBBox = Rect.fromPoints(Offset(element.boundingBox.topLeft.dx,element.boundingBox.topLeft.dy), Offset(element.boundingBox.bottomRight.dx,element.boundingBox.bottomRight.dy));
            }
          }            
        }

        if (matchEx5.hasMatch(line.text)) {
          for(TextElement element in line.elements){
            if(element.text.indexOf(matchEx5)!=-1){
              isBirthExist = true;
              birthBBox= Rect.fromPoints(Offset(element.boundingBox.topLeft.dx,element.boundingBox.topLeft.dy), Offset(element.boundingBox.bottomRight.dx,element.boundingBox.bottomRight.dy));
            }
          } 
        }
      }
    }

    for (TextBlock block in visionText.blocks) {     
      for (TextLine line in block.lines) {
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
          try{
            for (TextElement element in block.lines[linecount+1].elements) {
              _elements.add(element);
              textCapture+="Father's last name: "+element.text + '\n';
            }
          }
          catch(e){
            textCapture+="Father's last name: null\n";
          }
          
        }

        if (matchEx3.hasMatch(line.text)) {
          try{
            for (TextElement element in block.lines[linecount+1].elements) {
              _elements.add(element);
              textCapture+="Mother's last name: "+element.text + '\n';
            }
          }
          catch(e){
            textCapture+="Mother's last name: null\n";
          }          
        }

        if (matchEx4.hasMatch(line.text)) {     
          if (block.lines.asMap().containsKey(linecount+1)) {
            for (TextElement element in block.lines[linecount+1].elements) {
                _elements.add(element);
                textCapture+="Name: "+element.text + '\n';
              }
          } else {
            nameFirstFailed = true;
          }          
        }

        if(nameFirstFailed && isDNIExist && isBirthExist){
          for (TextElement element in line.elements) {
            if(element.boundingBox.topLeft.dy>nameBBox.bottomLeft.dy && element.boundingBox.bottomLeft.dy<birthBBox.topLeft.dy && element.boundingBox.topRight.dx<dniBBox.bottomLeft.dx){
              _elements.add(element);
                textCapture+="Name: "+element.text + '\n';
            }                
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
                          TextDetectorPainter(_imageSize, _elements, boundingBox, signBoundingBox),
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
                                    builder: (context) => EditTextAU(recognizedText,"Edit Text Screen", resizedPath, signPath),
                                  ),
                                );
                              }   
                              if(select==1){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditTextDNI(recognizedText,"Edit Text Screen", resizedPath, signPath),
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
                                  builder: (context) => Result(recognizedText, signPath, resizedPath,"Result Screen"),
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
  TextDetectorPainter(this.absoluteImageSize, this.elements, this.boundingBox, this.signBoundingBox);

  final Size absoluteImageSize;
  final List<TextElement> elements;
  final Rect boundingBox;
  final Rect signBoundingBox;

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

    Rect signRect(Rect bounding) {
      return Rect.fromLTRB(
        bounding.left*scaleX,
        bounding.top*scaleY,
        bounding.right*scaleX,
        bounding.bottom*scaleY,
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
    canvas.drawRect(signRect(signBoundingBox), paint);
  }

  @override
  bool shouldRepaint(TextDetectorPainter oldDelegate) {
    return true;
  }
}