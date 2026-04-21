import 'package:flutter/material.dart';

import 'models.dart';

class GamePainter extends CustomPainter {
  GamePainter({
    required this.bird,
    required this.pipes,
    required this.pipeWidth,
    required this.pipeGap,
    required this.birdRadius,
    required this.birdX,
    required this.groundHeight,
    required this.bgOffset,
  });

  final Bird bird;
  final List<Pipe> pipes;
  final double pipeWidth;
  final double pipeGap;
  final double birdRadius;
  final double birdX;
  final double groundHeight;
  final double bgOffset;

  @override
  void paint(Canvas canvas, Size size) {
    _paintSky(canvas, size);
    _paintClouds(canvas, size);
    _paintPipes(canvas, size);
    _paintGround(canvas, size);
    _paintBird(canvas);
  }

  void _paintSky(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF4EC0CA), Color(0xFFA7E8EE)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  void _paintClouds(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.7);
    final seeds = [
      const Offset(60, 110),
      const Offset(220, 70),
      const Offset(360, 150),
      const Offset(500, 90),
    ];
    final loopWidth = size.width + 180;
    for (final seed in seeds) {
      final x = ((seed.dx - bgOffset * 0.25) % loopWidth) - 60;
      final y = seed.dy;
      canvas.drawCircle(Offset(x, y), 26, paint);
      canvas.drawCircle(Offset(x + 22, y - 10), 20, paint);
      canvas.drawCircle(Offset(x + 44, y), 24, paint);
    }
  }

  void _paintPipes(Canvas canvas, Size size) {
    final fieldBottom = size.height - groundHeight;
    final body = Paint()..color = const Color(0xFF5BB84C);
    final dark = Paint()..color = const Color(0xFF3E8A36);
    final light = Paint()..color = const Color(0xFF86D26F);

    for (final pipe in pipes) {
      final gapTop = pipe.gapCenter - pipeGap / 2;
      final gapBottom = pipe.gapCenter + pipeGap / 2;

      canvas.drawRect(
        Rect.fromLTWH(pipe.x, 0, pipeWidth, gapTop),
        body,
      );
      canvas.drawRect(
        Rect.fromLTWH(pipe.x + 4, 0, 6, gapTop),
        light,
      );
      canvas.drawRect(
        Rect.fromLTWH(pipe.x + pipeWidth - 10, 0, 6, gapTop),
        dark,
      );
      canvas.drawRect(
        Rect.fromLTWH(pipe.x - 4, gapTop - 24, pipeWidth + 8, 24),
        body,
      );
      canvas.drawRect(
        Rect.fromLTWH(pipe.x - 4, gapTop - 6, pipeWidth + 8, 6),
        dark,
      );

      canvas.drawRect(
        Rect.fromLTWH(pipe.x, gapBottom, pipeWidth, fieldBottom - gapBottom),
        body,
      );
      canvas.drawRect(
        Rect.fromLTWH(pipe.x + 4, gapBottom, 6, fieldBottom - gapBottom),
        light,
      );
      canvas.drawRect(
        Rect.fromLTWH(
          pipe.x + pipeWidth - 10,
          gapBottom,
          6,
          fieldBottom - gapBottom,
        ),
        dark,
      );
      canvas.drawRect(
        Rect.fromLTWH(pipe.x - 4, gapBottom, pipeWidth + 8, 24),
        body,
      );
      canvas.drawRect(
        Rect.fromLTWH(pipe.x - 4, gapBottom + 18, pipeWidth + 8, 6),
        dark,
      );
    }
  }

  void _paintGround(Canvas canvas, Size size) {
    final top = size.height - groundHeight;
    canvas.drawRect(
      Rect.fromLTWH(0, top, size.width, groundHeight),
      Paint()..color = const Color(0xFFE0D79A),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, top, size.width, 16),
      Paint()..color = const Color(0xFF7EC95F),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, top + 16, size.width, 6),
      Paint()..color = const Color(0xFF5FA643),
    );

    final stroke = Paint()
      ..color = const Color(0xFFB8A25E)
      ..strokeWidth = 3;
    const double spacing = 28;
    double x = -(bgOffset % spacing);
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, top + 38),
        Offset(x + 14, top + 38),
        stroke,
      );
      canvas.drawLine(
        Offset(x + 10, top + 58),
        Offset(x + 24, top + 58),
        stroke,
      );
      x += spacing;
    }
  }

  void _paintBird(Canvas canvas) {
    canvas.save();
    canvas.translate(birdX, bird.y);
    final rotation = (bird.velocity / 600).clamp(-0.5, 1.2);
    canvas.rotate(rotation);

    canvas.drawCircle(
      Offset.zero,
      birdRadius,
      Paint()..color = const Color(0xFFF7D046),
    );
    canvas.drawCircle(
      const Offset(2, 5),
      birdRadius * 0.62,
      Paint()..color = const Color(0xFFFBE89C),
    );

    final wing = Path()
      ..moveTo(-3, 2)
      ..quadraticBezierTo(-12, 10, -3, 13)
      ..quadraticBezierTo(7, 10, -3, 2)
      ..close();
    canvas.drawPath(wing, Paint()..color = const Color(0xFFE4B82E));

    canvas.drawCircle(
      const Offset(7, -5),
      5,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      const Offset(8.5, -5),
      2.5,
      Paint()..color = Colors.black,
    );

    final beak = Path()
      ..moveTo(10, -2)
      ..lineTo(23, 0)
      ..lineTo(10, 5)
      ..close();
    canvas.drawPath(beak, Paint()..color = const Color(0xFFEE8B2E));
    canvas.drawPath(
      beak,
      Paint()
        ..color = const Color(0xFFC26B17)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) => true;
}
