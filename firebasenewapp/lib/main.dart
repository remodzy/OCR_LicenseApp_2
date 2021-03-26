import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebasenewapp/image_detail.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
  } on Exception catch (e) {
    print(e);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ML Vision',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FirstRoute(),
    );
  }
}

class FirstRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera App'),
      ),
      body: Center(
        child: Column(
          
          children:[
            ElevatedButton(
            child: Text('AU Driver License'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen(title: "AU Driver License",select: 0,)),
              );
            },
          ),
            ElevatedButton(child: Text('PE DNI'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen(title: "PE DNI",select: 1,)),
                );
              },
              )],
        )
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key, this.title, this.select}) : super(key: key);
  final String title;
  final int select;
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PickedFile imageURI;
  String imageResizedPath;
  Image imageNew;
  String optSelected;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    switch (widget.select) {
      case 0:
        optSelected = "AU Driver License";
        break;
      case 1:
        optSelected = "PE DNI card";
        break;
      default:
        optSelected = "No option";
        break;
    }
    super.initState();
  }

  Future <int> getImageFromCameraGallery(bool isCamera) async {
  
    // Formatting Date and Time
    String dateTime = DateFormat.yMMMd()
        .addPattern('-')
        .add_Hms()
        .format(DateTime.now())
        .toString();

    String formattedDateTime = dateTime.replaceAll(' ', '');
    print("Formatted: $formattedDateTime");

    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String visionDir = '${appDocDir.path}/Photos/Vision\ Images';
    await Directory(visionDir).create(recursive: true);

    final imageRPath = '$visionDir/imageResized_$formattedDateTime.jpg';
    var image = await _picker.getImage(source: (isCamera == true) ? ImageSource.camera : ImageSource.gallery);
    setState(() {      
      imageURI = image;
      imageResizedPath = imageRPath;
    });
    return 0;
  }  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ML Vision'),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Text('TakePicture: '+ optSelected),
      ),
        floatingActionButton: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                FloatingActionButton(
                  onPressed: (){
                      getImageFromCameraGallery(true).then((int flag) {
                          if (imageURI.path != null && imageResizedPath != null) {
                            final image = img.decodeImage(File(imageURI.path).readAsBytesSync());
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailScreen(imageURI.path, imageResizedPath, image,widget.title, widget.select),
                              ),
                            );
                          }
                        });
                  },
                  child: Icon(
                    Icons.camera
                    ),
                  ),                
              ],
            )
          
    );
  }
}