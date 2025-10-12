import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:railtime/model/arrival_model.dart';
import 'package:railtime/model/line_model.dart';
import 'package:railtime/model/services/line_service.dart';
import 'package:railtime/model/services/station_service.dart';
import 'package:railtime/model/station_model.dart';

class TflApiService {
  final String _baseUrl = 'https://api.tfl.gov.uk';
  final http.Client _httpClient;
  final StationService _stationService;
  final LineService _lineService;

  TflApiService({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client(),
      _stationService = StationService(),
      _lineService = LineService();

  /// Preform http get to the given [uri]
  ///
  /// Return [http.Response] if the response status code is 200
  ///
  /// Return null otherwise
  Future<T?> _httpGet<T>(Uri uri) async {
    http.Response res = await _httpClient.get(uri);
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as T;
    } else {
      return null;
    }
  }

  Future<Map<String, List<ArrivalModel>>> getArrivals(
    StationModel station,
  ) async {
    // Convert station ids as a lists
    final Iterable<String> stationIds =
        station.isHub ? station.children.map((x) => x.id) : [station.id];

    final Map<String, Set<ArrivalModel>> arrivals = {};

    for (String stationId in stationIds) {
      final Uri endpoint = Uri.parse('$_baseUrl/StopPoint/$stationId/Arrivals');
      final List<dynamic>? response = await _httpGet(endpoint);
      if (response == null) continue;

      // Get destinations
      final List<String> destinationIds =
          response
              .map((x) => x['destinationNaptanId']?.toString())
              .whereType<String>()
              .toList();
      final Map<String, StationModel> destinations = await _stationService
          .getStations(destinationIds);
      final Set<String> lineIds =
          response
              .map((dbMap) => dbMap['lineId']?.toString())
              .whereType<String>()
              .toSet();
      final List<Map<String, int>> directionsList = await Future.wait(
        lineIds.map(
          (lineId) => _lineService.getDirectionsByDestinations(
            lineId,
            stationId,
            destinationIds,
          ),
        ),
      );

      final Map<String, Map<String, int>> directions = {
        for (int i = 0; i < lineIds.length; i++)
          lineIds.elementAt(i): directionsList[i],
      };

      for (Map<String, dynamic> dbMap in response) {
        final LineModel? line = station.lines.firstWhereOrNull(
          (line) => line.id == dbMap['lineId'],
        );

        // Skip line does not exists in the station
        // Circle mislabelled as hammersmith and city line and vice versa
        // Also ignore service that terminates at the current station
        if (line == null ||
            stationIds.contains(
              dbMap['destinationNaptanId']?.toString() ?? '',
            )) {
          continue;
        }
        final ArrivalModel arrival = ArrivalModel.fromDatabaseMap(
          dbMap,
          line,
          destinations[dbMap['destinationNaptanId']],
          directions[line.id]?[dbMap['destinationNaptanId']],
        );
        if (arrivals.containsKey(line.id)) {
          arrivals[line.id]!.add(arrival);
        } else {
          arrivals[line.id] = {arrival};
        }
      }
    }

    Map<String, List<ArrivalModel>> sortedArrivals = {};

    // Sort arrival time in ascending order
    for (String lineId in arrivals.keys) {
      sortedArrivals[lineId] = arrivals[lineId]!.sorted(
        (a, b) => a.estimatedArrival.compareTo(b.estimatedArrival),
      );
    }

    return sortedArrivals;
  }
}
