import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'Should display the bottom sheet above the soft keyboard',
      (tester) async {
    // GIVEN: a paging view, with scroll-able list
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body:  Center(
            child: ElevatedButton(
          onPressed: () => showModalBottomSheet(
              context: context,
              //isScrollControlled: true,
              builder: (_) => Column(
                    children: [
                      TextField(),
                      ListTile(
                        title: Text('Am I Showing?'),
                      )
                    ],
                  )),
          child: Text('Show Bottom Sheet'),
        )),
      )),
    ));

    // WHEN: scrolled to the end of the page
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    // verify the bottom sheet is present
    expect(find.byType(TextField), findsOneWidget);

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();

    // THEN: action should only be called once
    // TODO not done, need to check if visible not only found
    expect(find.byType(ListTile), findsOneWidget);
  });
}
