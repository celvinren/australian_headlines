import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: MyThemeColor.themeColor(),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Australian News'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: MyAppBar().appBar(),
        body: TabBarView(
          children: List.generate(
              tabs.length, (index) => MyListView(title: tabs[index])),
        ),
      ),
    );
  }
}

class MyListView extends StatefulWidget {
  final String title;

  MyListView({this.title});

  @override
  _MyListViewState createState() => _MyListViewState();
}

class _MyListViewState extends State<MyListView>
    with AutomaticKeepAliveClientMixin<MyListView> {
  @override
  void initState() {
    // TODO: implement initState
    if (myNewsData.isEmpty || myNewsData[widget.title] == null) {
      fetchNews();
    }
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(itemBuilder: (BuildContext _context, int i) {
      return myListViewBuilder(i);
    });
  }

  Container myListViewBuilder(int i) {
    var newsMap = myNewsData[widget.title];

    if (newsMap != null) {
      return Container(
        decoration: BoxDecoration(
          border: BorderDirectional(
              start: BorderSide(color: MyThemeColor.themeColor(), width: 10),
              bottom: BorderSide(color: MyThemeColor.themeColor(), width: 10),
              end: BorderSide(color: MyThemeColor.themeColor(), width: 10)),
        ),
        // Border(
        //     left: BorderSide(width: 10),
        //     right: BorderSide(width: 10),
        //     bottom: BorderSide(
        //         width: 10))), //.all(width: 5, color: Colors.blue)),
        padding: EdgeInsets.all(4),
        child: FlatButton(
          onPressed: () {
            {
              Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                return new Browser(
                  url: newsMap['articles'][i]['url'],
                  title: "News",
                );
              }));
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                newsMap['articles'][i]['title'] == null
                    ? 'Anonymous'
                    : newsMap['articles'][i]['title'],
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              Text(
                newsMap['articles'][i]['source']['name'] == null
                    ? 'Publisher: Anonymous'
                    : 'Publisher: ' + newsMap['articles'][i]['source']['name'],
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey),
              ),
              Text(
                newsMap['articles'][i]['author'] == null
                    ? 'Author: No Author'
                    : 'Author: ' + newsMap['articles'][i]['author'],
                style: TextStyle(fontSize: 15),
              ),
              FadeInImage(
                placeholder: AssetImage('images/Loading.png'),
                image: NetworkImage(newsMap['articles'][i]['urlToImage'] == null
                    ? 'https://tacm.com/wp-content/uploads/2018/01/no-image-available.jpeg'
                    : newsMap['articles'][i]['urlToImage']),
              )
            ],
          ),
        ),
      );
    } else {
      return null;
    }
  }

  void openNews(String url) {
    Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
      return new Browser(
        url: url,
        title: "News",
      );
    }));
  }

  void fetchNews() async {
    String url = '';
    if (widget.title == 'HeadLines') {
      url =
          'https://newsapi.org/v2/top-headlines?country=au&pageSize=100&apiKey=70c602d38943461886963ffc12f2b53b';
    } else {
      url = 'https://newsapi.org/v2/top-headlines?country=au&category=' +
          widget.title.toLowerCase() +
          '&apiKey=70c602d38943461886963ffc12f2b53b';
    }
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      myNewsData[widget.title] = json.decode(response.body);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
    setState(() {});
  }
}

var myNewsData = {};
var tabs = [
  'HeadLines',
  'Technology',
  'Sports',
  'Entertainment',
  'Science',
  //'Health',
  'Business'
];

class MyAppBar {
  List<Tab> getAllTabsList() {
    return List.generate(
        tabs.length,
        (index) => Tab(
              text: tabs[index],
            ));
  }

  AppBar appBar() {
    return AppBar(
      title: TabBar(
        isScrollable: true,
        tabs: getAllTabsList(),
      ),
      //title: Text(widget.title),
    );
  }
}

class Browser extends StatelessWidget {
  const Browser({Key key, this.url, this.title}) : super(key: key);

  final String url;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: WebView(
        initialUrl: url,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}

class MyThemeColor {
  static MaterialColor themeColor() {
    return MaterialColor(0xFFb43c3c, <int, Color>{
      50: Color(0xFFb43c3c),
      100: Color(0xFFb43c3c),
      200: Color(0xFFb43c3c),
      300: Color(0xFFb43c3c),
      400: Color(0xFFb43c3c),
      500: Color(0xFFb43c3c),
      600: Color(0xFFb43c3c),
      700: Color(0xFFb43c3c),
      800: Color(0xFFb43c3c),
      900: Color(0xFFb43c3c),
    });
  }
}
