class Country {
  final String name;
  final String capital;
  final String region;
  final int population;
  final double area;
  final String flagUrl;
  final String? funFact;
  final String? landmark;
  final String? motto;
  final String? nativeGreeting;
  final String? famousFood;

  Country({
    required this.name,
    required this.capital,
    required this.region,
    required this.population,
    required this.area,
    required this.flagUrl,
    this.funFact,
    this.landmark,
    this.motto,
    this.nativeGreeting,
    this.famousFood,
  });

  // Factory constructor for parsing REST Countries API (v3.1)
  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name']['common'] ?? 'Unknown',
      capital: (json['capital'] as List?)?.isNotEmpty == true
          ? json['capital'][0]
          : 'No capital',
      region: json['region'] ?? 'Unknown',
      population: json['population'] ?? 0,
      area: (json['area'] ?? 0).toDouble(),
      flagUrl: json['flags']?['png'] ?? '',
    );
  }

  // Helper for static fun facts (enriched)
  String getDisplayFunFact() {
    final facts = {
      'Russia': 'Spans 11 time zones.',
      'Canada': 'Has the world\'s longest coastline.',
      'Ethiopia': 'Uses a unique 13-month calendar.',
      'Japan': 'Has over 6,800 islands.',
      'France': 'Most visited country in the world.',
      'Australia':
          'Home to the world\'s largest living structure (Great Barrier Reef).',
      'India': 'Has the world\'s highest cricket ground (in Chail).',
      'USA': 'Has the world\'s largest economy.',
      'Brazil': 'Contains most of the Amazon rainforest.',
      'China': 'Most populous country.',
    };
    return facts[name] ?? 'One of the most fascinating countries on Earth.';
  }

  String getDisplayLandmark() {
    final landmarks = {
      'Russia': 'Red Square, Moscow',
      'Canada': 'Niagara Falls',
      'Ethiopia': 'Lalibela Rock Churches',
      'Japan': 'Mount Fuji',
      'France': 'Eiffel Tower',
      'Australia': 'Sydney Opera House',
      'India': 'Taj Mahal',
      'USA': 'Statue of Liberty',
      'Brazil': 'Christ the Redeemer',
      'China': 'Great Wall',
    };
    return landmarks[name] ?? 'A remarkable landmark awaits.';
  }

  String getDisplayMotto() {
    final mottos = {
      'France': 'Liberty, Equality, Fraternity',
      'USA': 'In God We Trust',
      'Brazil': 'Order and Progress',
      'India': 'Satyameva Jayate (Truth Alone Triumphs)',
      'Canada': 'From Sea to Sea',
    };
    return mottos[name] ?? 'A nation of pride and heritage.';
  }

  String getDisplayNativeGreeting() {
    final greetings = {
      'France': 'Bonjour!',
      'Japan': 'Konnichiwa!',
      'Italy': 'Ciao!',
      'Spain': '¡Hola!',
      'Germany': 'Hallo!',
      'China': 'Nǐ hǎo!',
      'India': 'Namaste!',
      'Russia': 'Zdravstvuyte!',
      'Ethiopia': 'Selam!',
    };
    return greetings[name] ?? 'Welcome in their native tongue.';
  }

  String getDisplayFamousFood() {
    final foods = {
      'France': 'Croissant, Baguette, Cheese',
      'Japan': 'Sushi, Ramen, Tempura',
      'Italy': 'Pizza, Pasta, Gelato',
      'India': 'Biryani, Curry, Naan',
      'Mexico': 'Tacos, Guacamole',
      'China': 'Peking Duck, Dumplings',
    };
    return foods[name] ?? 'Delicious local cuisine.';
  }
}
