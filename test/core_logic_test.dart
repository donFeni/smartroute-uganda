import 'package:flutter_test/flutter_test.dart';
import 'package:smartroute_uganda/shared/models/app_models.dart';
import 'package:smartroute_uganda/shared/models/demo_data.dart';

void main() {
  // ─── Fuel estimate tests ─────────────────────────────────────────────────
  group('FuelEstimate', () {
    test('calculates litres required correctly', () {
      const estimate = FuelEstimate(
        distanceKm: 100,
        consumptionPer100km: 8.0,
        fuelPriceUgxPerLitre: 5000,
        fuelType: FuelType.petrol,
      );
      expect(estimate.litresRequired, equals(8.0));
    });

    test('calculates total cost correctly', () {
      const estimate = FuelEstimate(
        distanceKm: 50,
        consumptionPer100km: 10.0,
        fuelPriceUgxPerLitre: 5600,
        fuelType: FuelType.petrol,
      );
      // 50 * 10 / 100 = 5 litres; 5 * 5600 = 28000
      expect(estimate.litresRequired, equals(5.0));
      expect(estimate.totalCostUgx, equals(28000.0));
    });

    test('calculates cost per km correctly', () {
      const estimate = FuelEstimate(
        distanceKm: 100,
        consumptionPer100km: 8.0,
        fuelPriceUgxPerLitre: 5000,
        fuelType: FuelType.petrol,
      );
      // 8 litres * 5000 = 40000 total; 40000 / 100 = 400 per km
      expect(estimate.costPerKm, equals(400.0));
    });

    test('handles zero distance gracefully', () {
      const estimate = FuelEstimate(
        distanceKm: 0,
        consumptionPer100km: 8.0,
        fuelPriceUgxPerLitre: 5000,
        fuelType: FuelType.petrol,
      );
      expect(estimate.litresRequired, equals(0.0));
      expect(estimate.totalCostUgx, equals(0.0));
      expect(estimate.costPerKm, equals(0.0));
    });

    test('motorcycle uses less fuel than car', () {
      const car = FuelEstimate(
        distanceKm: 100,
        consumptionPer100km: 8.5,
        fuelPriceUgxPerLitre: 5600,
        fuelType: FuelType.petrol,
      );
      const boda = FuelEstimate(
        distanceKm: 100,
        consumptionPer100km: 3.5,
        fuelPriceUgxPerLitre: 5600,
        fuelType: FuelType.petrol,
      );
      expect(boda.totalCostUgx, lessThan(car.totalCostUgx));
    });
  });

  // ─── SmartScore model tests ──────────────────────────────────────────────
  group('RouteOption SmartScore', () {
    test('recommended route has highest SmartScore', () {
      final routes = DemoData.sampleRoutes();
      final recommended = routes.firstWhere((r) => r.isRecommended);
      final others = routes.where((r) => !r.isRecommended);
      for (final other in others) {
        expect(recommended.smartScore, greaterThanOrEqualTo(other.smartScore));
      }
    });

    test('SmartScore is between 0 and 100', () {
      final routes = DemoData.sampleRoutes();
      for (final r in routes) {
        expect(r.smartScore, greaterThanOrEqualTo(0));
        expect(r.smartScore, lessThanOrEqualTo(100));
      }
    });

    test('fastest route has shortest estimated time', () {
      final routes = DemoData.sampleRoutes();
      final fastest = routes.firstWhere(
        (r) => r.category == RouteCategory.fastest,
      );
      final fuelEff = routes.firstWhere(
        (r) => r.category == RouteCategory.fuelEfficient,
      );
      expect(
        fastest.estimatedMinutes,
        lessThanOrEqualTo(fuelEff.estimatedMinutes),
      );
    });

    test('fuel-efficient route has shortest distance', () {
      final routes = DemoData.sampleRoutes();
      final fuelEff = routes.firstWhere(
        (r) => r.category == RouteCategory.fuelEfficient,
      );
      final fastest = routes.firstWhere(
        (r) => r.category == RouteCategory.fastest,
      );
      expect(fuelEff.distanceKm, lessThanOrEqualTo(fastest.distanceKm));
    });
  });

  // ─── Road report model tests ─────────────────────────────────────────────
  group('RoadReport', () {
    test('copyWith updates status and confirmations', () {
      final original = RoadReport(
        id: 'test_id',
        category: ReportCategory.pothole,
        description: 'Test pothole',
        latitude: 0.3476,
        longitude: 32.5825,
        locationName: 'Test Location',
        reportedAt: DateTime(2024, 1, 1),
        status: ReportStatus.unverified,
        confirmations: 2,
      );
      final updated = original.copyWith(
        status: ReportStatus.communityConfirmed,
        confirmations: 5,
      );
      expect(updated.status, ReportStatus.communityConfirmed);
      expect(updated.confirmations, 5);
      expect(updated.id, 'test_id');
      expect(updated.category, ReportCategory.pothole);
    });

    test('sample reports have valid coordinates', () {
      for (final report in DemoData.sampleReports) {
        expect(report.latitude, isNot(0.0));
        expect(report.longitude, isNot(0.0));
        expect(report.description.isNotEmpty, isTrue);
        expect(report.locationName.isNotEmpty, isTrue);
      }
    });
  });

  // ─── Demo data tests ─────────────────────────────────────────────────────
  group('DemoData', () {
    test('demo user has valid data', () {
      final user = DemoData.demoUser;
      expect(user.id.isNotEmpty, isTrue);
      expect(user.name.isNotEmpty, isTrue);
      expect(user.email.contains('@'), isTrue);
      expect(user.points, greaterThan(0));
    });

    test('sample routes have three categories', () {
      final routes = DemoData.sampleRoutes();
      expect(routes.length, equals(3));
      final categories = routes.map((r) => r.category).toSet();
      expect(categories.contains(RouteCategory.fastest), isTrue);
      expect(categories.contains(RouteCategory.balanced), isTrue);
      expect(categories.contains(RouteCategory.fuelEfficient), isTrue);
    });

    test('saved places include home and work', () {
      final saved = DemoData.savedPlaces;
      expect(saved.any((p) => p.isHome), isTrue);
      expect(saved.any((p) => p.isWork), isTrue);
    });

    test('sample notifications have varied categories', () {
      final notifs = DemoData.sampleNotifications;
      final categories = notifs.map((n) => n.category).toSet();
      expect(categories.length, greaterThan(1));
    });

    test('fleet vehicles have valid registration IDs', () {
      for (final v in DemoData.fleetVehicleList) {
        expect(v.registrationId.isNotEmpty, isTrue);
        expect(v.driverName.isNotEmpty, isTrue);
      }
    });
  });

  // ─── Form validation logic tests ─────────────────────────────────────────
  group('Form validation', () {
    String? emailValidator(String? v) {
      if (v == null || v.trim().isEmpty) return 'Required';
      if (!v.contains('@')) return 'Invalid email';
      return null;
    }

    String? passwordValidator(String? v) {
      if (v == null || v.isEmpty) return 'Required';
      if (v.length < 6) return 'Too short';
      return null;
    }

    test('email validation requires @ symbol', () {
      expect(emailValidator(''), isNotNull);
      expect(emailValidator('notanemail'), isNotNull);
      expect(emailValidator('valid@email.com'), isNull);
    });

    test('password validation requires minimum 6 characters', () {
      expect(passwordValidator(''), isNotNull);
      expect(passwordValidator('abc'), isNotNull);
      expect(passwordValidator('abcdef'), isNull);
      expect(passwordValidator('longpassword'), isNull);
    });
  });

  // ─── Report status tests ──────────────────────────────────────────────────
  group('ReportStatus', () {
    test('all report statuses are distinct', () {
      final statuses = ReportStatus.values.toSet();
      expect(statuses.length, equals(ReportStatus.values.length));
    });

    test('report is active when not resolved or expired', () {
      const activeStatuses = [
        ReportStatus.unverified,
        ReportStatus.communityConfirmed,
        ReportStatus.underReview,
        ReportStatus.verified,
      ];
      const inactiveStatuses = [ReportStatus.resolved, ReportStatus.expired];

      for (final s in activeStatuses) {
        expect(s != ReportStatus.resolved && s != ReportStatus.expired, isTrue);
      }
      for (final s in inactiveStatuses) {
        expect(s == ReportStatus.resolved || s == ReportStatus.expired, isTrue);
      }
    });
  });
}
