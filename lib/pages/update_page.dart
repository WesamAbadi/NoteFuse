import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ota_update/ota_update.dart';

class UpdatePage extends StatelessWidget {
  final String version;
  final String url;
  const UpdatePage({Key? key, required this.version, required this.url})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // var linkUrl = Uri.parse(url);
    var releaseNotesUrl =
        Uri.parse('https://github.com/WesamAbadi/NoteFuse/releases');

    void updateTest(BuildContext context) async {
      try {
        //LINK CONTAINS APK OF FLUTTER HELLO WORLD FROM FLUTTER SDK EXAMPLES
        OtaUpdate()
            .execute(
          url,
          // OPTIONAL
          destinationFilename: 'NoteFuse.apk',
          //OPTIONAL, ANDROID ONLY - ABILITY TO VALIDATE CHECKSUM OF FILE:
          // sha256checksum:
          //     "d6da28451a1e15cf7a75f2c3f151befad3b80ad0bb232ab15c20897e54f21478",
        )
            .listen(
          (OtaEvent event) {
            // Handle events as needed
          },
        );
      } catch (e) {
        print('Failed to make OTA update. Details: $e');
      }
    }

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
                'Update Available!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10), // Add a gap of 10 pixels
              Text(
                'This update is mandatory due to crucial changes in the app.',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
              ),
              SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  // launchUrl(linkUrl);
                  updateTest(context);
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
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  launchUrl(releaseNotesUrl);
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
