import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  static Future<void> logSignUp(String name, String email) async {
    await _analytics.logEvent(
      name: 'user_signup',
      parameters: {'user_name': name, 'user_email': email},
    );
  }

  static Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

//////////
  static Future<void> logCustomEvent(String eventName, Map<String, Object> params) async {
  await _analytics.logEvent(name: eventName, parameters: params);
}
}
