import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:leaf/localization/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatelessWidget {
  final OverlayEntry? overlayEntry;

  OnboardingPage(this.overlayEntry, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = Localization.of(context);
    return IntroductionScreen(
      pages: [
        PageViewModel(
            title: loc.getTranslatedValue('onboarding_page1_title'),
            body: loc.getTranslatedValue('onboarding_page1_body'),
            image: Image.asset(
              'assets/images/book_lover.png',
              height: 240,
            )),
        PageViewModel(
            title: loc.getTranslatedValue('onboarding_page2_title'),
            body: loc.getTranslatedValue('onboarding_page2_body'),
            image: Image.asset(
              'assets/images/add_deal.png',
              height: 240,
            )),
        PageViewModel(
            title: loc.getTranslatedValue('onboarding_page3_title'),
            body: loc.getTranslatedValue('onboarding_page3_body'),
            image: Image.asset(
              'assets/images/meditate.png',
              height: 250,
            )),
        PageViewModel(
            title: loc.getTranslatedValue('onboarding_page4_title'),
            body: loc.getTranslatedValue('onboarding_page4_body'),
            image: Image.asset(
              'assets/images/support.png',
              height: 250,
            )),
        PageViewModel(
            title: loc.getTranslatedValue('onboarding_page5_title'),
            body: loc.getTranslatedValue('onboarding_page5_body'),
            image: Image.asset(
              'assets/images/done.png',
              height: 250,
            )),        
      ],
      showSkipButton: true,
      skip: Text(loc.getTranslatedValue('skip_btn_txt')),
      next: Text(loc.getTranslatedValue('next_btn_txt')),
      done: Text(loc.getTranslatedValue('done_btn_txt')),
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
