import 'package:flutter/material.dart';
import 'package:railtime/model/line_model.dart';

class LineIcon extends StatelessWidget {
  final LineModel line;
  final double size;
  final bool disabled;

  const LineIcon({
    super.key,
    required this.line,
    required this.size,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 5.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: disabled ? Theme.of(context).disabledColor : line.color,
          border: Border.all(
            color:
                disabled || line.color.computeLuminance() > 0.1
                    ? Colors.transparent
                    : Colors.white,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.5),
          child: Text(
            line.abbreviation,
            style: TextStyle(
              fontSize: size,
              color:
                  disabled
                      ? Colors.white
                      : (line.color.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
