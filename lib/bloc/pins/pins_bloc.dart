import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/pinned_country.dart';
import '../../services/pins_storage_service.dart';
import 'pins_event.dart';
import 'pins_state.dart';

class PinsBloc extends Bloc<PinsEvent, PinsState> {
  final PinsStorageService storage;

  PinsBloc({required this.storage}) : super(PinsInitial()) {
    on<LoadPins>(_onLoadPins);
    on<AddPin>(_onAddPin);
    on<UpdatePin>(_onUpdatePin);
    on<RemovePin>(_onRemovePin);
  }

  Future<void> _onLoadPins(LoadPins event, Emitter<PinsState> emit) async {
    emit(PinsLoading());
    try {
      final pins = await storage.loadPins();
      emit(PinsLoaded(pins));
    } catch (e) {
      emit(PinsError(e.toString()));
    }
  }

  Future<void> _onAddPin(AddPin event, Emitter<PinsState> emit) async {
    final currentState = state;
    if (currentState is PinsLoaded) {
      final exists =
          currentState.pins.any((p) => p.countryCode == event.pin.countryCode);
      if (!exists) {
        final updatedPins = List<PinnedCountry>.from(currentState.pins)
          ..add(event.pin);
        await storage.savePins(updatedPins);
        emit(PinsLoaded(updatedPins));
      } else {
        emit(PinsError('Country already pinned'));
        emit(PinsLoaded(currentState.pins));
      }
    }
  }

  Future<void> _onUpdatePin(UpdatePin event, Emitter<PinsState> emit) async {
    final currentState = state;
    if (currentState is PinsLoaded) {
      final updatedPins = currentState.pins.map((pin) {
        if (pin.countryCode == event.countryCode) {
          return PinnedCountry(
            countryCode: pin.countryCode,
            countryName: pin.countryName,
            flagUrl: pin.flagUrl,
            explorerNote: event.newNote,
            pinnedDate: pin.pinnedDate,
          );
        }
        return pin;
      }).toList();
      await storage.savePins(updatedPins);
      emit(PinsLoaded(updatedPins));
    }
  }

  Future<void> _onRemovePin(RemovePin event, Emitter<PinsState> emit) async {
    final currentState = state;
    if (currentState is PinsLoaded) {
      final updatedPins = currentState.pins
          .where((p) => p.countryCode != event.countryCode)
          .toList();
      await storage.savePins(updatedPins);
      emit(PinsLoaded(updatedPins));
    }
  }
}
