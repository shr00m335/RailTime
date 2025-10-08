import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:railtime/model/arrival_model.dart';
import 'package:railtime/model/line_model.dart';
import 'package:railtime/model/repository/database_repository.dart';
import 'package:railtime/model/services/line_service.dart';
import 'package:railtime/model/station_model.dart';

class TflApiService {
  final String _baseUrl = 'https://api.tfl.gov.uk';

  Future<Map<String, List<ArrivalModel>>> getArrivals(
    StationModel station,
  ) async {
    Uri endpoint = Uri.parse('$_baseUrl/StopPoint/${station.id}/Arrivals');

    http.Response res = await http.get(endpoint);
    if (res.statusCode != 200) return {};

    List<dynamic> resJson = jsonDecode(res.body);

    List<String> desintationIds =
        resJson
            .map((x) => x['destinationNaptanId']?.toString())
            .whereType<String>()
            .toSet()
            .toList();

    Map<String, StationModel> destinations = await DatabaseRepository()
        .getStationsByIds(desintationIds);

    Map<String, Map<String, int>> directions = {
      for (LineModel line in station.lines)
        line.id: await LineService().getDirectionsByDestinations(
          line.id,
          station.id,
          desintationIds,
        ),
    };

    final List<ArrivalModel> arrivals =
        resJson
            .map(
              (dbMap) => ArrivalModel.fromDatabaseMap(
                dbMap,
                station.lines.firstWhere((line) => line.id == dbMap['lineId']),
                destinations[dbMap['destinationNaptanId']],
                directions[dbMap['lineId']
                    .toString()]?[dbMap['destinationNaptanId']],
              ),
            )
            .toList();

    arrivals.sort((a, b) => a.estimatedArrival.compareTo(b.estimatedArrival));

    return {
      for (LineModel line in station.lines)
        line.id:
            arrivals
                .where(
                  (x) =>
                      x.line.id == line.id &&
                      x.line.id != 'circle' &&
                      x.destination?.id !=
                          '940GZZLUERC', // Add edge case where circle mislabeled as other line in API
                )
                .toList(),
    };
  }
}
