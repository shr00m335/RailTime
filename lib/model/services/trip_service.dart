import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:railtime/model/arrival_model.dart';
import 'package:railtime/model/repository/database_repository.dart';
import 'package:railtime/model/services/line_service.dart';
import 'package:railtime/model/services/tfl_api_service.dart';
import 'package:railtime/model/station_model.dart';
import 'package:railtime/model/trip_model.dart';

class TripService {
  final TflApiService _tflApiService;

  TripService({http.Client? httpClient})
    : _tflApiService = TflApiService(httpClient: httpClient);

  Future<TripModel?> getTrip(
    StationModel currentStation,
    ArrivalModel targetArrival,
    String? vehicleId,
  ) async {
    if (targetArrival.destination == null && targetArrival.direction == -1) {
      return null;
    }
    final DatabaseRepository repository = DatabaseRepository();
    final List<String> tripIds = await repository.getTripIdsOfLine(
      targetArrival.line.id,
      currentStation.id,
      targetArrival.estimatedArrival,
    );
    final Map<String, String> destinationIds = await repository
        .getTripDesinationIdsByIds(tripIds);
    String? tripId;
    // Get the tripId by destination first. If destination is not provided, get it by direction
    if (targetArrival.destination != null) {
      tripId =
          destinationIds.entries
              .firstWhereOrNull(
                (entry) => entry.value == targetArrival.destination!.id,
              )
              ?.key;
    } else if (targetArrival.direction != -1) {
      Map<String, int> directions = await LineService()
          .getDirectionsByDestinations(
            targetArrival.line.id,
            currentStation.id,
            destinationIds.values.toList(),
          );
      tripId =
          destinationIds.entries
              .firstWhereOrNull(
                (entry) =>
                    (directions[entry.value] ?? -1) == targetArrival.direction,
              )
              ?.key;
    }
    // Get schedule trip arrivals
    final List<TripArrivalModel> scheduledArrivals =
        tripId != null ? await repository.getTripById(tripId) : [];

    // Get estimatede trip arrivals
    final List<TripArrivalModel> estimatedArrivals =
        vehicleId != null
            ? await _tflApiService.getVehicleArrivals(
              vehicleId,
              targetArrival.line.id,
            )
            : [];

    final List<TripArrivalModel> sharedArrivals =
        estimatedArrivals
            .where(
              (arrival) => scheduledArrivals
                  .map((x) => x.station.id)
                  .contains(arrival.station.id),
            )
            .toList();
    final List<TripArrivalModel> arrivals =
        estimatedArrivals
            .where((arrival) => !sharedArrivals.contains(arrival))
            .toList();

    // Combine shared arrivals
    for (TripArrivalModel arrival in scheduledArrivals) {
      TripArrivalModel? estimatedArrival = sharedArrivals.firstOrNull;
      if (arrival.station.id == estimatedArrival?.station.id) {
        arrivals.add(
          TripArrivalModel(
            arrival.station,
            arrival.scheduled,
            estimatedArrival!.actual,
            estimatedArrival.platform,
            arrival.sequence,
            true,
          ),
        );
        sharedArrivals.removeAt(0);
      } else {
        arrivals.add(arrival);
      }
    }

    final List<TripArrivalModel> sortedArrivals = arrivals.sorted(
      (a, b) => (a.scheduled ?? a.actual ?? 0).compareTo(
        (b.scheduled ?? b.actual ?? 0),
      ),
    );

    bool estimatedStarted = false;
    int estimatedIndex = 0;
    for (TripArrivalModel arrival in sortedArrivals) {
      if (estimatedIndex >= estimatedArrivals.length) {
        estimatedStarted = false;
      } else if (arrival.station.id ==
          estimatedArrivals[estimatedIndex].station.id) {
        estimatedStarted = true;
        estimatedIndex += 1;
      } else if (estimatedStarted) {
        arrival.isStopping = false;
      } else {
        arrival.isDeparted = true;
      }
    }

    TripModel trip = TripModel(
      tripId ?? vehicleId ?? '',
      targetArrival.line,
      0,
      sortedArrivals.first.station,
      sortedArrivals.last.station,
      sortedArrivals,
    );
    return trip;
  }
}
