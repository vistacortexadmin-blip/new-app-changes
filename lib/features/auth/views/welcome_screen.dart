import 'package:flutter/material.dart';
import '../../../core/config/app_colors.dart';
import '../../../app.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        children: [
          // Background ambient wave glow
          Positioned.fill(
            child: CustomPaint(
              painter: _WaveGraphicPainter(),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // 1. Logo & Brand Mark
                  Center(
                    child: Column(
                      children: [
                        // Stylized "V" ribbon icon
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00C6FF), Color(0xFF0072FF), Color(0xFF6A11CB)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0072FF).withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.all_inclusive_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'VistaCortex',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Your Health. Smarter.',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 5),

                  // 2. Tagline
                  const Text(
                    'Understand Today.\nA Healthier Tomorrow.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 3. Get Started Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: AppColors.primary.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainNavigationShell(),
                          ),
                        );
                      },
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 4. Sign In Link
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainNavigationShell(),
                        ),
                      );
                    },
                    child: RichText(
                      text: const TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: 'Sign In',
                            style: TextStyle(
                              color: Color(0xFF60A5FA),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for the organic glowing electric blue wave seen on Screen 1
class _WaveGraphicPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    
    // Background gradient
    final bgPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0, -0.1),
        radius: 1.2,
        colors: [Color(0xFF0F1B38), Color(0xFF0A0F1D)],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    final path1 = Path();
    path1.moveTo(0, size.height * 0.45);
    path1.cubicTo(
      size.width * 0.25, size.height * 0.35,
      size.width * 0.45, size.height * 0.55,
      size.width * 0.85, size.height * 0.40,
    );
    path1.quadraticBezierTo(
      size.width, size.height * 0.35,
      size.width, size.height * 0.42,
    );

    final paint1 = Paint()
      ..color = const Color(0xFF00D2FF).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawPath(path1, paint1);

    final path2 = Path();
    path2.moveTo(0, size.height * 0.52);
    path2.cubicTo(
      size.width * 0.3, size.height * 0.62,
      size.width * 0.65, size.height * 0.38,
      size.width, size.height * 0.50,
    );

    final paint2 = Paint()
      ..color = const Color(0xFF3B82F6).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawPath(path2, paint2);

    final paint3 = Paint()
      ..color = const Color(0xFF60A5FA).withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path2, paint3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
