import 'package:flutter/material.dart';

class FutureSeasonWarning extends StatelessWidget {
  const FutureSeasonWarning({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.amber[300],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black, width: 2),
        ),
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Center(
          child: Text(
            "WARNING\nFuture seasons are NOT visible to users. Edit the season and set the status to 'Active'.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }
}
