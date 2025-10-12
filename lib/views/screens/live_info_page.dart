import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:railtime/model/arrival_model.dart';
import 'package:railtime/model/station_model.dart';
import 'package:railtime/view_model/live_info_view_model.dart';
import 'package:railtime/views/widgets/line_arrivals.dart';
import 'package:railtime/views/widgets/line_icon.dart';
import 'package:railtime/views/widgets/top_bar.dart';

class LiveInfoPage extends StatefulWidget {
  const LiveInfoPage({super.key});

  @override
  State<LiveInfoPage> createState() => _LiveInfoPageState();
}

class _LiveInfoPageState extends State<LiveInfoPage> {
  int _selectedLineIndex = 0;
  final PageController _pageController = PageController();

  void _onPageChanged(int index) {
    setState(() {
      _selectedLineIndex = index;
    });
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: Duration(
        milliseconds: (_pageController.page!.floor() - index).abs() * 200,
      ),
      curve: Easing.linear,
    );
  }

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
    final Map<String, List<ArrivalModel>>? arrivals =
        Provider.of<LiveInfoViewModel>(context).arrivals;

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
                    .map((line) => LineIcon(line: line, size: 14))
                    .toList(),
          ),
        ),
        (nearestStation != null && arrivals != null)
            ? Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      children:
                          nearestStation.lines
                              .map(
                                (line) => LineArrivals(
                                  line: line,
                                  arrivals: arrivals[line.id] ?? [],
                                ),
                              )
                              .toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          nearestStation.lines
                              .asMap()
                              .entries
                              .map(
                                (entry) => GestureDetector(
                                  onTap: () => _goToPage(entry.key),
                                  child: LineIcon(
                                    line: entry.value,
                                    size:
                                        _selectedLineIndex == entry.key
                                            ? 16
                                            : 12,
                                    disabled: _selectedLineIndex != entry.key,
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                ],
              ),
            )
            : Expanded(child: const Center(child: CircularProgressIndicator())),
      ],
    );
  }
}
