import 'package:flutter/material.dart';
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
                initialValue: _firstname.isEmpty ? null : _firstname,
                decoration: InputDecoration(labelText: 'Firstname'),
                onChanged: (value) => _firstname = value,
              ),
              TextFormField(
                initialValue: _lastname.isEmpty ? null : _lastname,
                decoration: InputDecoration(labelText: 'Lastname'),
                onChanged: (value) => _lastname = value,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: (_firstname.isEmpty || _lastname.isEmpty)
                    ? null
                    : () async {
                        // get data before popping screen
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        final errorColor = Theme.of(context).errorColor;
                        final primaryColor = Theme.of(context).primaryColor;
                        // pop screen
                        Navigator.of(context).pop();
                        // try updating the user profile
                        final result = await context
                            .read<ProfileProvider>()
                            .setProfile(
                                firstname: Profile.capitalizaName(_firstname),
                                lastname: Profile.capitalizaName(_lastname));
                        // check if an error occured
                        if (!result) {
                          // remove snackbar if existing and show a new with error message
                          final errorMessage =
                              context.read<ProfileProvider>().errorMessage;
                          scaffoldMessenger.hideCurrentSnackBar();
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              backgroundColor: errorColor,
                              content: Text(errorMessage),
                            ),
                          );
                        }
                        if (result) {
                          // remove snackbar if existing and show a new with error message
                          scaffoldMessenger.hideCurrentSnackBar();
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              backgroundColor: primaryColor,
                              content: Text('Succesfully edited profile'),
                            ),
                          );
                        }
                      },
                child: Text('Edit profile'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
