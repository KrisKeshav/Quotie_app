import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quotie/helper/global.dart';
import 'package:quotie/screen/favourites_screen.dart';
import 'package:screenshot/screenshot.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String quote = "";
  String owner = "";
  String imglink = "";
  bool working = false;
  final grey = Colors.blueGrey[800];
  ScreenshotController screenshotController = ScreenshotController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<Map<String, String>> favorites = [];

  @override
  void initState() {
    super.initState();

    // Initialize the AnimationController
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Initialize the Fade Animation
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    // Start by fetching the quote
    getQuote();
    _loadFavorites();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> getQuote() async {
    setState(() {
      working = true;
      quote = "";
      owner = "";
      imglink = "";
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.api-ninjas.com/v1/quotes?category=happiness'),
        headers: {
          'X-Api-Key': quotesApiKey,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> res = jsonDecode(response.body);
        if (res.isNotEmpty) {
          setState(() {
            owner = res[0]["author"]?.toString().trim() ?? "Unknown";
            quote = res[0]["quote"]?.replaceAll("â", " ") ?? "No quote available";
            getImg(owner);
          });
        }
      } else {
        offline();
      }
    } catch (e) {
      offline();
    } finally {
      setState(() {
        working = false;
      });
      _animationController.forward(from: 0); // Trigger the animation
    }
  }

  void offline() {
    setState(() {
      owner = "Janet Fitch";
      quote = "The phoenix must burn to emerge";
      imglink = "";
      working = false;
    });
  }

  Future<void> shareQuote() async {
    try {
      // Capture the screenshot
      final screenshot = await screenshotController.capture();

      if (screenshot == null) {
        print('Screenshot failed');
        return;
      }

      // Get the directory to save the screenshot
      final directory = await getApplicationDocumentsDirectory();
      final screenshotDir = Directory('${directory.path}/screenshots');

      // Create the directory if it doesn't exist
      if (!await screenshotDir.exists()) {
        await screenshotDir.create(recursive: true);
      }

      final path = '${screenshotDir.path}/${DateTime.now().toIso8601String()}.png';
      final file = File(path);

      // Save the screenshot to a file
      await file.writeAsBytes(screenshot);

      // Share the screenshot and quote text
      await Share.shareXFiles([XFile(file.path)], text: quote);
      print('Screenshot shared successfully');
    } catch (e) {
      print('Error sharing the screenshot: $e');
    }
  }

  Future<void> getImg(String name) async {
    try {
      final response = await http.get(
        Uri.parse("https://en.wikipedia.org/w/api.php?action=query&generator=search&gsrlimit=1&prop=pageimages%7Cextracts&pithumbsize=400&gsrsearch=$name&format=json"),
      );
      final res = json.decode(response.body)["query"]["pages"];
      final page = res.values.first;
      setState(() {
        imglink = page["thumbnail"]?["source"] ?? "";
        working = false;
      });
    } catch (e) {
      setState(() {
        imglink = "";
        working = false;
      });
    }
  }

  Widget drawImg() {
    return imglink.isEmpty
        ? Image.asset("assets/images/offline.jpeg", fit: BoxFit.cover)
        : FadeTransition(
      opacity: _fadeAnimation,
      child: Image.network(imglink, fit: BoxFit.cover),
    );
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString('favorites') ?? '[]';
    try {
      final List<dynamic> decodedFavorites = jsonDecode(favoritesJson);

      setState(() {
        favorites = decodedFavorites.map((item) {
          // Safely convert each dynamic map to Map<String, String>
          return (item as Map<dynamic, dynamic>).map<String, String>((key, value) {
            return MapEntry(key.toString(), value.toString());
          });
        }).toList();
      });
    } catch (e) {
      print('Error loading favorites: $e');
      setState(() {
        favorites = [];
      });
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = jsonEncode(favorites);
    prefs.setString('favorites', favoritesJson);
  }

  void _likeQuote() {
    setState(() {
      favorites.add({"quote": quote, "owner": owner});
      _saveFavorites();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quote added to favorites!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.tealAccent.withOpacity(0.7),
        elevation: 4,
        title: const Text("Quotie"),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        titleSpacing: mq.size.width * 0.06,
        leading: const Icon(CupertinoIcons.home, color: Colors.lightGreenAccent),
        actions: [
          IconButton(
            padding: const EdgeInsets.only(right: 16.0),
            icon: const Icon(Icons.favorite, color: Colors.redAccent, size: 30,),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoritesScreen()),
              );
            },
          ),
        ],
      ),
      backgroundColor: grey,
      body: Screenshot(
        controller: screenshotController,
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: <Widget>[
            drawImg(),
            Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, 0.6, 1],
                  colors: [
                    grey!.withAlpha(70),
                    grey!.withAlpha(220),
                    grey!.withAlpha(255),
                  ],
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      quote,
                      style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black,
                              offset: Offset(5.0, 5.0),
                            ),
                          ],
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (owner.isNotEmpty)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        "- $owner",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                            fontSize: 20,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          FloatingActionButton(
            heroTag: null,
            onPressed: !working ? getQuote : null,
            backgroundColor: Colors.blueGrey,
            child: const Icon(Icons.refresh, size: 30, color: Colors.white),
          ),
          FloatingActionButton(
            heroTag: null,
            onPressed: quote.isNotEmpty ? _likeQuote : null,
            backgroundColor: Colors.pinkAccent,
            child: const Icon(Icons.favorite, size: 30, color: Colors.white),
          ),
          FloatingActionButton(
            heroTag: null,
            onPressed: quote.isNotEmpty ? shareQuote : null,
            backgroundColor: Colors.green,
            child: const Icon(Icons.share, size: 30, color: Colors.white),
          ),

        ],
      ),
    );
  }
}
