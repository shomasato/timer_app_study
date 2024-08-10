import 'dart:async';

class ActiveTimer {
  final String tid;
  int totalCount;
  bool isCounting;
  late Timer timer;

  ActiveTimer({
    required this.tid,
    required this.totalCount,
    this.isCounting = true,
  });
}
