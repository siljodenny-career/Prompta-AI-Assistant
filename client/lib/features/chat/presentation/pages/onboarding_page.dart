import 'package:client/core/components/custom_button.dart';
import 'package:client/core/components/screen_config.dart';
import 'package:client/features/chat/presentation/pages/chat_page.dart';
import 'package:client/features/chat/presentation/widgets/basic_features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          // color: Colors.brown,
          width: ScreenConfig.screenWidth,
          height: ScreenConfig.screenHeight,
          padding: EdgeInsets.symmetric(
            horizontal: ScreenConfig.screenWidth * 0.09,
            vertical: ScreenConfig.screenWidth * 0.05,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome to \nPrompta',
                        style: GoogleFonts.raleway(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 30,),
                      SvgPicture.asset(
                        'assets/images/prompt_icon.svg',
                        width: 60,
                      ),
                    ],
                  ),
                  Text(
                    'This official app is free,syncs your history across devices and brings you the best experience.',
                    style: GoogleFonts.raleway(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    BasicFeatures(
                      icon: 'assets/images/icons8-binoculars.svg',
                      title: 'Prompta can be inaccurate',
                      description:
                          'Prompta may provide inaccurate information about people, places, or facts.',
                    ),
                    BasicFeatures(
                      icon: 'assets/images/icons8-lock.svg',
                      title: "Don't share sensitive info",
                      description:
                          'Chats may be reviewed to improve our systems, so don\'t share sensitive info.',
                    ),
                    BasicFeatures(
                      icon: 'assets/images/icons8-settings.svg',
                      title: 'Control your chat history',
                      description:
                          'Decide whether new chats on this device will appear in your history and be used to improve our systems.',
                    ),
                  ],
                ),
              ),
              Center(
                child: CustomButton(
                  text: 'Get Started',
                  icon: Icons.arrow_forward,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChatPage()),
                    );
                    print('button pressed');
                  },
                  // padding: EdgeInsets.symmetric(
                  //   horizontal: size.width * 0.28,

                  // ),
                  padding: EdgeInsets.only(
                    left: ScreenConfig.screenWidth * 0.25,
                    right: ScreenConfig.screenWidth * 0.25,
                  ),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
