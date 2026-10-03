class FlightOffer {
  final String id;
  final String airlineName;
  final String airlineCode;
  final String flightNumber;
  final String originCode;
  final String originCity;
  final String destinationCode;
  final String destinationCity;
  final String departureTime;
  final String arrivalTime;
  final String duration;
  final int stops;
  final String cabinClass;
  final int price;
  final bool refundable;
  final String includedBaggage;
  final String aircraftType;
  final String departureTerminal;
  final String arrivalTerminal;
  final bool mealIncluded;

  const FlightOffer({
    required this.id,
    required this.airlineName,
    required this.airlineCode,
    required this.flightNumber,
    required this.originCode,
    required this.originCity,
    required this.destinationCode,
    required this.destinationCity,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.stops,
    required this.cabinClass,
    required this.price,
    required this.refundable,
    required this.includedBaggage,
    this.aircraftType = 'Airbus A320neo',
    this.departureTerminal = 'T1',
    this.arrivalTerminal = 'T2',
    this.mealIncluded = false,
  });

  String get stopsLabel => stops == 0 ? 'Non-stop' : (stops == 1 ? '1 Stop' : '$stops Stops');

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'airlineName': airlineName,
      'airlineCode': airlineCode,
      'flightNumber': flightNumber,
      'originCode': originCode,
      'originCity': originCity,
      'destinationCode': destinationCode,
      'destinationCity': destinationCity,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'duration': duration,
      'stops': stops,
      'cabinClass': cabinClass,
      'price': price,
      'refundable': refundable,
      'includedBaggage': includedBaggage,
      'aircraftType': aircraftType,
      'departureTerminal': departureTerminal,
      'arrivalTerminal': arrivalTerminal,
      'mealIncluded': mealIncluded,
    };
  }

  factory FlightOffer.fromMap(Map<String, dynamic> map) {
    String fromCity = map['originCity'] ?? '';
    if (fromCity.isEmpty && map['from'] != null) {
      fromCity = (map['from'] as String).split('(').first.trim();
    }
    String toCity = map['destinationCity'] ?? '';
    if (toCity.isEmpty && map['to'] != null) {
      toCity = (map['to'] as String).split('(').first.trim();
    }

    return FlightOffer(
      id: map['id'] ?? '',
      airlineName: map['airlineName'] ?? map['airline'] ?? '',
      airlineCode: map['airlineCode'] ?? '',
      flightNumber: map['flightNumber'] ?? '',
      originCode: map['originCode'] ?? '',
      originCity: fromCity,
      destinationCode: map['destinationCode'] ?? '',
      destinationCity: toCity,
      departureTime: map['departureTime'] ?? '',
      arrivalTime: map['arrivalTime'] ?? '',
      duration: map['duration'] ?? '',
      stops: (map['stops'] as num?)?.toInt() ?? 0,
      cabinClass: map['cabinClass'] ?? 'Economy',
      price: (map['price'] as num?)?.toInt() ?? 0,
      refundable: map['refundable'] ?? true,
      includedBaggage: map['includedBaggage'] ?? '15 kg Check-in',
      aircraftType: map['aircraftType'] ?? map['aircraft'] ?? 'Airbus A320neo',
      departureTerminal: map['departureTerminal'] ?? map['terminal'] ?? 'T1',
      arrivalTerminal: map['arrivalTerminal'] ?? 'T2',
      mealIncluded: map['mealIncluded'] ?? false,
    );
  }
}

class FlightSearchCriteria {
  final String from;
  final String fromCode;
  final String to;
  final String toCode;
  final DateTime departureDate;
  final DateTime? returnDate;
  final int tripType; // 0 = One Way, 1 = Round Trip
  final int adults;
  final int children;
  final int infants;
  final String cabinClass;

  const FlightSearchCriteria({
    required this.from,
    required this.fromCode,
    required this.to,
    required this.toCode,
    required this.departureDate,
    this.returnDate,
    required this.tripType,
    required this.adults,
    required this.children,
    required this.infants,
    required this.cabinClass,
  });

  int get totalPassengers => adults + children + infants;
}
