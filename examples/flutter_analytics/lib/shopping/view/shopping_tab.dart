import 'package:analytics_repository/analytics_repository.dart';
import 'package:flutter/material.dart';

class ShoppingTab extends StatelessWidget {
  const ShoppingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const Placeholder(),
            settings: const RouteSettings(
              arguments: RouteAnalytic('placeholder_page_viewed'),
            ),
          ),
        );
      },
      child: const Text('Push'),
    );
  }
}
