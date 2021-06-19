import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatelessWidget {
  final OverlayEntry? overlayEntry;
  static const routeName = '/Onboarding';

  OnboardingPage(this.overlayEntry, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
            title: 'Deals indicator',
            body:
                'Search for desired books or authors, the right indicator shows the number of deals for a certain book. Orange indicates there are few books left, light green there are some book and dark green there are many books left.',
            image: Image.asset(
              'assets/images/onboard1.png',
              height: 280,
            )),
        PageViewModel(
            title: 'Fast message',
            body:
                'In the deals section you can send messages to people, Pro tip: long press the message button to send a fast message from the same page.',
            image: Image.asset(
              'assets/images/onboard2.png',
              height: 280,
            )),
        PageViewModel(
            title: 'Chat options',
            body:
                'In the chat page you can send locations and photos to easily communicate with each other you can also see if the other person in online or not. shapes designed by starline / Freepik',
            image: Image.asset(
              'assets/images/onboard3.png',
              height: 280,
            )),
      ],
      showSkipButton: true,
      skip: const Text('Skip'),
      next: const Text('Next'),
      done: const Text('Done'),
      onDone: () async {
        // When done button is press
        final sharedPreferences = await SharedPreferences.getInstance();
        await sharedPreferences.setBool('ONBOARD', false);
        overlayEntry!.remove();
      },
      dotsDecorator: DotsDecorator(
          size: const Size.square(10.0),
          activeSize: const Size(20.0, 10.0),
          activeColor: Theme.of(context).backgroundColor,
          color: Colors.black26,
          spacing: const EdgeInsets.symmetric(horizontal: 3.0),
          activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0))),
    );
  }
}
