// ignore_for_file: prefer_const_constructors, avoid_redundant_argument_values
import 'package:flutter_analytics/offer/bloc/offer_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_repository/shopping_repository.dart';

void main() {
  const product = Product(
    id: 0,
    name: 'name',
    description: 'description',
  );

  const offer = Offer(
    id: 0,
    product: product,
    title: 'name',
    subtitle: 'subtitle',
    description: 'description',
  );

  group('OfferState', () {
    test('supports value comparison', () {
      expect(OfferState(), OfferState());
    });

    group('copyWith', () {
      test('returns the same object if no arguments are provided', () {
        expect(
          OfferState().copyWith(),
          equals(OfferState()),
        );
      });

      test('retains the old value for every parameter if null is provided', () {
        expect(
          OfferState().copyWith(
            status: null,
            allOffers: null,
            selectedOffers: null,
            pendingOffer: null,
          ),
          equals(OfferState()),
        );
      });

      test('replaces every non-null parameter', () {
        expect(
          OfferState().copyWith(
            status: OfferStatus.success,
            allOffers: [offer],
            selectedOffers: [offer],
            pendingOffer: offer,
          ),
          equals(
            OfferState(
              status: OfferStatus.success,
              allOffers: const [offer],
              selectedOffers: const [offer],
              pendingOffer: offer,
            ),
          ),
        );
      });
    });
  });
}
