import 'dart:async';

import 'package:analytics_repository/analytics_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_repository/shopping_repository.dart';

part 'offer_event.dart';
part 'offer_state.dart';

class OfferBloc extends Bloc<OfferEvent, OfferState> {
  OfferBloc(this._shoppingRepository) : super(const OfferState()) {
    on<_OfferCartProductsChanged>(_onCartProductsChanged);
    on<OfferStarted>(_onStarted);
    on<OfferSelected>(_onSelected);

    _productSubscription = _shoppingRepository.selectedProducts.listen(
      (products) => add(
        _OfferCartProductsChanged(products),
      ),
    );
  }

  final ShoppingRepository _shoppingRepository;
  late StreamSubscription<List<Product>> _productSubscription;

  @override
  Future<void> close() {
    _productSubscription.cancel();
    return super.close();
  }

  List<Offer> _selectedOffers(
    List<Offer> allOffers,
    List<Product> cartProducts,
  ) {
    final selectedOffers = <Offer>[];

    for (final offer in allOffers) {
      final isOfferSelected = cartProducts.contains(offer.product);
      if (isOfferSelected) selectedOffers.add(offer);
    }

    return selectedOffers;
  }

  void _onCartProductsChanged(
    _OfferCartProductsChanged event,
    Emitter<OfferState> emit,
  ) {
    emit(
      state.copyWith(
        selectedOffers: _selectedOffers(
          state.allOffers,
          event.cartProducts,
        ),
      ),
    );
  }

  Future<void> _onStarted(
    OfferStarted event,
    Emitter<OfferState> emit,
  ) async {
    try {
      late final List<Offer> allOffers;
      late final List<Product> cartProducts;

      await Future.wait([
        _shoppingRepository.fetchAllOffers().then(
              (value) => allOffers = value,
            ),
        _shoppingRepository.fetchCartProducts().then(
              (value) => cartProducts = value,
            ),
      ]);

      emit(
        state.copyWith(
          status: OfferStatus.success,
          allOffers: allOffers,
          selectedOffers: _selectedOffers(
            allOffers,
            cartProducts,
          ),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: OfferStatus.failure,
        ),
      );
    }
  }

  Future<void> _onSelected(
    OfferSelected event,
    Emitter<OfferState> emit,
  ) async {
    if (state.pendingOffer != Offer.empty) return;

    emit(
      state.copyWith(
        pendingOffer: event.offer,
      ),
    );

    try {
      await _shoppingRepository.addOfferToCart(event.offer);

      emit(
        state.copyWith(
          selectedOffers: [event.offer, ...state.selectedOffers],
          pendingOffer: Offer.empty,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          pendingOffer: Offer.empty,
        ),
      );
    }
  }
}
