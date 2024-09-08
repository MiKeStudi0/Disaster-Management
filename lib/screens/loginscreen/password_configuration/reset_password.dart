import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:disaster_management/features/authentication/controller/forget_password/forget_password_controller.dart';
import 'package:disaster_management/screens/loginscreen/loginscreen.dart';
import 'package:disaster_management/utils/constants/image_strings.dart';
import 'package:disaster_management/utils/constants/sizes.dart';
import 'package:disaster_management/utils/constants/text_strings.dart';
import 'package:disaster_management/utils/helpers/helper_functions.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key, required this.email});
final String email;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [IconButton(onPressed: ()=>Get.back(), icon: const Icon(Icons.clear))],
      ),
      body:  SingleChildScrollView(
        child: Padding(padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(children: [
  Image(
                  image: const AssetImage(TImages.deliveredEmailIllustration),
                  width: THelperFunctions.screenWidth() * 0.6,
                ),
                 const  SizedBox(height: TSizes.spaceBtwSections),
                Text(
                  email,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              const  SizedBox(height: TSizes.spaceBtwSections),
              
                Text(
                  TTexts.changeYourPasswordTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
               const SizedBox(height: TSizes.spaceBtwItems),
                
                  Text(
                 TTexts.changeYourPasswordSubTitle,
                  style: Theme.of(context).textTheme.labelMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                SizedBox( width: double.infinity, child: ElevatedButton( onPressed: ()=> Get.off(()=> const Loginscreen()), child: const Text( TTexts.done),),),
                const SizedBox(height: TSizes.spaceBtwItems),
                SizedBox( width: double.infinity, child: TextButton( onPressed: ()=> ForgetPasswordController.instance.resendPasswordRestEmail(email), child: const Text( TTexts.resendEmail),),),

        ],)),
      )
    );
  }
}