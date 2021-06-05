import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:leaf/settings/widgets/settings_list.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        leading: Icon(Icons.settings_rounded, size: 50, color: Theme.of(context).splashColor,),
        middle:
            Text('Settings', style: Theme.of(context).textTheme.headline6!.copyWith(
              color: Theme.of(context).hintColor
            )),
      ),
      body: SettingsList(),
    );
  }
}
