import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:railtime/model/arrival_model.dart';
import 'package:railtime/model/lat_lon.dart';
import 'package:railtime/model/line_model.dart';
import 'package:railtime/model/station_model.dart';
import 'package:railtime/views/widgets/line_arrival_item.dart';

void main() {
  testWidgets('LineArrivalItem with normal arrival', (
    WidgetTester tester,
  ) async {
    ArrivalModel arrival = ArrivalModel(
      '123',
      LineModel(
        'bakerloo',
        'Bakerloo',
        'BAK',
        'tube',
        Colors.white,
        '',
        '',
        '',
        '',
      ),
      '4',
      0,
      StationModel('123', 'Test Destination', [], LatLon(0, 0), ''),
      '',
      DateTime.now(),
      DateTime(2025, 09, 25, 19, 23),
    );
    await tester.pumpWidget(
      MaterialApp(home: LineArrivalItem(arrival: arrival)),
    );

    final Finder timeFinder = find.text('19:23');
    final Finder destinationFinder = find.text('Test Destination');
    final Finder platformFinder = find.text('4');
    expect(timeFinder, findsOneWidget);
    expect(destinationFinder, findsOneWidget);
    expect(platformFinder, findsOneWidget);
  });

  testWidgets('LineArrivalItem with arrival without destination', (
    WidgetTester tester,
  ) async {
    ArrivalModel arrival = ArrivalModel(
      '123',
      LineModel(
        'bakerloo',
        'Bakerloo',
        'BAK',
        'tube',
        Colors.white,
        '',
        '',
        '',
        '',
      ),
      '4',
      0,
      null,
      'Test Destination 2',
      DateTime.now(),
      DateTime(2025, 09, 25, 19, 23),
    );
    await tester.pumpWidget(
      MaterialApp(home: LineArrivalItem(arrival: arrival)),
    );

    final Finder timeFinder = find.text('19:23');
    final Finder destinationFinder = find.text('Test Destination 2');
    final Finder platformFinder = find.text('4');
    expect(timeFinder, findsOneWidget);
    expect(destinationFinder, findsOneWidget);
    expect(platformFinder, findsOneWidget);
  });
}
