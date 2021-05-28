import 'package:flutter_test/flutter_test.dart';
import 'package:leaf/profile/models/profile.dart';

void main() {
  test(
      'Given user with firstname " rob " and lastname " BOB" When fullname is called Then fullname is "Rob Bob"',
      () async {
    // ARRANGE
    final user = Profile(
      uid: '1',
      firstname: ' rob ',
      lastname: ' BOB',
      userItems: {},
      imageUrl: '',
      creationTime: DateTime.now(),
    );

    // ACT
    final fullname = user.fullName;

    // ASSERT
    expect(fullname, 'Rob Bob');
  });
}
