import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:leaf/global/widgets/leaf_error.dart';
import 'package:leaf/messages/messages_page.dart';
import 'package:provider/provider.dart';

import '../global/extensions.dart';
import 'profile_provider.dart';
import 'widgets/edit_profile_bottom_sheet.dart';
import 'widgets/profile_deals_list.dart';
import 'widgets/profile_image.dart';
import '../global/widgets/bezierContainer.dart';

class ProfilePage extends StatefulWidget {
  static const routeName = '/profile';
  final String uid;

  ProfilePage([this.uid]);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileProvider>().fetchProfile(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final height = mediaQuery.size.height;
    final width = mediaQuery.size.width;

    final profile = context.watch<ProfileProvider>().profile;
    final isLoading = context.watch<ProfileProvider>().isLoading;
    final isError = context.watch<ProfileProvider>().isError;
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : isError
              ? Center(
                  child: LeafError(
                      context.read<ProfileProvider>().reFetchProfile,
                      widget.uid),
                )
              : SingleChildScrollView(
                  child: Stack(
                    children: [
                      Positioned(
                        top: -height * .20,
                        right: -width * .2,
                        child: BezierContainer(),
                      ),
                      Column(
                        children: [
                          AppBar(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            iconTheme: IconThemeData(
                                color: Theme.of(context).primaryColorDark),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.only(
                                    left: 20, right: 20, bottom: 20),
                                child: ProfileImage(profile),
                              ),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(profile.fullName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5),
                                    Text('Member since: ' +
                                        DateFormat('y')
                                            .format(profile.creationTime)),
                                    profile.isMe
                                        ? ElevatedButton(
                                            onPressed: () =>
                                                showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  context: context,
                                                  builder: (_) =>
                                                      ChangeNotifierProvider
                                                          .value(
                                                    value:
                                                        context.read<ProfileProvider>().provider,
                                                    child:
                                                        EditProfileBottomSheet(
                                                      profile.firstname
                                                          .split(RegExp('\\s+'))
                                                          .reduce((value,
                                                                  element) =>
                                                              value
                                                                  .capitalize() +
                                                              ' ' +
                                                              element
                                                                  .capitalize())
                                                          .capitalize(),
                                                      profile.lastname
                                                          .split(RegExp('\\s+'))
                                                          .reduce((value,
                                                                  element) =>
                                                              value
                                                                  .capitalize() +
                                                              ' ' +
                                                              element
                                                                  .capitalize())
                                                          .capitalize(),
                                                    ),
                                                  ),
                                                ),
                                            child: Text('Edit Profile'))
                                        : ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            primary: Colors.pink
                                          ),
                                            onPressed: () => Navigator.of(
                                                        context,
                                                        rootNavigator: true)
                                                    .pushNamed(
                                                        MessagesPage.routeName,
                                                        arguments: {
                                                      'id': profile.uid,
                                                      'image': profile.imageUrl,
                                                      'name': profile.fullName
                                                    }),
                                            child: Text('Send message'))
                                  ],
                                ),
                              )
                            ],
                          ),
                          ListTile(
                            leading: Icon(Icons.spa_rounded,
                                color: Theme.of(context).primaryColor),
                            title: Text('Deals'),
                          ),
                          Divider(
                            height: 1,
                          ),
                          ProfileDealsList(),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }
}
