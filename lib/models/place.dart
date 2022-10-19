class Place {
  // String? name, display_name, lat, lon, category, type;
  String place_id, description;
  // Address? address;

  Place({
    required this.place_id,
    required this.description,
    // required this.lat,
    // required this.lon,
    // required this.name,
    // required this.osm_id,
    // required this.place_id,
    // required this.type,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
        // address: Address.fromJson(json['address']),
        // category: json['category'],
        // lat: json['lat'],
        // lon: json['lon'],
        // name: json['name'],
        // osm_id: json['osm_id'],
        place_id: json['place_id'],
        description: json['description']);
  }
}
