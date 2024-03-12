import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdatePage extends StatelessWidget {
  final String version;
  final String url;
  const UpdatePage({Key? key, required this.version, required this.url})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var linkUrl = Uri.parse(url);

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Container(
          width: 300,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Update Available',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10), // Add a gap of 10 pixels
              Text(
                'This update is mandatory due to crucial changes in the app',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
              ),
              SizedBox(height: 50), // Add a larger gap of 20 pixels
              ElevatedButton(
                onPressed: () {
                  // Implement download functionality
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Download',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Implement download functionality
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  url,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 10), // Add a gap of 10 pixels
              TextButton(
                onPressed: () {
                  launchUrl(
                      linkUrl); // Launch the URL when the button is pressed
                },
                child: Text(
                  'Read More',
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}