class Bird {
  double y;
  double velocity;

  Bird({required this.y, required this.velocity});
}

class Pipe {
  double x;
  double gapCenter;
  bool scored;

  Pipe({required this.x, required this.gapCenter, this.scored = false});
}

enum GamePhase { waiting, playing, gameOver }
