import 'package:flutter/material.dart';
import 'package:leaf/global/utils.dart';
import 'package:leaf/localization/localization.dart';
import 'package:leaf/messages/messages_page.dart';
import 'package:leaf/notifications/notification_provider.dart';
import 'package:leaf/presence/presence_provider.dart';
import 'package:leaf/settings/how_to_page.dart';
import 'package:provider/provider.dart';

import 'package:leaf/authentication/authentication_provider.dart';

import 'delete_account_bottom_sheet.dart';

class SettingsList extends StatefulWidget {
  @override
  _SettingsListState createState() => _SettingsListState();
}

class _SettingsListState extends State<SettingsList> {
  bool resetBtn = false;
  bool feedbackBtn = false;
  bool signOutBtn = false;

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthenticationProvider>().isLoading;
    final email = context.watch<AuthenticationProvider>().email;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final loc = Localization.of(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          ListTile(
              leading: resetBtn
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(),
                    )
                  : Icon(Icons.lock_rounded),
              title:
                  Text(loc.getTranslatedValue('settings_list_reset_pass_text')),
              onTap: isLoading
                  ? null
                  : () async {
                      setState(() => resetBtn = true);
                      await onPressHandler(
                        context: context,
                        action: () => context
                            .read<AuthenticationProvider>()
                            .resetPassword(email!),
                        lateErrorMessage: () =>
                            context.read<AuthenticationProvider>().errorMessage,
                        successMessage: loc
                            .getTranslatedValue('reset_pass_success_msg_text'),
                      );
                      setState(() => resetBtn = false);
                    }),
          ListTile(
            leading: feedbackBtn
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(),
                  )
                : Icon(Icons.feedback_rounded),
            title: Text(
                loc.getTranslatedValue('settings_list_send_feedback_title')),
            subtitle: Text(
                loc.getTranslatedValue('settings_list_send_feedback_subtitle')),
            onTap: isLoading
                ? null
                : () async {
                    setState(() => feedbackBtn = true);
                    final serviceAccount = await context
                        .read<AuthenticationProvider>()
                        .getAdminAccount();
                    if (serviceAccount != null) {
                      await Navigator.of(context, rootNavigator: true)
                          .pushNamed(
                        MessagesPage.routeName,
                        arguments: {
                          'id': serviceAccount.uid,
                          'image': serviceAccount.imageUrl,
                          'name': serviceAccount.fullName
                        },
                      );
                    } else {
                      // remove snackbar if existing and show a new with error message
                      scaffoldMessenger.hideCurrentSnackBar();
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          backgroundColor: Theme.of(context).errorColor,
                          content: Text(
                            loc.getTranslatedValue('error_msg'),
                          ),
                        ),
                      );
                    }
                    setState(() => feedbackBtn = false);
                  },
          ),
          ListTile(
            leading: Icon(Icons.category_rounded),
            title: Text(loc.getTranslatedValue('settings_list_howto_text')),
            onTap: () => Navigator.of(context, rootNavigator: true)
                .pushNamed(HowToPage.routeName),
          ),
          // ListTile(
          //   leading: Icon(Icons.translate_rounded),
          //   title: Text('Language, Location and Currency'),
          //   onTap: () => showModalBottomSheet(
          //     isScrollControlled: true,
          //     context: context,
          //     builder: (_) => LocationBottomSheet(),
          //   ),
          // ),
          ListTile(
              leading: signOutBtn
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(),
                    )
                  : Icon(Icons.exit_to_app_rounded),
              title: Text(loc.getTranslatedValue('settings_list_log_out_text')),
              onTap: isLoading
                  ? null
                  : () async {
                      setState(() => signOutBtn = true);
                      await onPressHandler(
                          context: context,
                          action: () async {
                            // unsubscribe from all topics
                            await context
                                .read<NotificationProvider>()
                                .unsubscribeFromAllTopics();
                            // remove presence
                            await context
                                .read<PresenceProvider>()
                                .goOffline(signout: true);
                            // sign out
                            return context
                                .read<AuthenticationProvider>()
                                .signOut();
                          },
                          errorMessage: loc.getTranslatedValue('error_msg'));
                      setState(() => signOutBtn = false);
                    }),
          ListTile(
            leading: Icon(Icons.delete_rounded),
            title: Text(
                loc.getTranslatedValue('settings_list_delete_account_text')),
            onTap: () => showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (_) => DeleteAccountBottomSheet(),
            ),
          ),
        ],
      ),
    );
  }
}
