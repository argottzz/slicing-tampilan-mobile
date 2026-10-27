import 'model_utils.dart';

class EventItem {
  final int id;
  final int createdBy;
  final String title;
  final String description;
  final String date;
  final String location;
  final String? bannerUrl;
  final double price;
  final int quota;
  final int taken;
  final int availableQuota;
  final String organizerName;
  final String organizerEmail;

  const EventItem({
    required this.id,
    required this.createdBy,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.bannerUrl,
    required this.price,
    required this.quota,
    required this.taken,
    required this.availableQuota,
    required this.organizerName,
    required this.organizerEmail,
  });

  bool get gratis => price <= 0;
  bool get kuotaHabis => availableQuota <= 0;

  factory EventItem.fromJson(Map<String, dynamic> json) {
    final quota = readInt(json['quota']);
    final taken = readInt(json['taken']);
    final available = json['available_quota'] == null
        ? quota - taken
        : readInt(json['available_quota']);

    return EventItem(
      id: readInt(json['id']),
      createdBy: readInt(json['created_by']),
      title: readText(json['title'], 'Tanpa judul'),
      description: readText(json['description']),
      date: readText(json['date']),
      location: readText(json['location'], '-'),
      bannerUrl: readNullableText(json['banner_url']),
      price: readDouble(json['price']),
      quota: quota,
      taken: taken,
      availableQuota: available < 0 ? 0 : available,
      organizerName: readText(json['organizer_name'], 'Organizer'),
      organizerEmail: readText(json['organizer_email']),
    );
  }
}
