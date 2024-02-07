import 'package:flutter/material.dart';

class HourCard extends StatelessWidget {
  final String time;
  final IconData icon;
  final String temp;
  const HourCard({
    super.key,
    required this.time,
    required this.icon,
    required this.temp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              time,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            Icon(icon, size: 25),
            const SizedBox(
              height: 10,
            ),
            Text(temp),
          ],
        ),
      ),
    );
  }
}
