import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatelessWidget {
  final OverlayEntry? overlayEntry;

  OnboardingPage(this.overlayEntry, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
            title: 'Find you curriculum',
            body:
                'Search for desired books or authors, see how many deals are available and follow books to get notifications when new deals arrive.',
            image: Image.asset(
              'assets/images/book_lover.png',
              height: 240,
            )),
        PageViewModel(
            title: 'Send fast message',
            body: 'In the deals section you can send messages to people, Pro tip: long press the message button to send a fast message from the same page.',
            // bodyWidget: RichText(
            //     text: TextSpan(
            //         style: Theme.of(context).textTheme.bodyText1,
            //         children: [
            //       TextSpan(
            //           text:
            //               'In the deals section you can send messages to people, '),
            //       TextSpan(
            //           text: 'Pro tip: ',
            //           style: TextStyle(fontWeight: FontWeight.bold)),
            //       TextSpan(
            //           text:
            //               'long press the message button to send a fast message from the same page.'),
            //     ])),
            image: Image.asset(
              'assets/images/message_sent.png',
            )),
        PageViewModel(
            title: 'Share your location',
            body:
                'In the chat you can send your location or select a spesific location, to meetup and easily communicate ',
            image: Image.asset(
              'assets/images/my_location.png',
              height: 250,
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
