class ScheduleVisit {
  final String address;
  final String suburb;
  final String customerName;
  final int hours;
  final double price;
  final String dueDate;
  final String? note;

  const ScheduleVisit({
    required this.address,
    required this.suburb,
    required this.customerName,
    required this.hours,
    required this.price,
    required this.dueDate,
    this.note,
  });
}