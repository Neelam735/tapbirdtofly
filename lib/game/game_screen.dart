import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'game_painter.dart';
import 'models.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  static const double gravity = 1600;
  static const double jumpVelocity = -460;
  static const double pipeSpeed = 190;
  static const double pipeGap = 190;
  static const double pipeWidth = 72;
  static const double pipeSpacing = 260;
  static const double birdRadius = 18;
  static const double groundHeight = 90;
  static const double birdXFactor = 0.28;

  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;
  final Random _rng = Random();

  Size _size = Size.zero;
  GamePhase _phase = GamePhase.waiting;

  Bird _bird = Bird(y: 0, velocity: 0);
  final List<Pipe> _pipes = [];
  int _score = 0;
  int _best = 0;
  double _bgOffset = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _resetForWaiting() {
    _bird = Bird(y: _size.height / 2, velocity: 0);
    _pipes.clear();
    _score = 0;
    final startX = _size.width + 80;
    for (int i = 0; i < 3; i++) {
      _pipes.add(_makePipe(startX + i * pipeSpacing));
    }
    _phase = GamePhase.waiting;
  }

  Pipe _makePipe(double x) {
    final fieldHeight = _size.height - groundHeight;
    final minCenter = pipeGap / 2 + 60;
    final maxCenter = fieldHeight - pipeGap / 2 - 40;
    final gapCenter = minCenter + _rng.nextDouble() * (maxCenter - minCenter);
    return Pipe(x: x, gapCenter: gapCenter);
  }

  void _handleTap() {
    switch (_phase) {
      case GamePhase.waiting:
        _phase = GamePhase.playing;
        _bird.velocity = jumpVelocity;
      case GamePhase.playing:
        _bird.velocity = jumpVelocity;
      case GamePhase.gameOver:
        setState(_resetForWaiting);
    }
  }

  void _onTick(Duration elapsed) {
    if (_size == Size.zero) return;
    final double rawDt = _lastTick == Duration.zero
        ? 0
        : (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    final double dt = rawDt > 0.05 ? 0.05 : rawDt;

    switch (_phase) {
      case GamePhase.waiting:
        _bgOffset = (_bgOffset + pipeSpeed * dt * 0.3) % _size.width;
        _bird.y = _size.height / 2 +
            sin(elapsed.inMilliseconds / 220.0) * 10;
      case GamePhase.playing:
        _bird.velocity += gravity * dt;
        _bird.y += _bird.velocity * dt;
        _bgOffset = (_bgOffset + pipeSpeed * dt) % _size.width;

        final birdX = _size.width * birdXFactor;
        for (final pipe in _pipes) {
          pipe.x -= pipeSpeed * dt;
          if (!pipe.scored && pipe.x + pipeWidth < birdX) {
            pipe.scored = true;
            _score++;
          }
        }
        _pipes.removeWhere((p) => p.x + pipeWidth < -20);
        if (_pipes.isEmpty ||
            _pipes.last.x < _size.width - pipeSpacing) {
          final lastX = _pipes.isEmpty
              ? _size.width + 80
              : _pipes.last.x + pipeSpacing;
          _pipes.add(_makePipe(lastX));
        }
        if (_hasCollision()) {
          _phase = GamePhase.gameOver;
          if (_score > _best) _best = _score;
        }
      case GamePhase.gameOver:
        _bird.velocity += gravity * dt;
        _bird.y += _bird.velocity * dt;
        final maxY = _size.height - groundHeight - birdRadius;
        if (_bird.y > maxY) {
          _bird.y = maxY;
          _bird.velocity = 0;
        }
    }

    setState(() {});
  }

  bool _hasCollision() {
    final birdX = _size.width * birdXFactor;
    final birdY = _bird.y;

    if (birdY + birdRadius >= _size.height - groundHeight) return true;
    if (birdY - birdRadius <= 0) return true;

    for (final pipe in _pipes) {
      final left = pipe.x;
      final right = pipe.x + pipeWidth;
      if (birdX + birdRadius < left || birdX - birdRadius > right) continue;
      final gapTop = pipe.gapCenter - pipeGap / 2;
      final gapBottom = pipe.gapCenter + pipeGap / 2;
      if (birdY - birdRadius < gapTop || birdY + birdRadius > gapBottom) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final newSize = Size(constraints.maxWidth, constraints.maxHeight);
          if (newSize != _size) {
            _size = newSize;
            if (_phase == GamePhase.waiting && _pipes.isEmpty) {
              _resetForWaiting();
            }
          }
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _handleTap,
            child: Stack(
              children: [
                CustomPaint(
                  size: newSize,
                  painter: GamePainter(
                    bird: _bird,
                    pipes: _pipes,
                    pipeWidth: pipeWidth,
                    pipeGap: pipeGap,
                    birdRadius: birdRadius,
                    birdX: newSize.width * birdXFactor,
                    groundHeight: groundHeight,
                    bgOffset: _bgOffset,
                  ),
                ),
                SafeArea(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Text(
                        '$_score',
                        style: const TextStyle(
                          fontSize: 68,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(3, 3),
                              blurRadius: 0,
                              color: Color(0xAA000000),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (_phase == GamePhase.waiting)
                  const _Overlay(
                    title: 'Tap Bird to Fly',
                    subtitle: 'Tap anywhere to start',
                  ),
                if (_phase == GamePhase.gameOver)
                  _Overlay(
                    title: 'Game Over',
                    subtitle: 'Score: $_score    Best: $_best\nTap to play again',
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Overlay extends StatelessWidget {
  const _Overlay({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.55),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
