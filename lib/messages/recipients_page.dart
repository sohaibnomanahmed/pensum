import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:leaf/messages/recipients_provider.dart';
import 'package:leaf/messages/widgets/recipients_list.dart';

class RecipientsPage extends StatefulWidget {
  @override
  _RecipientsPageState createState() => _RecipientsPageState();
}

class _RecipientsPageState extends State<RecipientsPage> {
  @override
  void initState() {
    super.initState();
    context.read<RecipientsProvider>().fetchRecipients;
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<RecipientsProvider>().isLoading;
    // a search should come wheen afforable
    return Scaffold(
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : RecipientsList());
  }
}
