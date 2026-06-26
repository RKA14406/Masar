import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:screen_protector/screen_protector.dart';

class QuizScreenSecurityService with WidgetsBindingObserver {
  int _appSwitchFlags = 0;
  bool _isMonitoringLifecycle = false;
  bool _isOutsideApp = false;

  int get appSwitchFlags => _appSwitchFlags;
  bool get integrityPassed => _appSwitchFlags == 0;

  Future<void> startProtectedQuizSession() async {
    _appSwitchFlags = 0;
    _isOutsideApp = false;

    if (!_isMonitoringLifecycle) {
      WidgetsBinding.instance.addObserver(this);
      _isMonitoringLifecycle = true;
    }

    await enableExamProtection();
  }

  Future<void> stopProtectedQuizSession() async {
    if (_isMonitoringLifecycle) {
      WidgetsBinding.instance.removeObserver(this);
      _isMonitoringLifecycle = false;
    }

    _isOutsideApp = false;
    await disableExamProtection();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isMonitoringLifecycle) return;

    final leftQuizApp =
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached;

    if (leftQuizApp) {
      if (!_isOutsideApp) {
        _appSwitchFlags += 1;
        _isOutsideApp = true;
      }
      return;
    }

    if (state == AppLifecycleState.resumed) {
      _isOutsideApp = false;
    }
  }

  Future<void> enableExamProtection() async {
    try {
      await ScreenProtector.preventScreenshotOn();
    } catch (_) {}

    try {
      await ScreenProtector.protectDataLeakageOn();
    } catch (_) {}

    debugPrint('🔒 Screenshot protection enabled');
  }

  Future<void> disableExamProtection() async {
    try {
      await ScreenProtector.preventScreenshotOff();
    } catch (_) {}

    try {
      await ScreenProtector.protectDataLeakageOff();
    } catch (_) {}

    debugPrint('🔓 Screenshot protection disabled');
  }
}