import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as p;
import 'package:railtime/model/arrival_model.dart';
import 'package:railtime/model/repository/database_repository.dart';
import 'package:railtime/model/services/trip_service.dart';
import 'package:railtime/model/station_model.dart';
import 'package:railtime/model/trip_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'tfl_api_service_test.mocks.dart';

void main() {
  late MockClient mockHttpClient;
  late DatabaseRepository repository;
  late TripService tripService;

  setUp(() {
    mockHttpClient = MockClient();
    repository = DatabaseRepository();
    databaseFactory = databaseFactoryFfi;
    final testDbPath = p.join(Directory.current.path, 'assets', 'timetable.db');
    repository.setTestDatabasePath(testDbPath);
    tripService = TripService(httpClient: mockHttpClient);
  });

  tearDown(() async {
    final db = await repository.database;
    await db.close();
  });

  group('getTrip Tests', () {
    test('getTrip same number of scheduled and expected arrivals', () async {
      StationModel currentStation =
          (await repository.getStationById('910GEMRSPKH'))!;
      StationModel destination =
          (await repository.getStationById('910GUPMNSTR'))!;
      ArrivalModel targetArrival = ArrivalModel(
        '',
        currentStation.lines.firstWhere((x) => x.id == 'liberty'),
        '1',
        0,
        destination,
        '',
        DateTime(2025, 10, 17, 6, 16),
        DateTime(2025, 10, 17, 6, 16),
      );

      when(
        mockHttpClient.get(
          Uri.parse('https://api.tfl.gov.uk/Vehicle/lib-0/Arrivals'),
        ),
      ).thenAnswer(
        (_) async => http.Response('''
    [
      {
        "\$type": "Tfl.Api.Presentation.Entities.Prediction, Tfl.Api.Presentation.Entities",
        "id": "123",
        "operationType": 1,
        "vehicleId": "lib-0",
        "naptanId": "910GROMFORD",
        "stationName": "Romford Rail Station",
        "lineId": "liberty",
        "lineName": "Liberty",
        "platformName": "Platform 1",
        "bearing": "",
        "destinationNaptanId": "910GUPMNSTR",
        "destinationName": "Upminster Rail Station",
        "timestamp": "2025-10-11T17:06:26.0540841Z",
        "timeToStation": 43,
        "currentLocation": "Approaching Paddington",
        "towards": "Upminster",
        "expectedArrival": "2025-10-17T06:11:00Z",
        "timeToLive": "2025-10-11T17:07:09Z",
        "modeName": "overground",
        "timing": {
          "\$type": "Tfl.Api.Presentation.Entities.PredictionTiming, Tfl.Api.Presentation.Entities",
          "countdownServerAdjustment": "00:00:00",
          "source": "0001-01-01T00:00:00",
          "insert": "0001-01-01T00:00:00",
          "read": "2025-10-11T17:06:40.218Z",
          "sent": "2025-10-11T17:06:26Z",
          "received": "0001-01-01T00:00:00"
        }
      },
      {
        "\$type": "Tfl.Api.Presentation.Entities.Prediction, Tfl.Api.Presentation.Entities",
        "id": "123",
        "operationType": 1,
        "vehicleId": "lib-0",
        "naptanId": "910GEMRSPKH",
        "stationName": "Romford Rail Station",
        "lineId": "liberty",
        "lineName": "Liberty",
        "platformName": "Platform 2",
        "bearing": "",
        "destinationNaptanId": "910GUPMNSTR",
        "destinationName": "Upminster Rail Station",
        "timestamp": "2025-10-11T17:06:26.0540841Z",
        "timeToStation": 43,
        "currentLocation": "Approaching Paddington",
        "towards": "Upminster",
        "expectedArrival": "2025-10-17T06:17:00Z",
        "timeToLive": "2025-10-11T17:07:09Z",
        "modeName": "overground",
        "timing": {
          "\$type": "Tfl.Api.Presentation.Entities.PredictionTiming, Tfl.Api.Presentation.Entities",
          "countdownServerAdjustment": "00:00:00",
          "source": "0001-01-01T00:00:00",
          "insert": "0001-01-01T00:00:00",
          "read": "2025-10-11T17:06:40.218Z",
          "sent": "2025-10-11T17:06:26Z",
          "received": "0001-01-01T00:00:00"
        }
      },
      {
        "\$type": "Tfl.Api.Presentation.Entities.Prediction, Tfl.Api.Presentation.Entities",
        "id": "123",
        "operationType": 1,
        "vehicleId": "lib-0",
        "naptanId": "910GUPMNSTR",
        "stationName": "Romford Rail Station",
        "lineId": "liberty",
        "lineName": "Liberty",
        "platformName": "Platform 3",
        "bearing": "",
        "destinationNaptanId": "910GUPMNSTR",
        "destinationName": "Upminster Rail Station",
        "timestamp": "2025-10-11T17:06:26.0540841Z",
        "timeToStation": 43,
        "currentLocation": "Approaching Paddington",
        "towards": "Upminster",
        "expectedArrival": "2025-10-17T06:25:00Z",
        "timeToLive": "2025-10-11T17:07:09Z",
        "modeName": "overground",
        "timing": {
          "\$type": "Tfl.Api.Presentation.Entities.PredictionTiming, Tfl.Api.Presentation.Entities",
          "countdownServerAdjustment": "00:00:00",
          "source": "0001-01-01T00:00:00",
          "insert": "0001-01-01T00:00:00",
          "read": "2025-10-11T17:06:40.218Z",
          "sent": "2025-10-11T17:06:26Z",
          "received": "0001-01-01T00:00:00"
        }
      }
    ]
    ''', 200),
      );

      TripModel? trip = await tripService.getTrip(
        currentStation,
        targetArrival,
        'lib-0',
      );
      expect(trip!.id, 'lib-0');
      expect(trip.line.id, 'liberty');
      expect(trip.origin.id, '910GROMFORD');
      expect(trip.destination.id, '910GUPMNSTR');
      expect(trip.arrivals.length, 3);
      expect(trip.arrivals.first.platform, '1');
      expect(trip.arrivals.first.actual, 22260);
      expect(trip.arrivals.first.scheduled, 22260);
      expect(trip.arrivals[1].station.id, '910GEMRSPKH');
      expect(trip.arrivals[1].platform, '2');
      expect(trip.arrivals[1].actual, 22620);
      expect(trip.arrivals[1].scheduled, 22560);
      expect(trip.arrivals[2].platform, '3');
      expect(trip.arrivals[2].actual, 23100);
      expect(trip.arrivals[2].scheduled, 22860);
    });

    test('getTrip no starting expected arrivals', () async {
      StationModel currentStation =
          (await repository.getStationById('910GEMRSPKH'))!;
      StationModel destination =
          (await repository.getStationById('910GUPMNSTR'))!;
      ArrivalModel targetArrival = ArrivalModel(
        '',
        currentStation.lines.firstWhere((x) => x.id == 'liberty'),
        '1',
        0,
        destination,
        '',
        DateTime(2025, 10, 17, 6, 16),
        DateTime(2025, 10, 17, 6, 16),
      );

      when(
        mockHttpClient.get(
          Uri.parse('https://api.tfl.gov.uk/Vehicle/lib-0/Arrivals'),
        ),
      ).thenAnswer(
        (_) async => http.Response('''
    [
      {
        "\$type": "Tfl.Api.Presentation.Entities.Prediction, Tfl.Api.Presentation.Entities",
        "id": "123",
        "operationType": 1,
        "vehicleId": "lib-0",
        "naptanId": "910GEMRSPKH",
        "stationName": "Romford Rail Station",
        "lineId": "liberty",
        "lineName": "Liberty",
        "platformName": "Platform 2",
        "bearing": "",
        "destinationNaptanId": "910GUPMNSTR",
        "destinationName": "Upminster Rail Station",
        "timestamp": "2025-10-11T17:06:26.0540841Z",
        "timeToStation": 43,
        "currentLocation": "Approaching Paddington",
        "towards": "Upminster",
        "expectedArrival": "2025-10-17T06:17:00Z",
        "timeToLive": "2025-10-11T17:07:09Z",
        "modeName": "overground",
        "timing": {
          "\$type": "Tfl.Api.Presentation.Entities.PredictionTiming, Tfl.Api.Presentation.Entities",
          "countdownServerAdjustment": "00:00:00",
          "source": "0001-01-01T00:00:00",
          "insert": "0001-01-01T00:00:00",
          "read": "2025-10-11T17:06:40.218Z",
          "sent": "2025-10-11T17:06:26Z",
          "received": "0001-01-01T00:00:00"
        }
      },
      {
        "\$type": "Tfl.Api.Presentation.Entities.Prediction, Tfl.Api.Presentation.Entities",
        "id": "123",
        "operationType": 1,
        "vehicleId": "lib-0",
        "naptanId": "910GUPMNSTR",
        "stationName": "Romford Rail Station",
        "lineId": "liberty",
        "lineName": "Liberty",
        "platformName": "Platform 3",
        "bearing": "",
        "destinationNaptanId": "910GUPMNSTR",
        "destinationName": "Upminster Rail Station",
        "timestamp": "2025-10-11T17:06:26.0540841Z",
        "timeToStation": 43,
        "currentLocation": "Approaching Paddington",
        "towards": "Upminster",
        "expectedArrival": "2025-10-17T06:25:00Z",
        "timeToLive": "2025-10-11T17:07:09Z",
        "modeName": "overground",
        "timing": {
          "\$type": "Tfl.Api.Presentation.Entities.PredictionTiming, Tfl.Api.Presentation.Entities",
          "countdownServerAdjustment": "00:00:00",
          "source": "0001-01-01T00:00:00",
          "insert": "0001-01-01T00:00:00",
          "read": "2025-10-11T17:06:40.218Z",
          "sent": "2025-10-11T17:06:26Z",
          "received": "0001-01-01T00:00:00"
        }
      }
    ]
    ''', 200),
      );

      TripModel? trip = await tripService.getTrip(
        currentStation,
        targetArrival,
        'lib-0',
      );

      expect(trip!.id, 'lib-0');
      expect(trip.line.id, 'liberty');
      expect(trip.origin.id, '910GROMFORD');
      expect(trip.destination.id, '910GUPMNSTR');
      expect(trip.arrivals.length, 3);
      expect(trip.arrivals.first.platform, null);
      expect(trip.arrivals.first.actual, null);
      expect(trip.arrivals.first.scheduled, 22260);
      expect(trip.arrivals.first.isDeparted, true);
      expect(trip.arrivals[1].station.id, '910GEMRSPKH');
      expect(trip.arrivals[1].platform, '2');
      expect(trip.arrivals[1].actual, 22620);
      expect(trip.arrivals[1].scheduled, 22560);
      expect(trip.arrivals[1].isDeparted, false);
      expect(trip.arrivals[2].platform, '3');
      expect(trip.arrivals[2].actual, 23100);
      expect(trip.arrivals[2].scheduled, 22860);
      expect(trip.arrivals[2].isDeparted, false);
    });

    test('getTrip no starting with one non-stopping station', () async {
      StationModel currentStation =
          (await repository.getStationById('910GEMRSPKH'))!;
      StationModel destination =
          (await repository.getStationById('910GUPMNSTR'))!;
      ArrivalModel targetArrival = ArrivalModel(
        '',
        currentStation.lines.firstWhere((x) => x.id == 'liberty'),
        '1',
        0,
        destination,
        '',
        DateTime(2025, 10, 17, 6, 16),
        DateTime(2025, 10, 17, 6, 16),
      );

      when(
        mockHttpClient.get(
          Uri.parse('https://api.tfl.gov.uk/Vehicle/lib-0/Arrivals'),
        ),
      ).thenAnswer(
        (_) async => http.Response('''
    [
      {
        "\$type": "Tfl.Api.Presentation.Entities.Prediction, Tfl.Api.Presentation.Entities",
        "id": "123",
        "operationType": 1,
        "vehicleId": "lib-0",
        "naptanId": "910GROMFORD",
        "stationName": "Romford Rail Station",
        "lineId": "liberty",
        "lineName": "Liberty",
        "platformName": "Platform 1",
        "bearing": "",
        "destinationNaptanId": "910GUPMNSTR",
        "destinationName": "Upminster Rail Station",
        "timestamp": "2025-10-11T17:06:26.0540841Z",
        "timeToStation": 43,
        "currentLocation": "Approaching Paddington",
        "towards": "Upminster",
        "expectedArrival": "2025-10-17T06:17:00Z",
        "timeToLive": "2025-10-11T17:07:09Z",
        "modeName": "overground",
        "timing": {
          "\$type": "Tfl.Api.Presentation.Entities.PredictionTiming, Tfl.Api.Presentation.Entities",
          "countdownServerAdjustment": "00:00:00",
          "source": "0001-01-01T00:00:00",
          "insert": "0001-01-01T00:00:00",
          "read": "2025-10-11T17:06:40.218Z",
          "sent": "2025-10-11T17:06:26Z",
          "received": "0001-01-01T00:00:00"
        }
      },
      {
        "\$type": "Tfl.Api.Presentation.Entities.Prediction, Tfl.Api.Presentation.Entities",
        "id": "123",
        "operationType": 1,
        "vehicleId": "lib-0",
        "naptanId": "910GUPMNSTR",
        "stationName": "Romford Rail Station",
        "lineId": "liberty",
        "lineName": "Liberty",
        "platformName": "Platform 3",
        "bearing": "",
        "destinationNaptanId": "910GUPMNSTR",
        "destinationName": "Upminster Rail Station",
        "timestamp": "2025-10-11T17:06:26.0540841Z",
        "timeToStation": 43,
        "currentLocation": "Approaching Paddington",
        "towards": "Upminster",
        "expectedArrival": "2025-10-17T06:25:00Z",
        "timeToLive": "2025-10-11T17:07:09Z",
        "modeName": "overground",
        "timing": {
          "\$type": "Tfl.Api.Presentation.Entities.PredictionTiming, Tfl.Api.Presentation.Entities",
          "countdownServerAdjustment": "00:00:00",
          "source": "0001-01-01T00:00:00",
          "insert": "0001-01-01T00:00:00",
          "read": "2025-10-11T17:06:40.218Z",
          "sent": "2025-10-11T17:06:26Z",
          "received": "0001-01-01T00:00:00"
        }
      }
    ]
    ''', 200),
      );

      TripModel? trip = await tripService.getTrip(
        currentStation,
        targetArrival,
        'lib-0',
      );

      expect(trip!.id, 'lib-0');
      expect(trip.line.id, 'liberty');
      expect(trip.origin.id, '910GROMFORD');
      expect(trip.destination.id, '910GUPMNSTR');
      expect(trip.arrivals.length, 3);
      expect(trip.arrivals.first.platform, '1');
      expect(trip.arrivals.first.actual, 22620);
      expect(trip.arrivals.first.scheduled, 22260);
      expect(trip.arrivals.first.isDeparted, false);
      expect(trip.arrivals.first.isStopping, true);
      expect(trip.arrivals[1].station.id, '910GEMRSPKH');
      expect(trip.arrivals[1].platform, null);
      expect(trip.arrivals[1].actual, null);
      expect(trip.arrivals[1].scheduled, 22560);
      expect(trip.arrivals[1].isDeparted, false);
      expect(trip.arrivals[1].isStopping, false);
      expect(trip.arrivals[2].platform, '3');
      expect(trip.arrivals[2].actual, 23100);
      expect(trip.arrivals[2].scheduled, 22860);
      expect(trip.arrivals[2].isDeparted, false);
      expect(trip.arrivals[2].isStopping, true);
    });

    test('getTrip no starting with one extra station', () async {
      StationModel currentStation =
          (await repository.getStationById('910GEMRSPKH'))!;
      StationModel destination =
          (await repository.getStationById('910GUPMNSTR'))!;
      ArrivalModel targetArrival = ArrivalModel(
        '',
        currentStation.lines.firstWhere((x) => x.id == 'liberty'),
        '1',
        0,
        destination,
        '',
        DateTime(2025, 10, 17, 6, 16),
        DateTime(2025, 10, 17, 6, 16),
      );

      when(
        mockHttpClient.get(
          Uri.parse('https://api.tfl.gov.uk/Vehicle/lib-0/Arrivals'),
        ),
      ).thenAnswer(
        (_) async => http.Response('''
    [
      {
        "\$type": "Tfl.Api.Presentation.Entities.Prediction, Tfl.Api.Presentation.Entities",
        "id": "123",
        "operationType": 1,
        "vehicleId": "lib-0",
        "naptanId": "910GROMFORD",
        "stationName": "Romford Rail Station",
        "lineId": "liberty",
        "lineName": "Liberty",
        "platformName": "Platform 1",
        "bearing": "",
        "destinationNaptanId": "910GUPMNSTR",
        "destinationName": "Upminster Rail Station",
        "timestamp": "2025-10-11T17:06:26.0540841Z",
        "timeToStation": 43,
        "currentLocation": "Approaching Paddington",
        "towards": "Upminster",
        "expectedArrival": "2025-10-17T06:17:00Z",
        "timeToLive": "2025-10-11T17:07:09Z",
        "modeName": "overground",
        "timing": {
          "\$type": "Tfl.Api.Presentation.Entities.PredictionTiming, Tfl.Api.Presentation.Entities",
          "countdownServerAdjustment": "00:00:00",
          "source": "0001-01-01T00:00:00",
          "insert": "0001-01-01T00:00:00",
          "read": "2025-10-11T17:06:40.218Z",
          "sent": "2025-10-11T17:06:26Z",
          "received": "0001-01-01T00:00:00"
        }
      },
      {
        "\$type": "Tfl.Api.Presentation.Entities.Prediction, Tfl.Api.Presentation.Entities",
        "id": "123",
        "operationType": 1,
        "vehicleId": "lib-0",
        "naptanId": "910GPADTON",
        "stationName": "Romford Rail Station",
        "lineId": "liberty",
        "lineName": "Liberty",
        "platformName": "Platform 2",
        "bearing": "",
        "destinationNaptanId": "910GUPMNSTR",
        "destinationName": "Upminster Rail Station",
        "timestamp": "2025-10-11T17:06:26.0540841Z",
        "timeToStation": 43,
        "currentLocation": "Approaching Paddington",
        "towards": "Upminster",
        "expectedArrival": "2025-10-17T06:20:00Z",
        "timeToLive": "2025-10-11T17:07:09Z",
        "modeName": "overground",
        "timing": {
          "\$type": "Tfl.Api.Presentation.Entities.PredictionTiming, Tfl.Api.Presentation.Entities",
          "countdownServerAdjustment": "00:00:00",
          "source": "0001-01-01T00:00:00",
          "insert": "0001-01-01T00:00:00",
          "read": "2025-10-11T17:06:40.218Z",
          "sent": "2025-10-11T17:06:26Z",
          "received": "0001-01-01T00:00:00"
        }
      },
      {
        "\$type": "Tfl.Api.Presentation.Entities.Prediction, Tfl.Api.Presentation.Entities",
        "id": "123",
        "operationType": 1,
        "vehicleId": "lib-0",
        "naptanId": "910GUPMNSTR",
        "stationName": "Romford Rail Station",
        "lineId": "liberty",
        "lineName": "Liberty",
        "platformName": "Platform 3",
        "bearing": "",
        "destinationNaptanId": "910GUPMNSTR",
        "destinationName": "Upminster Rail Station",
        "timestamp": "2025-10-11T17:06:26.0540841Z",
        "timeToStation": 43,
        "currentLocation": "Approaching Paddington",
        "towards": "Upminster",
        "expectedArrival": "2025-10-17T06:25:00Z",
        "timeToLive": "2025-10-11T17:07:09Z",
        "modeName": "overground",
        "timing": {
          "\$type": "Tfl.Api.Presentation.Entities.PredictionTiming, Tfl.Api.Presentation.Entities",
          "countdownServerAdjustment": "00:00:00",
          "source": "0001-01-01T00:00:00",
          "insert": "0001-01-01T00:00:00",
          "read": "2025-10-11T17:06:40.218Z",
          "sent": "2025-10-11T17:06:26Z",
          "received": "0001-01-01T00:00:00"
        }
      }
    ]
    ''', 200),
      );

      TripModel? trip = await tripService.getTrip(
        currentStation,
        targetArrival,
        'lib-0',
      );

      expect(trip!.id, 'lib-0');
      expect(trip.line.id, 'liberty');
      expect(trip.origin.id, '910GROMFORD');
      expect(trip.destination.id, '910GUPMNSTR');
      expect(trip.arrivals.length, 4);
      expect(trip.arrivals.first.platform, '1');
      expect(trip.arrivals.first.station.id, '910GROMFORD');
      expect(trip.arrivals.first.actual, 22620);
      expect(trip.arrivals.first.scheduled, 22260);
      expect(trip.arrivals.first.isDeparted, false);
      expect(trip.arrivals.first.isStopping, true);
      expect(trip.arrivals[1].station.id, '910GEMRSPKH');
      expect(trip.arrivals[1].platform, null);
      expect(trip.arrivals[1].actual, null);
      expect(trip.arrivals[1].scheduled, 22560);
      expect(trip.arrivals[1].isDeparted, false);
      expect(trip.arrivals[1].isStopping, false);
      expect(trip.arrivals[2].platform, '2');
      expect(trip.arrivals[2].station.id, '910GPADTON');
      expect(trip.arrivals[2].actual, 22800);
      expect(trip.arrivals[2].scheduled, null);
      expect(trip.arrivals[2].isDeparted, false);
      expect(trip.arrivals[2].isStopping, true);
      expect(trip.arrivals[3].platform, '3');
      expect(trip.arrivals[3].actual, 23100);
      expect(trip.arrivals[3].scheduled, 22860);
      expect(trip.arrivals[3].isDeparted, false);
      expect(trip.arrivals[3].isStopping, true);
      expect(trip.arrivals[3].station.id, '910GUPMNSTR');
    });
  });
}
