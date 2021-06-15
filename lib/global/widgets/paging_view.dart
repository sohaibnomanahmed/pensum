import 'package:flutter/material.dart';

class PagingView extends StatefulWidget {
  final Widget child;
  final Function action;

  const PagingView({Key? key, required this.child, required this.action})
      : super(key: key);

  @override
  _PagingViewState createState() => _PagingViewState();
}

class _PagingViewState extends State<PagingView> {
  late bool lock;

  @override
  Widget build(BuildContext context) {
    lock = false;
    return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels >
              (scrollInfo.metrics.maxScrollExtent * 0.8)) {
            if (!lock) {
              // set lock to prevent multiple calls to the function
              lock = true;
              widget.action();
            }
          }
          return true;
        },
        child: widget.child);
  }
}
