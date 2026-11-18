import 'package:flutter_test/flutter_test.dart';

import 'package:smartroute_uganda/features/map/domain/map_location.dart';
import 'package:smartroute_uganda/features/map/presentation/controllers/map_state_controller.dart';
import 'package:smartroute_uganda/shared/models/app_models.dart';
import 'package:smartroute_uganda/shared/models/demo_data.dart';

/// Tests for road report → map marker data flow.
/// Verifies the critical bug fix: reports submitted via CreateReportScreen
/// must appear as visible map markers in MapStateController.
void main() {
  group('MapStateController — road report markers', () {
    late MapStateController mapCtrl;

    setUp(() {
      mapCtrl = MapStateController(
        geocodingRepository: null,
      );
    });

    tearDown(() {
      mapCtrl.dispose();
    });

    test('loadReportMarkers produces one marker per report', () {
      final reports = DemoData.sampleReports;
      mapCtrl.loadReportMarkers(reports);

      // All reports are active in sampleReports (none resolved/expired).
      final reportMarkerCount = mapCtrl.markers
          .where((m) => _isReportMarkerType(m.type))
          .length;
      expect(reportMarkerCount, equals(reports.length));
    });

    test('loadReportMarkers maps categories to correct marker types', () {
      final reports = [
        RoadReport(
          id: 'test_pothole',
          category: ReportCategory.pothole,
          description: 'Test pothole',
          latitude: 0.3476,
          longitude: 32.5825,
          locationName: 'Test Location',
          reportedAt: DateTime.now(),
          status: ReportStatus.unverified,
        ),
        RoadReport(
          id: 'test_flooding',
          category: ReportCategory.flooding,
          description: 'Test flooding',
          latitude: 0.3500,
          longitude: 32.5900,
          locationName: 'Flood Point',
          reportedAt: DateTime.now(),
          status: ReportStatus.unverified,
        ),
        RoadReport(
          id: 'test_accident',
          category: ReportCategory.accident,
          description: 'Test accident',
          latitude: 0.3600,
          longitude: 32.6000,
          locationName: 'Accident Point',
          reportedAt: DateTime.now(),
          status: ReportStatus.unverified,
        ),
      ];

      mapCtrl.loadReportMarkers(reports);

      final markers = mapCtrl.markers;
      final pothole = markers.firstWhere((m) => m.id == 'test_pothole');
      final flooding = markers.firstWhere((m) => m.id == 'test_flooding');
      final accident = markers.firstWhere((m) => m.id == 'test_accident');

      expect(pothole.type, equals(MapMarkerType.pothole));
      expect(flooding.type, equals(MapMarkerType.flooding));
      expect(accident.type, equals(MapMarkerType.accident));
    });

    test('report markers have correct payload (report ID) for navigation', () {
      const reportId = 'rr_nav_test';
      mapCtrl.loadReportMarkers([
        RoadReport(
          id: reportId,
          category: ReportCategory.roadworks,
          description: 'Test roadworks',
          latitude: 0.3476,
          longitude: 32.5825,
          locationName: 'Test Location',
          reportedAt: DateTime.now(),
          status: ReportStatus.unverified,
        ),
      ]);

      final marker = mapCtrl.markers.firstWhere((m) => m.id == reportId);
      expect(marker.payload, equals(reportId));
    });

    test('report markers have valid non-zero coordinates', () {
      mapCtrl.loadReportMarkers(DemoData.sampleReports);
      final reportMarkers =
          mapCtrl.markers.where((m) => _isReportMarkerType(m.type));

      for (final m in reportMarkers) {
        expect(m.location.latitude, isNot(0.0),
            reason: '${m.id} should have non-zero latitude');
        expect(m.location.longitude, isNot(0.0),
            reason: '${m.id} should have non-zero longitude');
      }
    });

    test('addReport then loadReportMarkers shows new report on map', () {
      // Simulate the flow from CreateReportScreen:
      // 1. Provider adds report
      // 2. SmartRouteMap re-builds and calls loadReportMarkers

      final newReport = RoadReport(
        id: 'new_report_uuid',
        category: ReportCategory.closure,
        description: 'Road blocked due to flooding',
        latitude: 0.3740,
        longitude: 32.6850,
        locationName: 'Bweyogerere Road',
        reportedAt: DateTime.now(),
        status: ReportStatus.unverified,
      );

      // Start with existing reports, then add the new one.
      final reports = [...DemoData.sampleReports, newReport];
      mapCtrl.loadReportMarkers(reports);

      final newMarker = mapCtrl.markers.firstWhere(
        (m) => m.id == 'new_report_uuid',
        orElse: () => throw StateError('New report marker not found on map'),
      );
      expect(newMarker.type, equals(MapMarkerType.closure));
      expect(newMarker.location.latitude, closeTo(0.3740, 0.0001));
    });

    test('visibleMarkers excludes report markers when showReportMarkers is false', () {
      mapCtrl.loadReportMarkers(DemoData.sampleReports);

      // All markers visible by default.
      expect(mapCtrl.visibleMarkers.isNotEmpty, isTrue);

      // Hide report markers.
      mapCtrl.toggleReportMarkers();

      final visibleReportMarkers = mapCtrl.visibleMarkers
          .where((m) => _isReportMarkerType(m.type));
      expect(visibleReportMarkers.isEmpty, isTrue);
    });

    test('selectMarker sets selectedMarker correctly', () {
      mapCtrl.loadReportMarkers(DemoData.sampleReports);
      final first = mapCtrl.markers.first;

      mapCtrl.selectMarker(first);
      expect(mapCtrl.selectedMarker, equals(first));

      mapCtrl.selectMarker(null);
      expect(mapCtrl.selectedMarker, isNull);
    });

    test('reloading markers clears and replaces previous report markers', () {
      mapCtrl.loadReportMarkers(DemoData.sampleReports);
      final initialCount = mapCtrl.markers
          .where((m) => _isReportMarkerType(m.type))
          .length;
      expect(initialCount, greaterThan(0));

      // Reload with single report — count must reflect new state.
      mapCtrl.loadReportMarkers([DemoData.sampleReports.first]);
      final reloadedCount = mapCtrl.markers
          .where((m) => _isReportMarkerType(m.type))
          .length;
      expect(reloadedCount, equals(1));
    });
  });

  group('RoadReport model', () {
    test('all sample reports have valid non-zero coordinates', () {
      for (final report in DemoData.sampleReports) {
        expect(report.latitude, isNot(0.0));
        expect(report.longitude, isNot(0.0));
        expect(report.latitude, inInclusiveRange(-90.0, 90.0));
        expect(report.longitude, inInclusiveRange(-180.0, 180.0));
      }
    });
  });
}

bool _isReportMarkerType(MapMarkerType t) {
  return t == MapMarkerType.pothole ||
      t == MapMarkerType.flooding ||
      t == MapMarkerType.accident ||
      t == MapMarkerType.roadworks ||
      t == MapMarkerType.closure ||
      t == MapMarkerType.congestion ||
      t == MapMarkerType.hazard;
}
