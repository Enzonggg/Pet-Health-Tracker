import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneFrame extends StatelessWidget {
  final Widget child;

  const PhoneFrame({super.key, required this.child});

  // Helper method to get the current time in HH:MM format
  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen size
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    final height = screenSize.height; // Calculate phone dimensions
    // Make phone frame larger for better visibility and user experience
    final phoneWidth = width > 500 ? 380.0 : width * 0.95;
    final phoneHeight = height > 800 ? 760.0 : height * 0.95;
    final bezelWidth = phoneWidth * 0.04;

    return Center(
      child: Container(
        width: phoneWidth,
        height: phoneHeight,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(128),
              spreadRadius: 5,
              blurRadius: 15,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Phone frame
            Container(
              margin: EdgeInsets.all(bezelWidth),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  children: [
                    // OS Status Bar
                    Container(
                      height: 24,
                      color: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Time
                          Text(
                            _getCurrentTime(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Right Icons
                          Row(
                            children: const [
                              Icon(
                                Icons.network_cell,
                                color: Colors.white,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.wifi, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Icon(
                                Icons.battery_full,
                                color: Colors.white,
                                size: 14,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Main content
                    Expanded(child: child),
                  ],
                ),
              ),
            ),

            // Status bar notch
            Positioned(
              top: bezelWidth / 2,
              left: 0,
              right: 0,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Notch background
                    Container(
                      width: phoneWidth * 0.3,
                      height: bezelWidth * 1.5,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(bezelWidth),
                      ),
                    ),
                    // Status icons
                    SizedBox(
                      width: phoneWidth * 0.25,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Camera dot
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          // Speaker
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          // Light sensor
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Home indicator
            Positioned(
              bottom: bezelWidth / 2,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    // Provide haptic feedback for a more realistic feel
                    HapticFeedback.lightImpact();
                    // We could navigate to home screen here if needed
                  },
                  child: Container(
                    width: phoneWidth * 0.3,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(204),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
            ),

            // Volume buttons
            Positioned(
              top: phoneHeight * 0.15,
              left: 0,
              child: Container(
                width: bezelWidth / 2,
                height: phoneHeight * 0.06,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(bezelWidth / 4),
                  ),
                ),
              ),
            ),
            Positioned(
              top: phoneHeight * 0.23,
              left: 0,
              child: Container(
                width: bezelWidth / 2,
                height: phoneHeight * 0.06,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(bezelWidth / 4),
                  ),
                ),
              ),
            ),

            // Power button
            Positioned(
              top: phoneHeight * 0.15,
              right: 0,
              child: Container(
                width: bezelWidth / 2,
                height: phoneHeight * 0.08,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(bezelWidth / 4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
