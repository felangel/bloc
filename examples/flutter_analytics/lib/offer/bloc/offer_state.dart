part of 'offer_bloc.dart';

enum OfferStatus {
  initial,
  loading,
  success,
  failure,
}

class OfferState extends Equatable {
  const OfferState({
    this.status = OfferStatus.loading,
    this.offers = const [],
    this.pendingOffer = Offer.empty,
  });

  final OfferStatus status;
  final List<Offer> offers;
  final Offer pendingOffer;

  OfferState copyWith({
    OfferStatus? status,
    List<Offer>? offers,
    Offer? pendingOffer,
  }) {
    return OfferState(
      status: status ?? this.status,
      offers: offers ?? this.offers,
      pendingOffer: pendingOffer ?? this.pendingOffer,
    );
  }

  @override
  List<Object?> get props => [
        status,
        offers,
        pendingOffer,
      ];
}
