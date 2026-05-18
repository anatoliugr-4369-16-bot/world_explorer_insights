import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/pins/pins_bloc.dart';
import '../bloc/pins/pins_event.dart';
import '../bloc/pins/pins_state.dart';
import '../core/themes/app_theme.dart';
import '../models/country.dart';
import '../models/pinned_country.dart';

class CountryIntelligencePage extends StatefulWidget {
  final Country country;
  final List<Country> allCountries;
  const CountryIntelligencePage(
      {super.key, required this.country, required this.allCountries});

  @override
  State<CountryIntelligencePage> createState() =>
      _CountryIntelligencePageState();
}

class _CountryIntelligencePageState extends State<CountryIntelligencePage> {
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
        (pin) => pin.countryCode == widget.country.name,
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
      _pinsBloc.add(RemovePin(_currentPinId));
      setState(() {
        _isPinned = false;
        _explorerNote = '';
        _currentPinId = '';
      });
    } else {
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
        title: const Text('Research Note'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Add analytical notes about this country...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Save')),
        ],
      ),
    );
  }

  Future<void> _editNote() async {
    final newNote = await _showNoteDialog(initialNote: _explorerNote);
    if (newNote != null && newNote != _explorerNote) {
      _pinsBloc.add(UpdatePin(_currentPinId, newNote));
      setState(() => _explorerNote = newNote);
    }
  }

  void _shareInsight() {
    final insight = '🌍 ${widget.country.name}\n'
        'Population: ${widget.country.population}\n'
        'Area: ${widget.country.area} km²\n'
        'Population Rank: #${widget.country.populationRank ?? "N/A"}\n'
        'Area Rank: #${widget.country.areaRank ?? "N/A"}\n'
        'Density: ${widget.country.populationDensity.toStringAsFixed(1)}/km²';
    Clipboard.setData(ClipboardData(text: insight));
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insight copied to clipboard')));
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.country;
    final all = widget.allCountries;
    final largest = all.reduce((a, b) => a.area > b.area ? a : b);
    final mostPopulated =
        all.reduce((a, b) => a.population > b.population ? a : b);
    final mostDense =
        all.reduce((a, b) => a.populationDensity > b.populationDensity ? a : b);
    final worldAvgDensity =
        all.map((c) => c.populationDensity).reduce((a, b) => a + b) /
            all.length;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.deepForest, AppTheme.darkOlive],
                      ),
                    ),
                    child: Center(
                      child: Image.network(c.flagUrl,
                          width: 150,
                          height: 100,
                          errorBuilder: (_, __, ___) => const Icon(Icons.flag,
                              size: 80, color: Colors.white)),
                    ),
                  ),
                  Container(color: Colors.black.withValues(alpha: 0.4)),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                              color: AppTheme.antiqueGold,
                              borderRadius: BorderRadius.circular(20)),
                          child: Text(c.region,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 12),
                        Text(c.name,
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(color: Colors.white, fontSize: 36)),
                        Text(c.capital,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 18)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                  icon: Icon(
                      _isPinned ? Icons.push_pin : Icons.push_pin_outlined),
                  color: _isPinned ? AppTheme.antiqueGold : Colors.white,
                  onPressed: _togglePin),
              IconButton(
                  icon: const Icon(Icons.share), onPressed: _shareInsight),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  children: [
                    Expanded(
                        child: _analyticsCard(
                            'Population',
                            '${(c.population / 1e6).toStringAsFixed(1)}M',
                            Icons.people,
                            '#${c.populationRank} worldwide')),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _analyticsCard(
                            'Area',
                            '${(c.area / 1e6).toStringAsFixed(2)}M km²',
                            Icons.landscape,
                            '#${c.areaRank} worldwide')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _analyticsCard(
                            'Density',
                            '${c.populationDensity.toStringAsFixed(1)}/km²',
                            Icons.straighten,
                            '#${c.densityRank} worldwide')),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _analyticsCard('Capital', c.capital,
                            Icons.location_city, c.subregion)),
                  ],
                ),
                const SizedBox(height: 20),
                if (c.regionalPopulationRank != null)
                  _insightTile(
                      'Regional Population Rank',
                      '#${c.regionalPopulationRank} in ${c.region}',
                      Icons.people_outline),
                if (c.regionalAreaRank != null)
                  _insightTile('Regional Area Rank',
                      '#${c.regionalAreaRank} in ${c.region}', Icons.landscape),
                const SizedBox(height: 12),
                const Text('Global Comparisons',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _comparisonTile('vs Largest Country (${largest.name})', c.area,
                    largest.area, 'Area (km²)'),
                _comparisonTile(
                    'vs Most Populated (${mostPopulated.name})',
                    c.population.toDouble(),
                    mostPopulated.population.toDouble(),
                    'Population'),
                _comparisonTile(
                    'vs Most Dense (${mostDense.name})',
                    c.populationDensity,
                    mostDense.populationDensity,
                    'Density (people/km²)'),
                _comparisonTile('vs World Avg Density', c.populationDensity,
                    worldAvgDensity, 'Density (people/km²)'),
                const SizedBox(height: 16),
                if (c.languages.isNotEmpty)
                  _chipSection('Languages', c.languages),
                if (c.currencies.isNotEmpty)
                  _chipSection('Currencies', c.currencies),
                if (c.timezones.isNotEmpty)
                  _chipSection('Timezones', c.timezones),
                if (c.borders.isNotEmpty) ...[
                  const Text('Bordering Countries',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                      spacing: 8,
                      children: c.borders
                          .map((bc) => Chip(
                              label: Text(bc),
                              backgroundColor: AppTheme.mutedBeige))
                          .toList()),
                  const SizedBox(height: 16),
                ],
                if (c.latlng.length == 2)
                  _infoRow(Icons.gps_fixed,
                      'Coordinates: ${c.latlng[0].toStringAsFixed(4)}, ${c.latlng[1].toStringAsFixed(4)}'),
                const SizedBox(height: 8),
                if (_isPinned) ...[
                  const Divider(),
                  const Text('Research Notes',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              _explorerNote.isEmpty
                                  ? 'No notes added.'
                                  : _explorerNote,
                              style:
                                  const TextStyle(fontStyle: FontStyle.italic)),
                          const SizedBox(height: 8),
                          Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                  onPressed: _editNote,
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text('Edit Note'))),
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

  Widget _analyticsCard(String label, String value, IconData icon, String sub) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.antiqueGold, size: 24),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.secondaryText)),
            Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            if (sub.isNotEmpty)
              Text(sub,
                  style: const TextStyle(
                      fontSize: 10, color: AppTheme.secondaryText)),
          ],
        ),
      ),
    );
  }

  Widget _insightTile(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.antiqueGold),
          const SizedBox(width: 8),
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _comparisonTile(
      String label, double countryValue, double compareValue, String metric) {
    double ratio =
        compareValue > 0 ? (countryValue / compareValue).clamp(0.0, 1.0) : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 12, color: AppTheme.secondaryText)),
          LinearProgressIndicator(
              value: ratio,
              backgroundColor: AppTheme.mutedBeige,
              color: AppTheme.antiqueGold),
          const SizedBox(height: 4),
          Text(
              '${countryValue.toStringAsFixed(1)} vs ${compareValue.toStringAsFixed(1)} $metric',
              style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _chipSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
            spacing: 8,
            children: items
                .map((e) =>
                    Chip(label: Text(e), backgroundColor: AppTheme.mutedBeige))
                .toList()),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(children: [
      Icon(icon, size: 16, color: AppTheme.secondaryText),
      const SizedBox(width: 8),
      Expanded(child: Text(text))
    ]);
  }
}
