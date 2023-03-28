import 'package:analytics_repository/analytics_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_analytics/app/app.dart';
import 'package:flutter_analytics/cart/bloc/cart_bloc.dart';
import 'package:flutter_analytics/offer/offer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_repository/shopping_repository.dart';

class OfferTab extends StatelessWidget {
  const OfferTab({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      settings: const AnalyticRouteSettings(
        screenView: ScreenView(routeName: 'offer_tab'),
      ),
      builder: (_) => BlocProvider(
        create: (context) => OfferBloc(
          context.read<ShoppingRepository>(),
        )..add(
            const OfferStarted(),
          ),
        child: const OfferTab(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CupertinoNavigationBar(
        middle: Text('Offers'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: OfferList(),
        ),
      ),
    );
  }
}

class OfferList extends StatelessWidget {
  const OfferList({super.key});

  @override
  Widget build(BuildContext context) {
    final allOffers = context.select(
      (OfferBloc bloc) => bloc.state.allOffers,
    );

    final status = context.select(
      (OfferBloc bloc) => bloc.state.status,
    );

    if (status == OfferStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.black,
        ),
      );
    }
    if (status == OfferStatus.failure) {
      return const Center(
        child: Text('Something went wrong.'),
      );
    }
    if (allOffers.isEmpty) {
      return const Center(
        child: Text('No offers currently!'),
      );
    }

    return Center(
      child: Column(
        children: [
          for (final offer in allOffers) _OfferItem(offer),
        ],
      ),
    );
  }
}

class _OfferItem extends StatelessWidget {
  const _OfferItem(this.offer);

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  offer.title,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  offer.subtitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  offer.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              _OfferAction(offer),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfferAction extends StatelessWidget {
  const _OfferAction(this.offer);

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    final isSelected = context.select(
      (OfferBloc bloc) => bloc.state.selectedOffers.contains(offer),
    );

    final isPending = context.select(
      (OfferBloc bloc) => bloc.state.pendingOffer == offer,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ElevatedButton(
        onPressed: isSelected || isPending
            ? null
            : () {
                context.read<OfferBloc>().add(
                      OfferSelected(offer),
                    );
              },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isSelected ? 'Added' : 'Add to cart'),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.check),
              )
          ],
        ),
      ),
    );
  }
}
