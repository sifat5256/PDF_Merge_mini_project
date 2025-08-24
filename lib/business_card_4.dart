import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';



class ParallaxBusinessCard extends StatefulWidget {
  const ParallaxBusinessCard({super.key});

  @override
  State<ParallaxBusinessCard> createState() => _ParallaxBusinessCardState();
}

class _ParallaxBusinessCardState extends State<ParallaxBusinessCard> {
  double xOffset = 0;
  double yOffset = 0;
  double tiltFactor = 0.03;
  List<double>? accelerometerValues;

  @override
  void initState() {
    super.initState();
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        accelerometerValues = [event.x, event.y, event.z];
        xOffset = event.y * tiltFactor;
        yOffset = event.x * tiltFactor;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A14),
      body: Center(
        child: Stack(
          children: [
            // Background elements with parallax effect
            Positioned(
              top: 150 + yOffset * 10,
              left: 50 + xOffset * 8,
              child: Transform(
                transform: Matrix4.identity()
                  ..translate(xOffset * 15, yOffset * 15)
                  ..rotateZ(xOffset * 0.1),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFF6B6B).withOpacity(0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 100 - yOffset * 10,
              right: 70 - xOffset * 8,
              child: Transform(
                transform: Matrix4.identity()
                  ..translate(-xOffset * 12, -yOffset * 12)
                  ..rotateZ(-xOffset * 0.1),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF4ECDC4).withOpacity(0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Main card with 3D effect
            Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(yOffset * 0.5)
                ..rotateY(xOffset * 0.5),
              alignment: Alignment.center,
              child: Container(
                width: 320,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: const Color(0xFF1A1A2E),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: Offset(10 + xOffset * 10, 10 + yOffset * 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Card background pattern
                    _buildCardPattern(),

                    // Card content
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Transform(
                                transform: Matrix4.identity()
                                  ..translate(xOffset * 5, yOffset * 5),
                                child: const Text(
                                  'OLIVER MARTINEZ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                              Transform(
                                transform: Matrix4.identity()
                                  ..translate(-xOffset * 5, -yOffset * 5),
                                child: const FlutterLogo(
                                  size: 32,
                                  style: FlutterLogoStyle.markOnly,
                                ),
                              ),
                            ],
                          ),

                          Transform(
                            transform: Matrix4.identity()
                              ..translate(xOffset * 3, yOffset * 3),
                            child: Text(
                              'Creative Developer',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.7),
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),

                          const Spacer(),

                          Transform(
                            transform: Matrix4.identity()
                              ..translate(-xOffset * 4, -yOffset * 4),
                            child: Row(
                              children: [
                                _buildInfoItem(
                                  Icons.email,
                                  'oliver@creativedev.io',
                                  xOffset,
                                  yOffset,
                                ),
                                const SizedBox(width: 20),
                                _buildInfoItem(
                                  Icons.phone,
                                  '+1 (555) 123-7890',
                                  xOffset,
                                  yOffset,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          Transform(
                            transform: Matrix4.identity()
                              ..translate(xOffset * 4, yOffset * 4),
                            child: Row(
                              children: [
                                _buildInfoItem(
                                  Icons.location_on,
                                  'New York, NY',
                                  xOffset,
                                  yOffset,
                                ),
                                const SizedBox(width: 20),
                                _buildInfoItem(
                                  Icons.link,
                                  'creativedev.io',
                                  xOffset,
                                  yOffset,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Floating elements with stronger parallax
            Positioned(
              top: 120 - yOffset * 20,
              left: 40 - xOffset * 15,
              child: Transform(
                transform: Matrix4.identity()
                  ..translate(xOffset * 25, yOffset * 25)
                  ..rotateZ(xOffset * 0.5),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFF6B6B).withOpacity(0.2),
                    border: Border.all(
                      color: const Color(0xFFFF6B6B).withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 130 + yOffset * 20,
              right: 40 + xOffset * 15,
              child: Transform(
                transform: Matrix4.identity()
                  ..translate(-xOffset * 25, -yOffset * 25)
                  ..rotateZ(-xOffset * 0.5),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF4ECDC4).withOpacity(0.2),
                    border: Border.all(
                      color: const Color(0xFF4ECDC4).withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),

            // Instructions
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: (xOffset.abs() + yOffset.abs()) > 0.1 ? 0 : 1,
                child: const Text(
                  'Tilt your device to explore',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPattern() {
    return Transform(
      transform: Matrix4.identity()..rotateZ(pi / 4),
      child: Opacity(
        opacity: 0.05,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFF6B6B),
                Color(0xFF4ECDC4),
                Color(0xFF5562E2),
              ],
              stops: [0.2, 0.5, 0.8],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, double xOffset, double yOffset) {
    return Expanded(
      child: Transform(
        transform: Matrix4.identity()
          ..translate(xOffset * 2, yOffset * 2),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: const Color(0xFF4ECDC4),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}