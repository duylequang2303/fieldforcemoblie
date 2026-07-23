class ScheduleProperty {
  final String address;
  final String suburb;
  final String postcode;
  final String ownerName;
  final String? imageUrl;

  const ScheduleProperty({
    required this.address,
    required this.suburb,
    required this.postcode,
    required this.ownerName,
    this.imageUrl,
  });
}
