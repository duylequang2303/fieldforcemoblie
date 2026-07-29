class ScheduleProperty {
  final int id;
  final String address;
  final String suburb;
  final String postcode;
  final String ownerName;
  final String? imageUrl;
  final double? lat;
  final double? lng;
  final String? phone;
  final String? email;

  const ScheduleProperty({
    required this.id,
    required this.address,
    required this.suburb,
    required this.postcode,
    required this.ownerName,
    this.imageUrl,
    this.lat,
    this.lng,
    this.phone,
    this.email,
  });
}
