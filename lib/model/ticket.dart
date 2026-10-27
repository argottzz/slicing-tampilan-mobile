import 'model_utils.dart';

class Ticket {
  final int id;
  final int eventId;
  final int userId;
  final String status;
  final String? paymentProofUrl;
  final String title;
  final String date;
  final String location;
  final String? bannerUrl;
  final double price;
  final String userName;
  final String userEmail;

  const Ticket({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.status,
    required this.paymentProofUrl,
    required this.title,
    required this.date,
    required this.location,
    required this.bannerUrl,
    required this.price,
    required this.userName,
    required this.userEmail,
  });

  bool get pending => status == 'pending';
  bool get approved => status == 'approved';
  bool get cancelled => status == 'cancelled';

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: readInt(json['id']),
      eventId: readInt(json['event_id']),
      userId: readInt(json['user_id']),
      status: readText(json['status'], 'pending'),
      paymentProofUrl: readNullableText(json['payment_proof_url']),
      title: readText(json['title'], 'Event #${readInt(json['event_id'])}'),
      date: readText(json['date']),
      location: readText(json['location'], '-'),
      bannerUrl: readNullableText(json['banner_url']),
      price: readDouble(json['price']),
      userName: readText(json['user_name']),
      userEmail: readText(json['user_email']),
    );
  }
}
