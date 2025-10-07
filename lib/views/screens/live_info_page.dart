import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:railtime/model/station_model.dart';
import 'package:railtime/view_model/live_info_view_model.dart';
import 'package:railtime/views/widgets/line_icon.dart';
import 'package:railtime/views/widgets/top_bar.dart';

class LiveInfoPage extends StatefulWidget {
  const LiveInfoPage({super.key});

  @override
  State<LiveInfoPage> createState() => _LiveInfoPageState();
}

class _LiveInfoPageState extends State<LiveInfoPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LiveInfoViewModel>(
        context,
        listen: false,
      ).getNearestStation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final StationModel? nearestStation =
        Provider.of<LiveInfoViewModel>(context).nearestStation;

    return Column(
      children: [
        TopBar(
          title:
              nearestStation != null
                  ? Text(
                    nearestStation.name,
                    style: Theme.of(context).textTheme.headlineLarge,
                  )
                  : SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Theme.of(context).indicatorColor,
                      strokeWidth: 3,
                    ),
                  ),
          subtitle: Wrap(
            children:
                (nearestStation?.lines ?? [])
                    .map((line) => LineIcon(line: line))
                    .toList(),
          ),
        ),
      ],
    );
  }
}
