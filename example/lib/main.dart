import 'package:flutter/material.dart';
import 'package:multimedia_story_view/multimedia_story_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => StoryPage(),
                ),
              );
            },
            child: Text('Running on')),
      ),
    );
  }
}

class StoryPage extends StatefulWidget {
  @override
  _StoryPageState createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  final StoryController controller = StoryController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiMediaStoryView(
        storyItems: [
          StoryItem(
            Center(
              child: Container(
                color: Colors.blueAccent,
                child: Text("HELLO"),
              ),
            ),
            duration: Duration(seconds: 5),
          ),
          StoryItem(
            Center(
              child: Container(
                color: Colors.greenAccent,
                child: Text("Bye"),
              ),
            ),
            duration: Duration(seconds: 5),
          ),
          StoryItem(
            Center(
              child: Container(
                color: Colors.greenAccent,
                child: Text("TATA"),
              ),
            ),
            duration: Duration(seconds: 5),
          ),
          StoryItem(
              Column(
                children: [
                  Expanded(
                    child: StoryImage.url(
                      "https://image.ibb.co/cU4WGx/Omotuo-Groundnut-Soup-braperucci-com-1.jpg",
                      controller: controller,
                    ),
                    flex: 4,
                  ),
                  Expanded(
                    child: Container(
                      height: 400,
                      color: Colors.blueAccent,
                    ),
                    flex: 1,
                  )
                ],
              ),
              duration: Duration(seconds: 5),
          ),
          StoryItem(
            Column(
              children: [
                Expanded(
                  child: StoryVideo(
                    "https://www.youtube.com/watch?v=RMeLMnzFuh4",
                    controller,
                  ),
                  flex: 4,
                ),
                Expanded(
                  child: Container(
                    height: 400,
                    color: Colors.blueAccent,
                  ),
                  flex: 1,
                )
              ],
            ),
            duration: Duration(seconds: 5),
          ),
          StoryItem(
            Center(
              child: Container(
                color: Colors.indigo,
                child: Text("NEW Story"),
              ),
            ),
            duration: Duration(seconds: 5),
          ),
        ],
        controller: controller,
        onCloseButtonPressed: () {
          print("CLOSE BUTTON PRESSED");
        },
      ),
    );
  }
}

