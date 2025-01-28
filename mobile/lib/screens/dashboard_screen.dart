import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/alert_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          AlertCard(
            title: 'New Policy Update',
            description: 'Please review the new driving policies.',
          ),
          AlertCard(
            title: 'Vehicle Inspection',
            description: 'Vehicle inspection due on 25th Jan.',
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigation(),
    );
  }
}
