import 'package:flutter/material.dart';
import 'package:flutter_analytics/cart/view/cart_dialog.dart';

class OfferTab extends StatelessWidget {
  const OfferTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offers'),
      ),
      body: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            CartDialog.route(context),
          );
        },
        child: Text('Push'),
      ),
    );
  }
}
