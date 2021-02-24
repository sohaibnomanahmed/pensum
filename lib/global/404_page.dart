import 'package:flutter/material.dart';

class PageNotFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(50.0),
            child: Image.asset('assets/images/motor_cycle.png'),
          ),
          Text('Page not found', style: Theme.of(context).textTheme.headline4,),
        ],
      ),
    );
  }
}
