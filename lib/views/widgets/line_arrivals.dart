import 'package:flutter/material.dart';
import 'package:railtime/model/arrival_model.dart';
import 'package:railtime/model/line_model.dart';
import 'package:railtime/views/widgets/line_arrival_item.dart';
import 'package:railtime/views/widgets/line_icon.dart';

class LineArrivals extends StatelessWidget {
  final LineModel line;
  final List<ArrivalModel> arrivals;

  const LineArrivals({super.key, required this.line, required this.arrivals});

  @override
  Widget build(BuildContext context) {
    final Iterable<Widget> direction0ArrivalItems = arrivals
        .where((x) => x.direction == 0)
        .take(3)
        .map((arrival) => LineArrivalItem(arrival: arrival));
    final Iterable<Widget> direction1ArrivalItems = arrivals
        .where((x) => x.direction == 1)
        .take(3)
        .map((arrival) => LineArrivalItem(arrival: arrival));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Line Icons
          Row(
            children: [
              LineIcon(line: line, size: 16),
              Text(line.name, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
          SizedBox(height: 5.0),
          // Direction 0
          Text(line.direction0, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            'To ${line.destinations0}',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          SizedBox(height: 10.0),
          ...direction0ArrivalItems,
          // Generate empty space to maintain same y position for direction 1
          ...List.generate(
            3 - direction0ArrivalItems.length,
            (_) => 0,
          ).map((_) => SizedBox(height: 60)),
          // Direction 1
          Text(line.direction1, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            'To ${line.desintations1}',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          SizedBox(height: 10.0),
          ...(direction1ArrivalItems.isNotEmpty
              ? direction1ArrivalItems
              : [
                Center(
                  child: Text(
                    'No information. Please check station board',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ]),
        ],
      ),
    );
  }
}
