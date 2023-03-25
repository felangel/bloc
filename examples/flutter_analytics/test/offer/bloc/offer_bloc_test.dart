// ignore_for_file: prefer_const_constructors
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_analytics/offer/offer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopping_repository/shopping_repository.dart';

class MockShoppingRepository extends Mock implements ShoppingRepository {}

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

  const secondProduct = Product(
    id: 1,
    name: 'name',
    description: 'description',
  );

  const secondOffer = Offer(
    id: 1,
    title: 'title',
    subtitle: 'subtitle',
    description: 'description',
    product: secondProduct,
  );

  group('OfferBloc', () {
    late ShoppingRepository shoppingRepository;

    setUp(() {
      shoppingRepository = MockShoppingRepository();
      when(() => shoppingRepository.selectedProducts).thenAnswer(
        (_) => Stream.empty(),
      );
    });

    test('initial state is CartLoading', () {
      expect(
        OfferBloc(shoppingRepository).state,
        OfferState(),
      );
    });

    blocTest<OfferBloc, OfferState>(
      'emits [success] when products are fetched successfully',
      setUp: () {
        when(shoppingRepository.fetchAllOffers).thenAnswer(
          (_) => Future.value([]),
        );
        when(shoppingRepository.fetchCartProducts).thenAnswer(
          (_) => Future.value([]),
        );
      },
      build: () => OfferBloc(shoppingRepository),
      act: (bloc) => bloc.add(OfferStarted()),
      expect: () => [OfferState(status: OfferStatus.success)],
      verify: (_) {
        verify(shoppingRepository.fetchAllOffers).called(1);
        verify(shoppingRepository.fetchCartProducts).called(1);
      },
    );

    blocTest<OfferBloc, OfferState>(
      'emits [failure] when fetching products fails',
      setUp: () {
        when(shoppingRepository.fetchAllOffers).thenThrow(
          Exception('oops'),
        );
      },
      build: () => OfferBloc(shoppingRepository),
      act: (bloc) => bloc.add(OfferStarted()),
      expect: () => [OfferState(status: OfferStatus.failure)],
    );

    blocTest<OfferBloc, OfferState>(
      'updates correctly when selecting an offer',
      setUp: () {
        when(
          () => shoppingRepository.addOfferToCart(offer),
        ).thenAnswer((_) => Future.value());
      },
      build: () => OfferBloc(shoppingRepository),
      act: (bloc) => bloc.add(OfferSelected(offer)),
      expect: () => [
        OfferState(pendingOffer: offer),
        OfferState(selectedOffers: const [offer]),
      ],
      verify: (_) {
        verify(() => shoppingRepository.addOfferToCart(offer)).called(1);
      },
    );

    blocTest<OfferBloc, OfferState>(
      'updates correctly when selecting an offer fails',
      setUp: () {
        when(
          () => shoppingRepository.addOfferToCart(offer),
        ).thenThrow(Exception('oops'));
      },
      build: () => OfferBloc(shoppingRepository),
      act: (bloc) => bloc.add(OfferSelected(offer)),
      expect: () => [
        OfferState(pendingOffer: offer),
        OfferState(),
      ],
    );

    blocTest<OfferBloc, OfferState>(
      'updates selected offers when cart product stream changes',
      setUp: () {
        when(
          () => shoppingRepository.selectedProducts,
        ).thenAnswer(
          (_) => Stream.value(const [product, secondProduct]),
        );
      },
      seed: () => OfferState(
        allOffers: const [offer, secondOffer],
        selectedOffers: const [offer],
      ),
      build: () => OfferBloc(shoppingRepository),
      expect: () => [
        OfferState(
          allOffers: const [offer, secondOffer],
          selectedOffers: const [offer, secondOffer],
        ),
      ],
    );
  });
}
