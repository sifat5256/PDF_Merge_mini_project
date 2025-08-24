import 'package:flutter/material.dart';


class BusinessCardScreen2 extends StatefulWidget {
  const BusinessCardScreen2({super.key});

  @override
  State<BusinessCardScreen2> createState() => _BusinessCardScreen2State();
}

class _BusinessCardScreen2State extends State<BusinessCardScreen2> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: Center(
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateZ(_isHovered ? 0.02 : 0),
            transformAlignment: Alignment.center,
            width: 350,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_isHovered ? 0.2 : 0.1),
                  blurRadius: _isHovered ? 30 : 20,
                  offset: Offset(0, _isHovered ? 15 : 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Diagonal background
                  CustomPaint(
                    size: const Size(350, 200),
                    painter: DiagonalPainter(),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        // Profile avatar with interactive rotation
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(_isHovered ? 3.14 : 0),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: const Color(0xFF2D5C7F),
                            child: CircleAvatar(
                              radius: 38,
                              backgroundImage: NetworkImage(
                                'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1887&q=80',
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 20),

                        // Contact information
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'SAMANTHA REYES',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2D5C7F),
                                  letterSpacing: 1.2,
                                ),
                              ),

                              const SizedBox(height: 4),

                              const Text(
                                'Senior Flutter Developer',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6C7A89),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  _buildSocialIcon(Icons.email, const Color(0xFF2D5C7F)),
                                  _buildSocialIcon(Icons.phone, const Color(0xFF5C8AB8)),
                                  _buildSocialIcon(Icons.link, const Color(0xFF9BB5D3)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Flutter logo in corner with animation
                  Positioned(
                    top: 16,
                    right: 16,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      transform: Matrix4.identity()
                        ..translate(_isHovered ? 0.0 : 40.0, _isHovered ? 0.0 : -40.0),
                      child: const FlutterLogo(
                        size: 24,
                        style: FlutterLogoStyle.markOnly,
                      ),
                    ),
                  ),

                  // QR code on hover
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _isHovered ? 1.0 : 0.0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.qr_code_2,
                          size: 24,
                          color: Color(0xFF2D5C7F),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
      ),
      child: Icon(
        icon,
        size: 16,
        color: color,
      ),
    );
  }
}

// Custom painter for the diagonal background
class DiagonalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2D5C7F), Color(0xFF5C8AB8), Color(0xFF9BB5D3)],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.6, 0)
      ..lineTo(0, size.height * 0.4)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}