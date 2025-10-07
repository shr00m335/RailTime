import 'package:railtime/model/repository/database_repository.dart';

class LineService {
  Future<Map<String, int>> getDirectionsByDestinations(
    String lineId,
    String currentStationId,
    List<String> destinationIds,
  ) async {
    final List<String> stationIds =
        {currentStationId, ...destinationIds}.toList();

    final Map<String, int> sequences = await DatabaseRepository()
        .getStationsSequencesOnLine(lineId, stationIds);
    if (!sequences.keys.contains(currentStationId)) return {};
    final int currentStationSequnce = sequences[currentStationId]!;

    return {
      for (String destinationId in destinationIds)
        if (sequences.keys.contains(destinationId))
          destinationId:
              sequences[destinationId]! > currentStationSequnce ? 0 : 1,
    };
  }
}
