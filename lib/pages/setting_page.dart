import 'package:flutter/material.dart';

class DragButton extends StatefulWidget {
  @override
  _DragButtonState createState() => _DragButtonState();
}

class _DragButtonState extends State<DragButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Animation? _animation;
  double _left = 0;
  double _top = 0;
  double _width = 100;
  double _height = 100;
  double _screenWidth  = 0;
  double _screenHeight = 0;

  @override
  void initState() {
    super.initState();
      _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
      _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onPanUpdate: (DragUpdateDetails e) {
        setState(() {
          _left += e.delta.dx;
          _top += e.delta.dy;
          if (_left < 0) {
            _left = 0;
          }
          if (_left > _screenWidth - _width) {
            _left = _screenWidth - _width;
          }
          if (_top < 0) {
            _top = 0;
          }
          if (_top > _screenHeight - _height) {
            _top = _screenHeight - _height;
          }
        });
      },
      onPanEnd: (DragEndDetails e) {
        _controller.reset();
        _controller.forward();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          return Positioned(
            left: _left + _animation!.value * (0 - _left),
            top: _top + _animation!.value * (0 - _top),
            child: Container(
              width: _width,
              height: _height,
              color: Colors.blue,
            ),
          );
        },
      ),
    );
  }
}