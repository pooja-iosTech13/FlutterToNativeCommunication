import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter to Native iOS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Objective-c communication example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  static const platform = const MethodChannel('com.LW2/app');
  String encryptedData = "Empty";

    @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            RaisedButton(
              child: Text('Invoke Objective-c method channel'),
              onPressed: (){
                _invokeObjectiveCMethod();
              },
            ),
            Text(encryptedData),
          ],
        ),
      ),
    );
  }


  Future<void> _invokeObjectiveCMethod() async {
    String data;
    try {
      final String result = await platform.invokeMethod('encryptData', ["Pooja","Test123"]);

      data = '$result';
    } on PlatformException catch (e) {
      data = "Failed to encrypt data: '${e.message}'.";
    }

    setState(() {
      encryptedData = data;
    });
  }
}