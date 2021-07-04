import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaf/global/widgets/paging_view.dart';

void main() {
  testWidgets(
      'Should only call for action once, when scrolled to the end of a list',
      (tester) async {
    // GIVEN: a paging view, with scroll-able list
    var methodCall = 0;
    var list = ListView(
        children:
            List.generate(25, (index) => ListTile(title: Text('$index'))));

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: PagingView(action: () => methodCall += 1, child: list)),
    ));

    // WHEN: scrolled to the end of the page
    await tester.drag(find.byType(ListView), const Offset(0, -1000));

    // THEN: action should only be called once
    expect(methodCall, 1);
  });
}
