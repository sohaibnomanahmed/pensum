import 'package:flutter/material.dart';
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
  final ProfileProvider profileProvider;

  ProfilePage({this.uid, @required this.profileProvider});

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
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
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
                                Text(
                                  profile.fullName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline5
                                      .copyWith(color: Colors.teal[900]),
                                ),
                                // TODO store date created if not aldready stored by firebase
                                Text('Member since: 2021'),
                                ElevatedButton(
                                    onPressed: () => showModalBottomSheet(
                                          isScrollControlled: true,
                                          context: context,
                                          builder: (_) =>
                                              ChangeNotifierProvider.value(
                                            value: widget.profileProvider,
                                            child: EditProfileBottomSheet(
                                              profile.firstname
                                                  .split(RegExp('\\s+'))
                                                  .reduce((value, element) =>
                                                      value.capitalize() +
                                                      ' ' +
                                                      element.capitalize())
                                                  .capitalize(),
                                              profile.lastname
                                                  .split(RegExp('\\s+'))
                                                  .reduce((value, element) =>
                                                      value.capitalize() +
                                                      ' ' +
                                                      element.capitalize())
                                                  .capitalize(),
                                            ),
                                          ),
                                        ),
                                    child: Text('Edit Profile'))
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
