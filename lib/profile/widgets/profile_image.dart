import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leaf/images/photo_page.dart';
import 'package:leaf/presence/widgets/presence_bubble.dart';
import 'package:provider/provider.dart';

import '../models/profile.dart';
import '../profile_provider.dart';

class ProfileImage extends StatelessWidget {
  final Profile profile;

  ProfileImage(this.profile);

  @override
  Widget build(BuildContext context) {
    final isLoading = context.read<ProfileProvider>().isLoading;
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        OpenContainer(
          closedColor: Colors.transparent,
          closedElevation: 0,
          openElevation: 0,
          useRootNavigator: true,
          openBuilder: (_, __) => PhotoPage(profile.imageUrl),
          closedBuilder: (_, __) => CircleAvatar(
            radius: 70,
            backgroundImage: NetworkImage(profile.imageUrl),
          ),
        ),
        profile.isMe ?
          FloatingActionButton(
            elevation: 0,
            mini: true,
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
            child: Icon(Icons.edit),
          ):
          PresenceBubble(profile.uid, 25)
      ],
    );
  }
}
