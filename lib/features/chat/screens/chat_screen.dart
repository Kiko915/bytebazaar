import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:bytebazaar/utils/constants/text_strings.dart';
import 'package:bytebazaar/utils/constants/sizes.dart';
import 'package:bytebazaar/utils/helpers/helper_functions.dart';
import 'package:bytebazaar/utils/constants/colors.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = BHelperFunctions.isDarkMode(context);
    // Placeholder for chat messages logic. Assume empty for now.
    final bool isEmpty = true;

    return Scaffold(
      appBar: null,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [Color(0xFF4285F4), Color(0xFFEEF7FE)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          BTexts.chatTitle,
                          style: const TextStyle(
                            fontFamily: 'BebasNeue',
                            color: BColors.white,
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    // Optionally add actions here in the future
                  ],
                ),
              ),
              Expanded(
                child: isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Lottie.asset(
                              'assets/lottie/no-messages.json',
                              width: BHelperFunctions.screenWidth() * 0.6,
                            ),
                            const SizedBox(height: BSizes.spaceBtwItems),
                            Text(
                              BTexts.chatEmpty,
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: BSizes.spaceBtwSections),
                          ],
                        ),
                      )
                    : const Center(
                        child: Text("Chat Messages Here"),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
