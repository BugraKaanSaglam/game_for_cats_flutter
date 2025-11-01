import 'package:flutter/foundation.dart';

class GameClicksCounter extends ChangeNotifier {
  int totalTaps = 0;
  int miceTaps = 0;
  int bugTaps = 0;

  void reset() {
    totalTaps = 0;
    bugTaps = 0;
    miceTaps = 0;
    notifyListeners();
  }

  void recordMiceTap() {
    miceTaps++;
    totalTaps++;
    notifyListeners();
  }

  void recordBugTap() {
    bugTaps++;
    totalTaps++;
    notifyListeners();
  }

  void recordMissTap() {
    totalTaps++;
    notifyListeners();
  }
}
