class Place {
  final String name;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String contentId;
  final String contentTypeId;
  final String address;
  int? orderInDay = 0;
  int? dayNumber = 0;

  Place({
    required this.name,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.contentId,
    required this.contentTypeId,
    required this.address,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'imageUrl': imageUrl,
    'latitude': latitude,
    'longitude': longitude,
    'contentId': contentId,
    'contentTypeId': contentTypeId,
    'address': address,
  };

  factory Place.fromJson(Map<String, dynamic> json) => Place(
    name: json['name'],
    imageUrl: json['imageUrl'],
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    contentId: json['contentId'],
    contentTypeId: json['contentTypeId'],
    address: json['address'],
  );
}