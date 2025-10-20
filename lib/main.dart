import 'package:flutter/material.dart';

void main() {
  runApp(AlQuran());
}

class AlQuran extends StatelessWidget {
  const AlQuran({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      appBar: AppBar(),
      body: Placeholder(),
    ),);
  }
}