import '../../models/pinned_country.dart';

abstract class PinsEvent {}

class LoadPins extends PinsEvent {}

class AddPin extends PinsEvent {
  final PinnedCountry pin;
  AddPin(this.pin);
}

class UpdatePin extends PinsEvent {
  final String countryCode;
  final String newNote;
  UpdatePin(this.countryCode, this.newNote);
}

class RemovePin extends PinsEvent {
  final String countryCode;
  RemovePin(this.countryCode);
}
