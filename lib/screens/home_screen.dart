import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Converter Tools")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(
              text: "Image to PDF",
              onPressed: () {
                // 🚀 Navigate to Image→PDF converter screen  sss
              },
            ),
            SizedBox(height: 16),
            CustomButton(
              text: "PDF to Image",
              onPressed: () {
                // 🚀 Navigate to PDF→Image converter screen
              },
            ),
          ],
        ),
      ),
    );
  }
}
