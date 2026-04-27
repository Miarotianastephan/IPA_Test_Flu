import 'package:flutter/material.dart';

class DraggableFab extends StatefulWidget {
  final VoidCallback onPressed;
  final String? cover;
  const DraggableFab({super.key, required this.onPressed, required this.cover});

  @override
  State<DraggableFab> createState() => _DraggableFabState();
}

class _DraggableFabState extends State<DraggableFab> {
  late Offset position;
  bool initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!initialized) {
      final size = MediaQuery.of(context).size;
      position = Offset(size.width - 80, size.height - 120);
      initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const double fabSize = 56;
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            double newX = position.dx + details.delta.dx;
            double newY = position.dy + details.delta.dy;
            newX = newX.clamp(0.0, size.width - fabSize);
            newY = newY.clamp(0.0, size.height - fabSize - kToolbarHeight);
            position = Offset(newX, newY);
          });
        },
        child: FloatingActionButton(
          mini: false,
          backgroundColor: Colors.transparent,
          onPressed: widget.onPressed,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: fabSize,
                height: fabSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: ClipOval(
                  child: (widget.cover != null && widget.cover!.isNotEmpty)
                      ? Image.network(
                          widget.cover!,
                          width: fabSize,
                          height: fabSize,
                          fit: BoxFit.cover,
                        )
                      : SizedBox.shrink(),
                ),
              ),
              const Icon(
                Icons.music_note,
                color: Colors.white,
                size: 28,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    blurRadius: 4.0,
                    offset: Offset(2, 2),
                  ),
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 8.0,
                    offset: Offset(-2, -2),
                  ),
                  Shadow(
                    color: Colors.purpleAccent,
                    blurRadius: 12.0,
                    offset: Offset(0, 0),
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
