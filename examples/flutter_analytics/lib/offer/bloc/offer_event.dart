part of 'offer_bloc.dart';

abstract class OfferEvent extends Equatable {
  const OfferEvent();

  @override
  List<Object> get props => [];
}

class _OfferCartProductsChanged extends OfferEvent {
  const _OfferCartProductsChanged(this.cartProducts);

  final List<Product> cartProducts;

  @override
  List<Object> get props => [cartProducts];
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
