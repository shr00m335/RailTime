import 'package:flutter/material.dart';

/// A widget that acts as a title bar of the whole application.
///
/// [title] sets the title of the page to be displayed
///
/// [subtitle] puts a widget below the title (optional)
///
/// [backVisible] determines whether to show the back arrow, it is use when the page is push.
/// When the back arrow is clicked, it will go back to the previous page. (call Navigator.of(context).pop())
///
/// The height of the top bar is determined by whether a subtitle is provided. It will be either 50px without subtitle or 100px with subtitle
class TopBar extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final bool backVisible;

  const TopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.backVisible = false,
  });

  /// Go back to the previous page
  void _popPage(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Full width
      height:
          subtitle == null
              ? 50
              : 100, // Make the top bar shorter if subtitle not provided
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          mainAxisAlignment:
              subtitle == null
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            backVisible
                ? Row(
                  children: [
                    GestureDetector(
                      onTap: () => _popPage(context),
                      child: Icon(
                        Icons.arrow_back,
                        size: 28,
                        color:
                            Theme.of(context).textTheme.headlineLarge?.color ??
                            Colors
                                .white, // Get headlineLarge text color, fallback to white
                      ),
                    ),
                    SizedBox(width: 10.0),
                    title,
                  ],
                )
                : title,
            if (subtitle != null) subtitle!,
          ],
        ),
      ),
    );
  }
}
