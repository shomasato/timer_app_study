String timerString(int c) {
  if (c >= 3600) {
    int a = (c ~/ 3600);
    int t = c - (3600 * a);
    final h = (c ~/ 3600).toString();
    final m = (t ~/ 60).toString().padLeft(2, '0');
    final s = (t % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  } else {
    final m = (c ~/ 60).toString().padLeft(2, '0');
    final s = (c % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}