
import 'package:flutter/material.dart';
import 'homepage.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomPaint(
              painter: TextCurvePainter(),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  'Step into the sweet world of Cookielicious!',
                  style: GoogleFonts.roboto(
                    fontSize: 32, 
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[800], 
                  ),
                ),
              ),
            ),
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.5, end: 1.2),
              duration: const Duration(seconds: 2),
              curve: Curves.elasticOut,
              builder: (context, double scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: Image.asset(
                'asset/image/cookies logo.png',
                height: 250,
                width: 250,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TextCurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.lineTo(0, size.height / 2);
    path.quadraticBezierTo(size.width / 4, size.height, size.width / 2, size.height);
    path.quadraticBezierTo(3 * size.width / 4, size.height, size.width, size.height / 2);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}