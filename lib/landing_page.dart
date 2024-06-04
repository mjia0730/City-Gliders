import 'package:flutter/material.dart';
import 'chat_screen.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            double fontSize = constraints.maxWidth * 0.06; // Adjust the multiplier as needed
                            return Text(
                              "Welcome to UltiBot Flick's chatbot!",
                              style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0060A6)
                              ),
                              textAlign: TextAlign.center,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ChatScreen()),
                          );
                        },
                        child: Image.asset(
                          'assets/button_image.webp',
                          width: 200,  // Adjust the width and height as needed
                          height: 100,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
                child: Text(
                  "UltiBot Flick is an AI-powered chatbot that leverages a Mixture of Experts (MOEs) transformer model to generate responses. It is designed to answer any questions related to ultimate frisbee rules. It’s available 24/7 on your smartphone, making it a convenient resource for new and experienced players alike.",
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color(0xFF0060A6)
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
