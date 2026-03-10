import 'package:client/core/components/custom_button.dart';
import 'package:client/core/components/screen_config.dart';
import 'package:client/features/chat/presentation/pages/chat_page.dart';
import 'package:client/features/chat/presentation/widgets/basic_features.dart';
import 'package:client/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = AppTheme.darkTheme.textTheme;

    return SafeArea(
      child: Scaffold(
        body: Container(
          // color: Colors.brown,
          width: ScreenConfig.screenWidth,
          height: ScreenConfig.screenHeight,
          padding: EdgeInsets.symmetric(
            horizontal: ScreenConfig.screenWidth * 0.09,
            vertical: 60,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to \nPrompta',
                    style: TextStyle(
                      fontSize: textTheme.headlineLarge?.fontSize ?? 30,
                      fontWeight:
                          textTheme.headlineLarge?.fontWeight ??
                          FontWeight.w900,
                      color: textTheme.headlineLarge?.color ?? Colors.white,
                    ),
                  ),
                  Lottie.asset(
                    "animations/infinity_loading.json",
                    width: ScreenConfig.screenWidth * 0.2,
                    repeat: true,
                    animate: true,
                    frameRate: FrameRate(120),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Text(
                'This official app is free,syncs your history across devices and brings \nyou the best experience.',
                style: TextStyle(
                  fontSize: textTheme.bodyLarge?.fontSize ?? 30,
                  fontWeight:
                      textTheme.bodyLarge?.fontWeight ?? FontWeight.w900,
                  color: textTheme.bodyLarge?.color ?? Colors.white,
                ),
              ),
              SizedBox(height: 20),
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
