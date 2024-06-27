import 'package:flutter/material.dart';

class BGBubbles extends StatefulWidget {
  const BGBubbles({super.key, this.hasOpacity = false, this.height = 800});

  final bool hasOpacity;
  final double? height;

  @override
  State<BGBubbles> createState() => _BGBubblesState();
}

class _BGBubblesState extends State<BGBubbles> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height - 130,
      child: Stack(
        children: [
          bubble(
              hasOpacity: widget.hasOpacity,
              top: 90,
              left: -50,
              height: 130,
              width: 130,
              color: (!widget.hasOpacity)
                  ? Colors.purpleAccent
                  : Colors.purpleAccent.withOpacity(0.4)),
          bubble(
              hasOpacity: widget.hasOpacity,
              top: 30,
              left: 300,
              height: 70,
              width: 70,
              color: (!widget.hasOpacity)
                  ? Colors.yellow
                  : Colors.yellow.withOpacity(0.6)),
          bubble(
              hasOpacity: widget.hasOpacity,
              top: 350,
              left: 50,
              height: 50,
              width: 50,
              color: (!widget.hasOpacity)
                  ? Colors.purpleAccent
                  : Colors.purpleAccent.withOpacity(0.4)),
          bubble(
              hasOpacity: widget.hasOpacity,
              top: 600,
              left: 120,
              height: 80,
              width: 80,
              color: (!widget.hasOpacity)
                  ? Colors.purpleAccent
                  : Colors.purpleAccent.withOpacity(0.4)),
          bubble(
              hasOpacity: widget.hasOpacity,
              top: 400,
              left: 300,
              height: 130,
              width: 130,
              color: (!widget.hasOpacity)
                  ? Colors.yellow
                  : Colors.yellow.withOpacity(0.6)),
          bubble(
              hasOpacity: widget.hasOpacity,
              top: 250,
              left: 350,
              height: 30,
              width: 30,
              color: (!widget.hasOpacity)
                  ? Colors.purpleAccent
                  : Colors.purpleAccent.withOpacity(0.4)),
          bubble(
              hasOpacity: widget.hasOpacity,
              top: 650,
              left: 300,
              height: 130,
              width: 130,
              color: (!widget.hasOpacity)
                  ? Colors.yellow
                  : Colors.yellow.withOpacity(0.6)),
          bubble(
              hasOpacity: widget.hasOpacity,
              top: 500,
              left: 20,
              height: 50,
              width: 50,
              color: (!widget.hasOpacity)
                  ? Colors.yellow
                  : Colors.yellow.withOpacity(0.6)),
        ],
      ),
    );
  }
}

Widget bubble(
    {required double top,
    required double left,
    double? height,
    double? width,
    required Color color,
    bool hasOpacity = false}) {
  return Positioned(
    top: top,
    left: left,
    child: Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: hasOpacity ? Colors.grey.shade300 : Colors.grey,
            blurRadius: 4,
            offset: const Offset(4, 6), // Shadow position
          ),
        ],
      ),
    ),
  );
}
