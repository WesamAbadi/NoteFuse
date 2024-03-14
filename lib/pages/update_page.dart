import 'package:flutter/material.dart';
import 'package:note_fuse/pages/home_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ota_update/ota_update.dart';

class UpdatePage extends StatelessWidget {
  final String currentAppVersion;
  final String version;
  final String url;
  final bool mandatory;
  const UpdatePage({
    Key? key,
    required this.currentAppVersion,
    required this.version,
    required this.url,
    this.mandatory = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var releaseNotesUrl =
        Uri.parse('https://github.com/WesamAbadi/NoteFuse/releases');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.info),
          onPressed: () {
            launchUrl(releaseNotesUrl);
          },
        ),
      ),
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
              SizedBox(height: 10),
              Text(
                mandatory
                    ? 'This update is mandatory.'
                    : 'This update is optional.',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
              ),
              Text(
                'All your data will be saved automatically.',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  '$currentAppVersion ➜ $version',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlue, // Change color to your preference
                    fontFamily:
                        'Roboto', // Change font family to your preference
                  ),
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return UpdateDialog(url: url);
                    },
                  );
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
              if (!mandatory)
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(),
                      ),
                    );
                  },
                  child: Text(
                    'Skip',
                    style: TextStyle(fontSize: 13, color: Colors.blue),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class UpdateDialog extends StatefulWidget {
  final String url;

  const UpdateDialog({Key? key, required this.url}) : super(key: key);

  @override
  _UpdateDialogState createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Downloading update"),
      content: LinearProgressIndicator(),
    );
  }

  @override
  void initState() {
    super.initState();
    tryOtaUpdate();
  }

  Future<void> tryOtaUpdate() async {
    try {
      OtaUpdate()
          .execute(
        widget.url,
        destinationFilename: 'NoteFuse.apk',
      )
          .listen(
        (OtaEvent event) {
          // Handle events as needed
          if (event.status == OtaStatus.DOWNLOADING) {
            // Update the progress of the dialog
            setState(() {});
          }
        },
      );
    } catch (e) {
      print('Failed to make OTA update. Details: $e');
    }
  }
}
