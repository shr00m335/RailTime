import 'package:flutter/material.dart';
import 'package:railtime/model/arrival_model.dart';
import 'package:railtime/utils/date_time_utils.dart';

class LineArrivalItem extends StatelessWidget {
  final ArrivalModel arrival;

  const LineArrivalItem({super.key, required this.arrival});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10.0),
        ),
        height: 50,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            children: [
              Text(
                DateTimeUtils.formatToHHmm(arrival.estimatedArrival),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(width: 20.0),
              Text(
                arrival.destination?.name ?? arrival.destinationText,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(fontSize: 18.0),
              ),
              Spacer(),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Platform',
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall!.copyWith(fontSize: 8.0),
                  ),
                  Text(
                    arrival.platform,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
