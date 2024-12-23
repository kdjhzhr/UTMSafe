import 'package:flutter/material.dart';

class SafetyBanner extends StatelessWidget {
  const SafetyBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150, // Height of the banner
      child: PageView(
        controller: PageController(viewportFraction: 0.9),
        children: [
          // Slide 1
          _buildBannerSlide(
            image: 'assets/banner1.png',
            text: 'Report incidents promptly to ensure campus safety!',
          ),
          // Slide 2
          _buildBannerSlide(
            image: 'assets/banner2.png',
            text: 'Stay updated with real-time safety alerts!',
          ),
          // Slide 3
          _buildBannerSlide(
            image: 'assets/banner3.png',
            text: 'Emergency contacts are just a click away!',
          ),
        ],
      ),
    );
  }

  Widget _buildBannerSlide({required String image, required String text}) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          image: AssetImage(image), // Replace with your safety-themed image
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.6),
              Colors.transparent,
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
