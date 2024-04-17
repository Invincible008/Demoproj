import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gallery',
      home: ImageGallery(),
    );
  }
}

class ImageGallery extends StatefulWidget {
  @override
  _ImageGalleryState createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  final String apiKey = '43424528-b1ab65c946858c403b47de749';

  List<String> images = [];
  List<int> viewCounts = [];
  List<int> likeCounts = [];

  @override
  void initState() {
    super.initState();
     fetchImages();
  }

  Future<void> fetchImages() async {
    final String apiUrl =
        'https://pixabay.com/api/?key=$apiKey&image_type=photo&per_page=50';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        images = List<String>.from(data['hits'].map((hit) => hit['webformatURL']));
       viewCounts = List<int>.filled(images.length, 0);
        likeCounts = List<int>.filled(images.length, 0);
      });
    } else {
      throw Exception('Failed to load images');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Gallery'),
      ),
      body: GridView.builder(
        itemCount: images.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _calculateCrossAxisCount(context), 
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                viewCounts[index]++;
              });
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenImage(
                    imageUrl: images[index],
                    views: viewCounts[index],
                    likes: likeCounts[index],
                    onLike: () {
                      setState(() {
                        likeCounts[index]++;
                      });
                    },
                  ),
                ),
              );
            },
            child: Stack(
              children: [
                Container(
                  height: 200, 
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.network(images[index], fit: BoxFit.cover),
                      ),
                      SizedBox(height: 8),
                      Text('Views: ${viewCounts[index]}', style: TextStyle(fontSize: 12)),
                      Text('Likes: ${likeCounts[index]}', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: LikeButton(
                    onTap: () {
                      setState(() {
                        likeCounts[index]++;
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  int _calculateCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = (screenWidth / 150).floor(); 
    return crossAxisCount > 1 ? crossAxisCount : 1; 
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  final int views;
  final int likes;
  final Function()? onLike;

  const FullScreenImage({
    required this.imageUrl,
    required this.views,
    required this.likes,
    this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Image.network(imageUrl),
          SizedBox(height: 16),
          Text('Views: $views'),
          Text('Likes: $likes'),
        ],
      ),
    );
  }
}

class LikeButton extends StatelessWidget {
  final VoidCallback onTap;

  const LikeButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(Icons.favorite, color: Colors.red),
    );
  }
}
