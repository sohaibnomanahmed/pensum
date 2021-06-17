import 'package:flutter/material.dart';
import 'package:leaf/global/functions.dart';
import 'package:leaf/profile/models/profile.dart';
import 'package:provider/provider.dart';

import '../profile_provider.dart';

class EditProfileBottomSheet extends StatefulWidget {
  final String firstname;
  final String lastname;

  EditProfileBottomSheet(this.firstname, this.lastname);

  @override
  _EditProfileBottomSheetState createState() => _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends State<EditProfileBottomSheet> {
  var _firstname = '';
  var _lastname = '';

  @override
  void initState() {
    super.initState();
    if (widget.firstname.isNotEmpty) {
      _firstname = widget.firstname;
    }
    if (widget.lastname.isNotEmpty) {
      _lastname = widget.lastname;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.person_pin_circle_rounded,
                  size: 80, color: Theme.of(context).primaryColor),
              TextFormField(
                textCapitalization: TextCapitalization.words,
                initialValue: _firstname.isEmpty ? null : _firstname,
                decoration: InputDecoration(labelText: 'Firstname'),
                onChanged: (value) => _firstname = value,
              ),
              TextFormField(
                textCapitalization: TextCapitalization.words,
                initialValue: _lastname.isEmpty ? null : _lastname,
                decoration: InputDecoration(labelText: 'Lastname'),
                onChanged: (value) => _lastname = value,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: (_firstname.isEmpty || _lastname.isEmpty)
                    ? null
                    : () async => ButtonFunctions.onPressHandler(
                          context: context,
                          popScreen: true,
                          action: () async => await context
                              .read<ProfileProvider>()
                              .setProfileName(
                                  firstname: Profile.capitalizaName(_firstname),
                                  lastname: Profile.capitalizaName(_lastname)),
                          errorMessage:
                              'Something went wrong, please try again!',
                          successMessage: 'Succesfully edited profile',
                        ),
                child: Text('Edit profile'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
