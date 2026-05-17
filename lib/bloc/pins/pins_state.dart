import '../../models/pinned_country.dart';

abstract class PinsState {}

class PinsInitial extends PinsState {}

class PinsLoading extends PinsState {}

class PinsLoaded extends PinsState {
  final List<PinnedCountry> pins;
  PinsLoaded(this.pins);
}

class PinsError extends PinsState {
  final String message;
  PinsError(this.message);
}
