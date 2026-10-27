import 'dart:typed_data';

import '../model/model_utils.dart';
import '../model/ticket.dart';
import 'api.dart';

class RegistrationService {
  static Future<Ticket> create(int eventId) async {
    final response = await ApiService.post(
      '/registrations',
      body: {'event_id': eventId},
    );
    final body = readMap(response);
    return Ticket.fromJson(readMap(body['data']));
  }

  static Future<List<Ticket>> myTickets() async {
    final response = await ApiService.get('/registrations/my-tickets');
    final body = readMap(response);
    final data = body['data'];

    final hasil = <Ticket>[];
    if (data is List) {
      for (final item in data) {
        hasil.add(Ticket.fromJson(readMap(item)));
      }
    }

    return hasil;
  }

  static Future<Ticket> detail(int id) async {
    final response = await ApiService.get('/registrations/$id');
    final body = readMap(response);
    final data = readMap(body['data']);

    if (data.isEmpty) {
      throw const ApiException(404, 'Tiket tidak ditemukan.');
    }

    return Ticket.fromJson(data);
  }

  static Future<dynamic> uploadPaymentProof({
    required int registrationId,
    required Uint8List bytes,
    required String fileName,
  }) {
    return ApiService.multipart(
      'PATCH',
      '/registrations/$registrationId/payment',
      fileField: 'payment_proof',
      fileBytes: bytes,
      fileName: fileName,
    );
  }

  static Future<dynamic> updateStatus(int registrationId, String status) {
    return ApiService.patch(
      '/registrations/$registrationId/status',
      body: {'status': status},
    );
  }

  static Future<dynamic> cancel(int registrationId) {
    return updateStatus(registrationId, 'cancelled');
  }

  static Future<dynamic> approve(int registrationId) {
    return updateStatus(registrationId, 'approved');
  }
}
