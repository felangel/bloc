// ignore_for_file: prefer_const_constructors

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_analytics/offer/bloc/offer_bloc.dart';
import 'package:flutter_analytics/offer/view/offer_tab.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockingjay/mockingjay.dart';
import 'package:shopping_repository/shopping_repository.dart';

import '../../helpers/helpers.dart';

class MockShoppingRepository extends Mock implements ShoppingRepository {}

class MockOfferBloc extends MockBloc<OfferEvent, OfferState>
    implements OfferBloc {}

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

  group('CartTab', () {
    late ShoppingRepository shoppingRepository;
    late OfferBloc offerBloc;

    setUp(() {
      shoppingRepository = MockShoppingRepository();
      offerBloc = MockOfferBloc();
      when(() => offerBloc.state).thenReturn(OfferState());
    });

    Widget buildSubject() {
      return BlocProvider.value(
        value: offerBloc,
        child: const OfferTab(),
      );
    }

    group('route', () {
      testWidgets('renders OfferTab', (tester) async {
        when(() => shoppingRepository.fetchAllOffers()).thenAnswer(
          (_) => Future.value([offer]),
        );
        when(() => shoppingRepository.fetchCartProducts()).thenAnswer(
          (_) => Future.value([product]),
        );
        when(() => shoppingRepository.selectedProducts).thenAnswer(
          (_) => Stream.empty(),
        );

        await tester.pumpRoute(
          OfferTab.route(),
          shoppingRepository: shoppingRepository,
        );
        expect(find.byType(OfferTab), findsOneWidget);
      });
    });

    testWidgets('renders OfferItems when there are offers', (tester) async {
      when(() => offerBloc.state).thenReturn(
        OfferState(
          allOffers: const [offer],
          status: OfferStatus.success,
        ),
      );
      await tester.pumpApp(buildSubject());
      expect(find.byType(OfferItem), findsWidgets);
    });

    testWidgets('adds OfferSelected when offer is pressed', (tester) async {
      when(() => offerBloc.state).thenReturn(
        OfferState(
          status: OfferStatus.success,
          allOffers: const [offer],
        ),
      );
      await tester.pumpApp(buildSubject());
      await tester.tap(find.byType(OfferActionButton));
      verify(() => offerBloc.add(OfferSelected(offer))).called(1);
    });

    testWidgets('renders a check when an item has been selected',
        (tester) async {
      when(() => offerBloc.state).thenReturn(
        OfferState(
          status: OfferStatus.success,
          allOffers: const [offer],
          selectedOffers: const [offer],
        ),
      );
      await tester.pumpApp(buildSubject());
      expect(find.byIcon(Icons.check), findsWidgets);
    });
  });
}
