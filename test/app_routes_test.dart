import 'package:flutter_test/flutter_test.dart';
import 'package:okouran/core/routes/app_routes.dart';
import 'package:okouran/features/notifications/domain/app_alert.dart';

void main() {
  group('routeForAlert', () {
    test('maps credit alerts to their detail routes', () {
      expect(routeForAlert(AlertType.lowCredit), AppRoutes.alertLow);
      expect(routeForAlert(AlertType.criticalCredit), AppRoutes.alertCritical);
      expect(
        routeForAlert(AlertType.imminentCutoff),
        AppRoutes.alertCritical,
      );
    });

    test('maps informational alerts to their corresponding screens', () {
      expect(routeForAlert(AlertType.anomaly), AppRoutes.anomaly);
      expect(routeForAlert(AlertType.rechargeConfirmed), AppRoutes.history);
      expect(routeForAlert(AlertType.tip), AppRoutes.tips);
    });
  });
}
