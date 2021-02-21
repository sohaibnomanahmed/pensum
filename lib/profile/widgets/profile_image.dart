import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/profile.dart';
import '../profile_provider.dart';

class ProfileImage extends StatelessWidget {
  final Profile profile;

  ProfileImage(this.profile);

  @override
  Widget build(BuildContext context) {
    final isLoading = context.read<ProfileProvider>().isLoading;
    return Container(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 70,
            backgroundImage: NetworkImage(profile.imageUrl),
          ),
          if (profile.isMe)
            FloatingActionButton(
              elevation: 0,
              mini: true,
              child: Icon(Icons.edit),
              onPressed: isLoading
                  ? null
                  : () async {
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      final errorColor = Theme.of(context).errorColor;
                      final primaryColor = Theme.of(context).primaryColor;
                      final result = await context
                          .read<ProfileProvider>()
                          .setProfileImage(ImageSource.gallery);
                      if (!result) {
                        // remove snackbar if existing and show a new with error message
                        scaffoldMessenger.hideCurrentSnackBar();
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            backgroundColor: errorColor,
                            content: Text(
                              'Error occured changing profile image',
                            ),
                          ),
                        );
                      }
                      if (result) {
                        // remove snackbar if existing and show a new with error message
                        scaffoldMessenger.hideCurrentSnackBar();
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            backgroundColor: primaryColor,
                            content: Text('Successfully changed profile image'),
                          ),
                        );
                      }
                    },
            ),
        ],
      ),
    );
  }
}
