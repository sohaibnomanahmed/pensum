import 'package:flutter_test/flutter_test.dart';
import 'package:leaf/profile/models/profile.dart';

void main() {
  test(
      'Should make user input for firstname and lastname stored in default naming convention',
      () async {
    // GIVEN: user with firstname " rob " and lastname " BOB"
    final user = Profile(
      uid: '1',
      firstname: ' rob ',
      lastname: ' BOB',
      userItems: {},
      imageUrl: '',
      creationTime: DateTime.now(),
    );

    // WHEN: fullname is called
    final fullname = user.fullName;

    // THEN: fullname is "Rob Bob"
    expect(fullname, 'Rob Bob');
  });
}
