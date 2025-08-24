import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("History")),
      body: Center(
        child: Text(
          "Converted files history will appear here",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
