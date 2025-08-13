import 'place.dart';

class TravelDay {
  final List<Place> places;

  TravelDay({required this.places});

  Map<String, dynamic> toJson() => {
    'places': places.map((p) => p.toJson()).toList(),
  };

  factory TravelDay.fromJson(Map<String, dynamic> json) => TravelDay(
    places: (json['places'] as List)
        .map((p) => Place.fromJson(p))
        .toList(),
  );
}