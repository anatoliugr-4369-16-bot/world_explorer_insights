import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/pins/pins_bloc.dart';
import '../bloc/pins/pins_event.dart';
import '../bloc/pins/pins_state.dart';
import '../core/themes/app_theme.dart';
import '../models/pinned_country.dart';

class ExplorerBoardScreen extends StatefulWidget {
  const ExplorerBoardScreen({super.key});

  @override
  State<ExplorerBoardScreen> createState() => _ExplorerBoardScreenState();
}

class _ExplorerBoardScreenState extends State<ExplorerBoardScreen> {
  late final PinsBloc _pinsBloc;

  @override
  void initState() {
    super.initState();
    _pinsBloc = context.read<PinsBloc>();
    _pinsBloc.add(LoadPins());
  }

  Future<void> _editNote(PinnedCountry pin) async {
    final controller = TextEditingController(text: pin.explorerNote);
    final newNote = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Explorer Note'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Why is this country remarkable?',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newNote != null && newNote != pin.explorerNote) {
      _pinsBloc.add(UpdatePin(pin.countryCode, newNote));
    }
  }

  void _removePin(String countryCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from Explorer Board'),
        content: const Text('Are you sure you want to remove this pin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _pinsBloc.add(RemovePin(countryCode));
              Navigator.pop(context);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorer Board'),
        backgroundColor: AppTheme.deepForest,
      ),
      body: BlocBuilder<PinsBloc, PinsState>(
        builder: (context, state) {
          if (state is PinsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PinsError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is PinsLoaded) {
            final pins = state.pins;
            if (pins.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.push_pin_outlined,
                      size: 80,
                      color: AppTheme.secondaryText,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No pinned countries yet.\nTap the pin icon on any country detail screen.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.secondaryText),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pins.length,
              itemBuilder: (context, index) {
                final pin = pins[index];
                return _buildPinCard(pin);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildPinCard(PinnedCountry pin) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Flag
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    pin.flagUrl,
                    width: 50,
                    height: 35,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.flag, size: 35),
                  ),
                ),
                const SizedBox(width: 12),
                // Country name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pin.countryName,
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pinned: ${_formatDate(pin.pinnedDate)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                // Action buttons
                IconButton(
                  icon: const Icon(Icons.edit, color: AppTheme.dustyBrown),
                  onPressed: () => _editNote(pin),
                  tooltip: 'Edit note',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _removePin(pin.countryCode),
                  tooltip: 'Remove pin',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.mutedBeige,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.note, size: 20, color: AppTheme.dustyBrown),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pin.explorerNote.isEmpty
                          ? 'No explorer note added.'
                          : pin.explorerNote,
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
