import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:disaster_management/features/authentication/onboarding.controller/onboarding_controller.dart';
import 'package:disaster_management/utils/constants/colors.dart';
import 'package:disaster_management/utils/constants/sizes.dart';
import 'package:disaster_management/utils/constants/text_strings.dart';
import 'package:disaster_management/utils/device/device_utility.dart';
import 'package:disaster_management/utils/helpers/helper_functions.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: const [
              OnBoardingPage(
                  image: 'Assets2/Images/on_boarding_images/onbord.jpg',
                  title: TTexts.onBoardingTitle1,
                  subTitle: TTexts.onBoardingSubTitle1),
              OnBoardingPage(
                  image: 'Assets2/Images/content/onbord2.png',
                  title: TTexts.onBoardingTitle2,
                  subTitle: TTexts.onBoardingSubTitle2),
              OnBoardingPage(
                  image: 'Assets2/Images/content/onbord3.png',
                  title: TTexts.onBoardingTitle3,
                  subTitle: TTexts.onBoardingSubTitle3)
            ],
          ),
          const onBoardSkip(),
          const OnBoardingDotNavigaton(),
          const OnBoardingNextButton()
        ],
      ),
    );
  }
}

class OnBoardingNextButton extends StatelessWidget {
  const OnBoardingNextButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Positioned(
      right: TSizes.defaultSpace,
      bottom: TDeviceUtils.getBottomNavigationBarHeight(),
      child: ElevatedButton(
        onPressed: () => OnboardingController.instance.nextPage(),
        style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: dark ? TColors.primary : TColors.dark),
        child: const Icon(Iconsax.arrow_right_3),
      ),
    );
  }
}

class OnBoardingDotNavigaton extends StatelessWidget {
  const OnBoardingDotNavigaton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = OnboardingController.instance;
    final dark = THelperFunctions.isDarkMode(context);
    return Positioned(
      bottom: TDeviceUtils.getBottomNavigationBarHeight() + 20,
      left: TSizes.defaultSpace,
      child: SmoothPageIndicator(
        controller: controller.pageController,
        onDotClicked: controller.dotNavigationClick,
        count: 3,
        effect: ExpandingDotsEffect(
          activeDotColor: dark ? TColors.light : TColors.dark,
          dotHeight: 6,
        ),
      ),
    );
  }
}

class onBoardSkip extends StatelessWidget {
  const onBoardSkip({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: TDeviceUtils.getAppBarHeight(),
      right: TSizes.defaultSpace,
      child: TextButton(
        onPressed: () => OnboardingController.instance.skipPage(),
        child: const Text('Skip'),
      ),
    );
  }
}

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.subTitle,
  });

  final String image, title, subTitle;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: Column(
        children: [
         
          Padding(
            padding: const EdgeInsets.only(top: 80.0),
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
           Image(
            fit: BoxFit.contain,
            width: THelperFunctions.screenWidth() * 1,
            height: THelperFunctions.screenHeight() * 0.6,
            image: AssetImage(
              image,
            ),
          ),
    SizedBox(height: 15),
          Text(
            subTitle,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.left,
          )
        ],
      ),
    );
  }
}
