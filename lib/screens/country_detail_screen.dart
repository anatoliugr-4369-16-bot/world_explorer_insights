import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/pins/pins_bloc.dart';
import '../bloc/pins/pins_event.dart';
import '../bloc/pins/pins_state.dart';
import '../core/themes/app_theme.dart';
import '../models/country.dart';
import '../models/pinned_country.dart';

class CountryDetailScreen extends StatefulWidget {
  final Country country;

  const CountryDetailScreen({super.key, required this.country});

  @override
  State<CountryDetailScreen> createState() => _CountryDetailScreenState();
}

class _CountryDetailScreenState extends State<CountryDetailScreen> {
  late final PinsBloc _pinsBloc;
  bool _isPinned = false;
  String _explorerNote = '';
  String _currentPinId = '';

  @override
  void initState() {
    super.initState();
    _pinsBloc = context.read<PinsBloc>();
    _checkIfPinned();
  }

  void _checkIfPinned() {
    final state = _pinsBloc.state;
    if (state is PinsLoaded) {
      final existingPin = state.pins.firstWhere(
        (pin) =>
            pin.countryCode ==
            widget.country.name, // using name as code for simplicity
        orElse: () => PinnedCountry(
          countryCode: '',
          countryName: '',
          flagUrl: '',
          explorerNote: '',
          pinnedDate: DateTime.now(),
        ),
      );
      if (existingPin.countryCode.isNotEmpty) {
        setState(() {
          _isPinned = true;
          _explorerNote = existingPin.explorerNote;
          _currentPinId = existingPin.countryCode;
        });
      }
    }
  }

  void _togglePin() async {
    if (_isPinned) {
      // Remove pin
      _pinsBloc.add(RemovePin(_currentPinId));
      setState(() {
        _isPinned = false;
        _explorerNote = '';
        _currentPinId = '';
      });
    } else {
      // Show dialog to add note
      final note = await _showNoteDialog();
      if (note != null) {
        final newPin = PinnedCountry(
          countryCode: widget.country.name,
          countryName: widget.country.name,
          flagUrl: widget.country.flagUrl,
          explorerNote: note,
          pinnedDate: DateTime.now(),
        );
        _pinsBloc.add(AddPin(newPin));
        setState(() {
          _isPinned = true;
          _explorerNote = note;
          _currentPinId = widget.country.name;
        });
      }
    }
  }

  Future<String?> _showNoteDialog({String initialNote = ''}) async {
    final controller = TextEditingController(text: initialNote);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Explorer Note'),
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
  }

  Future<void> _editNote() async {
    final newNote = await _showNoteDialog(initialNote: _explorerNote);
    if (newNote != null && newNote != _explorerNote) {
      _pinsBloc.add(UpdatePin(_currentPinId, newNote));
      setState(() {
        _explorerNote = newNote;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final country = widget.country;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero section with gradient overlay
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Fallback gradient background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.deepForest, AppTheme.darkOlive],
                      ),
                    ),
                    child: Center(
                      child: Image.network(
                        country.flagUrl,
                        width: 150,
                        height: 100,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.flag,
                              size: 80,
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ),
                  // Dark overlay for text readability
                  Container(color: Colors.black.withValues(alpha: 0.3)),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.antiqueGold,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            country.region,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          country.name,
                          style: Theme.of(context).textTheme.displayLarge
                              ?.copyWith(color: Colors.white, fontSize: 36),
                        ),
                        Text(
                          country.capital,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              BlocListener<PinsBloc, PinsState>(
                listener: (context, state) {
                  if (state is PinsError &&
                      state.message.contains('already pinned')) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Already pinned to Explorer Board'),
                      ),
                    );
                  }
                },
                child: BlocBuilder<PinsBloc, PinsState>(
                  builder: (context, state) {
                    return IconButton(
                      icon: Icon(
                        _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                      ),
                      color: _isPinned ? AppTheme.antiqueGold : Colors.white,
                      onPressed: _togglePin,
                    );
                  },
                ),
              ),
            ],
          ),

          // Details content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Quick stats cards
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        'Population',
                        '${(country.population / 1e6).toStringAsFixed(1)}M',
                        Icons.people,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                        'Area',
                        '${(country.area / 1e6).toStringAsFixed(1)}M km²',
                        Icons.landscape,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        'Capital',
                        country.capital,
                        Icons.location_city,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard('Region', country.region, Icons.map),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Interesting facts
                _sectionTitle('Interesting Facts'),
                _factTile('🌍 Fun Fact', country.getDisplayFunFact()),
                _factTile('🏛️ Landmark', country.getDisplayLandmark()),
                _factTile('📜 Motto', country.getDisplayMotto()),
                _factTile(
                  '🗣️ Native Greeting',
                  country.getDisplayNativeGreeting(),
                ),
                _factTile('🍽️ Famous Food', country.getDisplayFamousFood()),

                const SizedBox(height: 16),

                // Explorer notes section (if pinned)
                if (_isPinned) ...[
                  _sectionTitle('Explorer Notes'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _explorerNote.isEmpty
                                ? 'No notes yet.'
                                : _explorerNote,
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: _editNote,
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('Edit Note'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.antiqueGold, size: 24),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.secondaryText,
              ),
            ),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  Widget _factTile(String label, String fact) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(fact)),
        ],
      ),
    );
  }
}
