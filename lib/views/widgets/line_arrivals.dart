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
          ...arrivals
              .where((x) => x.direction == 0)
              .take(3)
              .map((arrival) => LineArrivalItem(arrival: arrival)),
          // Direction 1
          Text(line.direction1, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            'To ${line.desintations1}',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          SizedBox(height: 10.0),
          ...arrivals
              .where((x) => x.direction == 1)
              .take(3)
              .map((arrival) => LineArrivalItem(arrival: arrival)),
        ],
      ),
    );
  }
}
