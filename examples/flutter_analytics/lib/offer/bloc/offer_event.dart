part of 'offer_bloc.dart';

abstract class OfferEvent extends Equatable {
  const OfferEvent();

  @override
  List<Object> get props => [];
}

class OfferStarted extends OfferEvent {
  const OfferStarted();
}

class OfferSelected extends OfferEvent with Analytic {
  const OfferSelected(this.offer);

  final Offer offer;

  @override
  String get eventName => 'offer_selected';

  @override
  Map<String, dynamic> get parameters => {'offer_id': offer.id};

  @override
  List<Object> get props => [offer];
}
