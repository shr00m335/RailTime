import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as p;
import 'package:railtime/model/repository/database_repository.dart';
import 'package:railtime/model/services/station_service.dart';
import 'package:railtime/model/services/tfl_api_service.dart';
import 'package:railtime/model/station_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import './tfl_api_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late MockClient mockHttpClient;
  late DatabaseRepository repository;
  late StationService stationService;
  late TflApiService tflApiService;

  setUp(() {
    mockHttpClient = MockClient();
    repository = DatabaseRepository();
    databaseFactory = databaseFactoryFfi;
    final testDbPath = p.join(Directory.current.path, 'assets', 'timetable.db');
    repository.setTestDatabasePath(testDbPath);
    stationService = StationService();
    tflApiService = TflApiService(httpClient: mockHttpClient);
  });

  tearDown(() async {
    final db = await repository.database;
    await db.close();
  });

  group('TflApiService.getArrivals Tests', () {
    test('Test a non-hub station', () async {
      final StationModel station =
          (await stationService.getStations(['940GZZLUEMB']))['940GZZLUEMB']!;
      when(
        mockHttpClient.get(
          Uri.parse('https://api.tfl.gov.uk/StopPoint/940GZZLUEMB/Arrivals'),
        ),
      ).thenAnswer(
        (_) async => http.Response('''
  [{
    "\$type": "Tfl.Api.Presentation.Entities.Prediction, Tfl.Api.Presentation.Entities",
    "id": "2109950102",
    "operationType": 1,
    "vehicleId": "201",
    "naptanId": "940GZZLUEMB",
    "stationName": "Embankment Underground Station",
    "lineId": "bakerloo",
    "lineName": "Bakerloo",
    "platformName": "Northbound - Platform 5",
    "direction": "outbound",
    "bearing": "",
    "destinationNaptanId": "940GZZLUHAW",
    "destinationName": "Harrow & Wealdstone Underground Station",
    "timestamp": "2025-10-10T13:52:23.161951Z",
    "timeToStation": 206,
    "currentLocation": "Approaching Lambeth North",
    "towards": "Harrow and Wealdstone",
    "expectedArrival": "2025-10-10T13:55:49Z",
    "timeToLive": "2025-10-10T13:55:49Z",
    "modeName": "tube",
    "timing": {
      "\$type": "Tfl.Api.Presentation.Entities.PredictionTiming, Tfl.Api.Presentation.Entities",
      "countdownServerAdjustment": "00:00:00",
      "source": "0001-01-01T00:00:00",
      "insert": "0001-01-01T00:00:00",
      "read": "2025-10-10T13:52:23.496Z",
      "sent": "2025-10-10T13:52:23Z",
      "received": "0001-01-01T00:00:00"
    }
  },
  {
    "\$type": "Tfl.Api.Presentation.Entities.Prediction, Tfl.Api.Presentation.Entities",
    "id": "676825927",
    "operationType": 1,
    "vehicleId": "002",
    "naptanId": "940GZZLUEMB",
    "stationName": "Embankment Underground Station",
    "lineId": "district",
    "lineName": "District",
    "platformName": "Eastbound - Platform 2",
    "direction": "outbound",
    "bearing": "",
    "destinationNaptanId": "940GZZLUUPM",
    "destinationName": "Upminster Underground Station",
    "timestamp": "2025-10-10T13:52:23.161951Z",
    "timeToStation": 596,
    "currentLocation": "At Gloucester Road Platform 3",
    "towards": "Upminster",
    "expectedArrival": "2025-10-10T14:02:19Z",
    "timeToLive": "2025-10-10T14:02:19Z",
    "modeName": "tube",
    "timing": {
      "\$type": "Tfl.Api.Presentation.Entities.PredictionTiming, Tfl.Api.Presentation.Entities",
      "countdownServerAdjustment": "00:00:00",
      "source": "0001-01-01T00:00:00",
      "insert": "0001-01-01T00:00:00",
      "read": "2025-10-10T13:52:21.939Z",
      "sent": "2025-10-10T13:52:23Z",
      "received": "0001-01-01T00:00:00"
    }
  },
  {
    "\$type": "Tfl.Api.Presentation.Entities.Prediction, Tfl.Api.Presentation.Entities",
    "id": "-131870546",
    "operationType": 1,
    "vehicleId": "062",
    "naptanId": "940GZZLUEMB",
    "stationName": "Embankment Underground Station",
    "lineId": "hammersmith-city",
    "lineName": "Hammersmith & City",
    "platformName": "Westbound - Platform 1",
    "bearing": "",
    "timestamp": "2025-10-10T13:52:23.161951Z",
    "timeToStation": 861,
    "currentLocation": "At Tower Hill Platform 2",
    "towards": "Check Front of Train",
    "expectedArrival": "2025-10-10T14:06:44Z",
    "timeToLive": "2025-10-10T14:06:44Z",
    "modeName": "tube",
    "timing": {
      "\$type": "Tfl.Api.Presentation.Entities.PredictionTiming, Tfl.Api.Presentation.Entities",
      "countdownServerAdjustment": "00:00:00",
      "source": "0001-01-01T00:00:00",
      "insert": "0001-01-01T00:00:00",
      "read": "2025-10-10T13:43:46.542Z",
      "sent": "2025-10-10T13:52:23Z",
      "received": "0001-01-01T00:00:00"
    }
  },
  {
    "\$type": "Tfl.Api.Presentation.Entities.Prediction, Tfl.Api.Presentation.Entities",
    "id": "1376981991",
    "operationType": 1,
    "vehicleId": "066",
    "naptanId": "940GZZLUEMB",
    "stationName": "Embankment Underground Station",
    "lineId": "northern",
    "lineName": "Northern",
    "platformName": "Southbound - Platform 4",
    "direction": "inbound",
    "bearing": "",
    "destinationNaptanId": "940GZZLUKNG",
    "destinationName": "Kennington Underground Station",
    "timestamp": "2025-10-10T13:52:23.161951Z",
    "timeToStation": 476,
    "currentLocation": "At Euston Platform 2",
    "towards": "Kennington via CX",
    "expectedArrival": "2025-10-10T14:00:19Z",
    "timeToLive": "2025-10-10T14:00:19Z",
    "modeName": "tube",
    "timing": {
      "\$type": "Tfl.Api.Presentation.Entities.PredictionTiming, Tfl.Api.Presentation.Entities",
      "countdownServerAdjustment": "00:00:00",
      "source": "0001-01-01T00:00:00",
      "insert": "0001-01-01T00:00:00",
      "read": "2025-10-10T13:52:25.937Z",
      "sent": "2025-10-10T13:52:23Z",
      "received": "0001-01-01T00:00:00"
    }
  },
  {
    "\$type": "Tfl.Api.Presentation.Entities.Prediction, Tfl.Api.Presentation.Entities",
    "id": "942698373",
    "operationType": 1,
    "vehicleId": "207",
    "naptanId": "940GZZLUEMB",
    "stationName": "Embankment Underground Station",
    "lineId": "circle",
    "lineName": "Circle",
    "platformName": "Eastbound - Platform 2",
    "direction": "inbound",
    "bearing": "",
    "destinationNaptanId": "940GZZLUHSC",
    "destinationName": "Hammersmith (H&C Line) Underground Station",
    "timestamp": "2025-10-10T14:01:05.2261555Z",
    "timeToStation": 29,
    "currentLocation": "At Platform",
    "towards": "Hammersmith",
    "expectedArrival": "2025-10-10T14:01:34Z",
    "timeToLive": "2025-10-10T14:01:34Z",
    "modeName": "tube",
    "timing": {
      "\$type": "Tfl.Api.Presentation.Entities.PredictionTiming, Tfl.Api.Presentation.Entities",
      "countdownServerAdjustment": "00:00:00",
      "source": "0001-01-01T00:00:00",
      "insert": "0001-01-01T00:00:00",
      "read": "2025-10-10T14:01:35.464Z",
      "sent": "2025-10-10T14:01:05Z",
      "received": "0001-01-01T00:00:00"
    }
  }]
''', 200),
      );

      final result = await tflApiService.getArrivals(station);
      expect(result.keys.length, 4);
      // Bakerloo
      expect(result['bakerloo']!.length, 1);
      expect(result['bakerloo']!.first.destination!.id, 'HUBHRW');
      expect(result['bakerloo']!.first.direction, 0);
      expect(result['bakerloo']!.first.platform, '5');
      // Circle
      expect(result['circle']!.length, 1);
      expect(result['circle']!.first.destination!.id, 'HUBHMS');
      expect(result['circle']!.first.direction, 1);
      expect(result['circle']!.first.platform, '2');
      // District
      expect(result['district']!.length, 1);
      expect(result['district']!.first.destination!.id, 'HUBUPM');
      expect(result['district']!.first.direction, 0);
      expect(result['district']!.first.platform, '2');
      // Northern
      expect(result['northern']!.length, 1);
      expect(result['northern']!.first.destination!.id, '940GZZLUKNG');
      expect(result['northern']!.first.direction, 1);
      expect(result['northern']!.first.platform, '4');
    });
  });

  test('Test with bad request response', () async {
    final StationModel station =
        (await stationService.getStations(['940GZZLUEMB']))['940GZZLUEMB']!;
    when(
      mockHttpClient.get(
        Uri.parse('https://api.tfl.gov.uk/940GZZLUEMB/Arrivals'),
      ),
    ).thenAnswer((_) async => http.Response('[]]', 400));
    final result = await tflApiService.getArrivals(station);
    expect(result.length, 0);
  });

  test('Test a hub station with duplicate response', () async {
    final StationModel station =
        (await stationService.getStations(['940GZZLUPAH']))['940GZZLUPAH']!;
    when(
      mockHttpClient.get(
        Uri.parse('https://api.tfl.gov.uk/StopPoint/940GZZLUPAH/Arrivals'),
      ),
    ).thenAnswer(
      (_) async => http.Response('''
  [
    {
      "\$type": "Tfl.Api.Presentation.Entities.Prediction, Tfl.Api.Presentation.Entities",
      "id": "-2001530886",
      "operationType": 1,
      "vehicleId": "202",
      "naptanId": "940GZZLUPAH",
      "stationName": "Paddington (H&C Line)-Underground",
      "lineId": "bakerloo",
      "lineName": "Bakerloo",
      "platformName": "Northbound - Platform 3",
      "bearing": "",
      "destinationNaptanId": "940GZZLUSGP",
      "destinationName": "Stonebridge Park Underground Station",
      "timestamp": "2025-10-11T17:06:26.0540841Z",
      "timeToStation": 43,
      "currentLocation": "Approaching Paddington",
      "towards": "Stonebridge Park",
      "expectedArrival": "2025-10-11T17:07:09Z",
      "timeToLive": "2025-10-11T17:07:09Z",
      "modeName": "tube",
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
      "id": "-556363544",
      "operationType": 1,
      "vehicleId": "203",
      "naptanId": "940GZZLUPAH",
      "stationName": "Paddington (H&C Line)-Underground",
      "lineId": "circle",
      "lineName": "Circle",
      "platformName": "Eastbound - Platform 16",
      "direction": "outbound",
      "bearing": "",
      "destinationNaptanId": "940GZZLUERC",
      "destinationName": "Edgware Road (Circle Line) Underground Station",
      "timestamp": "2025-10-11T17:06:26.0540841Z",
      "timeToStation": 165,
      "currentLocation": "At Royal Oak Platform 2",
      "towards": "Edgware Road (Circle)",
      "expectedArrival": "2025-10-11T17:09:11Z",
      "timeToLive": "2025-10-11T17:09:11Z",
      "modeName": "tube",
      "timing": {
        "\$type": "Tfl.Api.Presentation.Entities.PredictionTiming, Tfl.Api.Presentation.Entities",
        "countdownServerAdjustment": "00:00:00",
        "source": "0001-01-01T00:00:00",
        "insert": "0001-01-01T00:00:00",
        "read": "2025-10-11T17:06:47.694Z",
        "sent": "2025-10-11T17:06:26Z",
        "received": "0001-01-01T00:00:00"
      }
    },
    {
      "\$type": "Tfl.Api.Presentation.Entities.Prediction, Tfl.Api.Presentation.Entities",
      "id": "2104548186",
      "operationType": 1,
      "vehicleId": "207",
      "naptanId": "940GZZLUPAH",
      "stationName": "Paddington (H&C Line)-Underground",
      "lineId": "hammersmith-city",
      "lineName": "Hammersmith & City",
      "platformName": "Westbound - Platform 15",
      "direction": "inbound",
      "bearing": "",
      "destinationNaptanId": "940GZZLUHSC",
      "destinationName": "Hammersmith (H&C Line) Underground Station",
      "timestamp": "2025-10-11T17:06:26.0540841Z",
      "timeToStation": 675,
      "currentLocation": "At Kings Cross St. Pancras Platform 1",
      "towards": "Hammersmith",
      "expectedArrival": "2025-10-11T17:17:41Z",
      "timeToLive": "2025-10-11T17:17:41Z",
      "modeName": "tube",
      "timing": {
        "\$type": "Tfl.Api.Presentation.Entities.PredictionTiming, Tfl.Api.Presentation.Entities",
        "countdownServerAdjustment": "00:00:00",
        "source": "0001-01-01T00:00:00",
        "insert": "0001-01-01T00:00:00",
        "read": "2025-10-11T17:06:47.694Z",
        "sent": "2025-10-11T17:06:26Z",
        "received": "0001-01-01T00:00:00"
      }
    }
  ]
''', 200),
    );

    when(
      mockHttpClient.get(
        Uri.parse('https://api.tfl.gov.uk/StopPoint/940GZZLUPAC/Arrivals'),
      ),
    ).thenAnswer(
      (_) async => http.Response('''
      [
        {
          "\$type": "Tfl.Api.Presentation.Entities.Prediction, Tfl.Api.Presentation.Entities",
          "id": "-403589411",
          "operationType": 1,
          "vehicleId": "071",
          "naptanId": "940GZZLUPAC",
          "stationName": "Paddington Underground Station",
          "lineId": "circle",
          "lineName": "Circle",
          "platformName": "Outer Rail - Platform 2",
          "bearing": "",
          "timestamp": "2025-10-11T17:11:31.0208598Z",
          "timeToStation": 35,
          "currentLocation": "At Paddington Platform 2",
          "towards": "Edgware Road",
          "expectedArrival": "2025-10-11T17:12:06Z",
          "timeToLive": "2025-10-11T17:12:06Z",
          "modeName": "tube",
          "timing": {
            "\$type": "Tfl.Api.Presentation.Entities.PredictionTiming, Tfl.Api.Presentation.Entities",
            "countdownServerAdjustment": "00:00:00",
            "source": "0001-01-01T00:00:00",
            "insert": "0001-01-01T00:00:00",
            "read": "2025-10-11T17:11:44.894Z",
            "sent": "2025-10-11T17:11:31Z",
            "received": "0001-01-01T00:00:00"
          }
        },
        {
          "\$type": "Tfl.Api.Presentation.Entities.Prediction, Tfl.Api.Presentation.Entities",
          "id": "476467740",
          "operationType": 1,
          "vehicleId": "070",
          "naptanId": "940GZZLUPAC",
          "stationName": "Paddington Underground Station",
          "lineId": "hammersmith-city",
          "lineName": "Hammersmith & City",
          "platformName": "Inner Rail - Platform 1",
          "bearing": "",
          "timestamp": "2025-10-11T17:11:31.0208598Z",
          "timeToStation": 365,
          "currentLocation": "At Wimbledon Platform 4",
          "towards": "Check Front of Train",
          "expectedArrival": "2025-10-11T17:17:36Z",
          "timeToLive": "2025-10-11T17:17:36Z",
          "modeName": "tube",
          "timing": {
            "\$type": "Tfl.Api.Presentation.Entities.PredictionTiming, Tfl.Api.Presentation.Entities",
            "countdownServerAdjustment": "00:00:00",
            "source": "0001-01-01T00:00:00",
            "insert": "0001-01-01T00:00:00",
            "read": "2025-10-11T17:11:44.894Z",
            "sent": "2025-10-11T17:11:31Z",
            "received": "0001-01-01T00:00:00"
          }
        },
        {
          "\$type": "Tfl.Api.Presentation.Entities.Prediction, Tfl.Api.Presentation.Entities",
          "id": "-871626251",
          "operationType": 1,
          "vehicleId": "070",
          "naptanId": "940GZZLUPAC",
          "stationName": "Paddington Underground Station",
          "lineId": "district",
          "lineName": "District",
          "platformName": "Inner Rail - Platform 1",
          "bearing": "",
          "timestamp": "2025-10-11T17:11:31.0208598Z",
          "timeToStation": 372,
          "currentLocation": "At Wimbledon Platform 4",
          "towards": "Check Front of Train",
          "expectedArrival": "2025-10-11T17:17:43Z",
          "timeToLive": "2025-10-11T17:17:43Z",
          "modeName": "tube",
          "timing": {
            "\$type": "Tfl.Api.Presentation.Entities.PredictionTiming, Tfl.Api.Presentation.Entities",
            "countdownServerAdjustment": "00:00:00",
            "source": "0001-01-01T00:00:00",
            "insert": "0001-01-01T00:00:00",
            "read": "2025-10-11T17:11:42.307Z",
            "sent": "2025-10-11T17:11:31Z",
            "received": "0001-01-01T00:00:00"
          }
        }
      ]
      ''', 200),
    );

    when(
      mockHttpClient.get(
        Uri.parse('https://api.tfl.gov.uk/StopPoint/910GPADTLL/Arrivals'),
      ),
    ).thenAnswer(
      (_) async => http.Response('''
        [
          {
            "\$type": "Tfl.Api.Presentation.Entities.Prediction, Tfl.Api.Presentation.Entities",
            "id": "2115299108",
            "operationType": 1,
            "vehicleId": "202510118006498",
            "naptanId": "910GPADTLL",
            "stationName": "Paddington",
            "lineId": "elizabeth",
            "lineName": "Elizabeth line",
            "platformName": "B",
            "direction": "outbound",
            "bearing": "",
            "destinationNaptanId": "910GHTRWTM4",
            "destinationName": "Heathrow Terminal 4 Rail Station",
            "timestamp": "2025-10-11T17:13:47.6893763Z",
            "timeToStation": 6853,
            "currentLocation": "",
            "towards": "",
            "expectedArrival": "2025-10-11T19:08:00Z",
            "timeToLive": "2025-10-11T19:08:58Z",
            "modeName": "elizabeth-line",
            "timing": {
              "\$type": "Tfl.Api.Presentation.Entities.PredictionTiming, Tfl.Api.Presentation.Entities",
              "countdownServerAdjustment": "00:00:00",
              "source": "0001-01-01T00:00:00",
              "insert": "0001-01-01T00:00:00",
              "read": "2025-10-11T17:13:58.769Z",
              "sent": "2025-10-11T17:13:47Z",
              "received": "0001-01-01T00:00:00"
            }
          },
          {
            "\$type": "Tfl.Api.Presentation.Entities.Prediction, Tfl.Api.Presentation.Entities",
            "id": "-1911144119",
            "operationType": 1,
            "vehicleId": "202510118007265",
            "naptanId": "910GPADTLL",
            "stationName": "Paddington",
            "lineId": "elizabeth",
            "lineName": "Elizabeth line",
            "platformName": "A",
            "direction": "inbound",
            "bearing": "",
            "destinationNaptanId": "910GABWDXR",
            "destinationName": "Abbey Wood",
            "timestamp": "2025-10-11T17:13:47.6893763Z",
            "timeToStation": 1093,
            "currentLocation": "",
            "towards": "",
            "expectedArrival": "2025-10-11T17:32:00Z",
            "timeToLive": "2025-10-11T17:33:55Z",
            "modeName": "elizabeth-line",
            "timing": {
              "\$type": "Tfl.Api.Presentation.Entities.PredictionTiming, Tfl.Api.Presentation.Entities",
              "countdownServerAdjustment": "00:00:00",
              "source": "0001-01-01T00:00:00",
              "insert": "0001-01-01T00:00:00",
              "read": "2025-10-11T17:13:58.769Z",
              "sent": "2025-10-11T17:13:47Z",
              "received": "0001-01-01T00:00:00"
            }
          }
        ]
      ''', 200),
    );

    when(
      mockHttpClient.get(
        Uri.parse('https://api.tfl.gov.uk/StopPoint/910GPADTON/Arrivals'),
      ),
    ).thenAnswer(
      (_) async => http.Response('''
        [
          {
            "\$type": "Tfl.Api.Presentation.Entities.Prediction, Tfl.Api.Presentation.Entities",
            "id": "2115299108",
            "operationType": 1,
            "vehicleId": "202510118006498",
            "naptanId": "910GPADTLL",
            "stationName": "Paddington",
            "lineId": "elizabeth",
            "lineName": "Elizabeth line",
            "platformName": "B",
            "direction": "outbound",
            "bearing": "",
            "destinationNaptanId": "910GHTRWTM4",
            "destinationName": "Heathrow Terminal 4 Rail Station",
            "timestamp": "2025-10-11T17:13:47.6893763Z",
            "timeToStation": 6853,
            "currentLocation": "",
            "towards": "",
            "expectedArrival": "2025-10-11T19:08:00Z",
            "timeToLive": "2025-10-11T19:08:58Z",
            "modeName": "elizabeth-line",
            "timing": {
              "\$type": "Tfl.Api.Presentation.Entities.PredictionTiming, Tfl.Api.Presentation.Entities",
              "countdownServerAdjustment": "00:00:00",
              "source": "0001-01-01T00:00:00",
              "insert": "0001-01-01T00:00:00",
              "read": "2025-10-11T17:13:58.769Z",
              "sent": "2025-10-11T17:13:47Z",
              "received": "0001-01-01T00:00:00"
            }
          },
          {
            "\$type": "Tfl.Api.Presentation.Entities.Prediction, Tfl.Api.Presentation.Entities",
            "id": "-1911144119",
            "operationType": 1,
            "vehicleId": "202510118007265",
            "naptanId": "910GPADTLL",
            "stationName": "Paddington",
            "lineId": "elizabeth",
            "lineName": "Elizabeth line",
            "platformName": "A",
            "direction": "inbound",
            "bearing": "",
            "destinationNaptanId": "910GABWDXR",
            "destinationName": "Abbey Wood",
            "timestamp": "2025-10-11T17:13:47.6893763Z",
            "timeToStation": 1093,
            "currentLocation": "",
            "towards": "",
            "expectedArrival": "2025-10-11T17:32:00Z",
            "timeToLive": "2025-10-11T17:33:55Z",
            "modeName": "elizabeth-line",
            "timing": {
              "\$type": "Tfl.Api.Presentation.Entities.PredictionTiming, Tfl.Api.Presentation.Entities",
              "countdownServerAdjustment": "00:00:00",
              "source": "0001-01-01T00:00:00",
              "insert": "0001-01-01T00:00:00",
              "read": "2025-10-11T17:13:58.769Z",
              "sent": "2025-10-11T17:13:47Z",
              "received": "0001-01-01T00:00:00"
            }
          }
        ]
      ''', 200),
    );

    final result = await tflApiService.getArrivals(station);
    expect(result.keys.length, 5);

    expect(result['bakerloo']!.length, 1);
    expect(result['district']!.length, 1);
    expect(result['circle']!.length, 2);
    expect(result['hammersmith-city']!.length, 2);
    expect(result['elizabeth']!.length, 2);
  });
}
