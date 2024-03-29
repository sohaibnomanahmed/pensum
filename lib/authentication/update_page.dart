import 'package:flutter/material.dart';
import 'package:leaf/localization/localization.dart';
import 'package:new_version/new_version.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdatePage extends StatelessWidget {
  final VersionStatus? status;

  const UpdatePage({Key? key, this.status}) : super(key: key);

  void _launchURL() async {
  final url = status!.appStoreLink;
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

  @override
  Widget build(BuildContext context) {
    final loc = Localization.of(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: Icon(
                  Icons.eco,
                  size: 60,
                  color: Theme.of(context).primaryColor,
                ),
                contentPadding: EdgeInsets.zero,
                title: Text(loc.getTranslatedValue('update_title')),
                subtitle: Text(loc.getTranslatedValue('update_body') + ' ${status!.storeVersion}'),
            ),
            SizedBox(height: 30),
            ElevatedButton(onPressed: _launchURL, child: Text(loc.getTranslatedValue('update_btn_text')))
          ],
        ),
      ),
    );
  }
}
