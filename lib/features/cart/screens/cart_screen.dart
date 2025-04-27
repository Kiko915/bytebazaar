import 'package:bytebazaar/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:bytebazaar/common/widgets/b_feedback.dart';
import 'package:bytebazaar/utils/constants/sizes.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder for cart items logic. Assume empty for now.
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
                          BTexts.cartTitle,
                          style: const TextStyle(
                            fontFamily: 'BebasNeue',
                            color: Colors.white,
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        // TODO: Implement edit mode logic
                        BFeedback.show(
                          context,
                          title: 'Edit Mode',
                          message: 'You can now select and edit cart items (placeholder).',
                          type: BFeedbackType.info,
                          position: BFeedbackPosition.top
                        );
                      },
                      child: const Icon(Icons.edit, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isEmpty ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Lottie.asset(
                              'assets/lottie/empty-cart.json',
                              width: MediaQuery.of(context).size.width * 0.6,
                            ),
                            const SizedBox(height: BSizes.spaceBtwItems),
                            Text(
                              BTexts.cartEmpty,
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : const Center(
                        child: Text("Cart Items Here"), // Placeholder for actual list
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
