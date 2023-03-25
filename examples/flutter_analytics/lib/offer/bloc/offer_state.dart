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
    this.allOffers = const [],
    this.selectedOffers = const [],
    this.pendingOffer = Offer.empty,
  });

  final OfferStatus status;
  final List<Offer> allOffers;
  final List<Offer> selectedOffers;
  final Offer pendingOffer;

  OfferState copyWith({
    OfferStatus? status,
    List<Offer>? allOffers,
    List<Offer>? selectedOffers,
    Offer? pendingOffer,
  }) {
    return OfferState(
      status: status ?? this.status,
      allOffers: allOffers ?? this.allOffers,
      selectedOffers: selectedOffers ?? this.selectedOffers,
      pendingOffer: pendingOffer ?? this.pendingOffer,
    );
  }

  @override
  List<Object?> get props => [
        status,
        allOffers,
        selectedOffers,
        pendingOffer,
      ];
}
