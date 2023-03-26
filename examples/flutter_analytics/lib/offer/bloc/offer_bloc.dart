import 'package:analytics_repository/analytics_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_repository/shopping_repository.dart';

part 'offer_event.dart';
part 'offer_state.dart';

class OfferBloc extends Bloc<OfferEvent, OfferState> {
  OfferBloc(this._shoppingRepository) : super(const OfferState()) {
    on<OfferStarted>(_onStarted);
    on<OfferSelected>(_onSelected);
  }

  final ShoppingRepository _shoppingRepository;

  Future<void> _onStarted(
    OfferStarted event,
    Emitter<OfferState> emit,
  ) async {
    try {
      final offers = await _shoppingRepository.fetchOffers();

      emit(
        state.copyWith(
          status: OfferStatus.success,
          offers: offers,
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
    } finally {
      emit(
        state.copyWith(
          pendingOffer: Offer.empty,
        ),
      );
    }
  }
}
