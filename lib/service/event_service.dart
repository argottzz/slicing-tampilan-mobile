import 'dart:typed_data';

import '../model/event_item.dart';
import '../model/model_utils.dart';
import '../model/ticket.dart';
import 'api.dart';

class EventListResult {
  final List<EventItem> items;
  final int page;
  final int totalPages;
  final int total;

  const EventListResult({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.total,
  });
}

class EventService {
  static Future<EventListResult> list({
    String search = '',
    String location = '',
    String sortBy = 'date',
    String order = 'asc',
    int page = 1,
    int limit = 12,
  }) async {
    final response = await ApiService.get(
      '/events',
      query: {
        'search': search,
        'location': location,
        'sort_by': sortBy,
        'order': order,
        'page': page,
        'limit': limit,
      },
    );

    final body = readMap(response);
    final data = body['data'];
    final pagination = readMap(body['pagination']);

    final items = <EventItem>[];
    if (data is List) {
      for (final item in data) {
        items.add(EventItem.fromJson(readMap(item)));
      }
    }

    return EventListResult(
      items: items,
      page: readInt(pagination['page'], page),
      totalPages: readInt(pagination['totalPages'], 1),
      total: readInt(pagination['total'], items.length),
    );
  }

  static Future<EventItem> detail(int id) async {
    final response = await ApiService.get('/events/$id');
    final body = readMap(response);
    final data = readMap(body['data']);

    if (data.isEmpty) {
      throw const ApiException(404, 'Event tidak ditemukan.');
    }

    return EventItem.fromJson(data);
  }

  static Future<dynamic> create({
    required Map<String, String> fields,
    Uint8List? bannerBytes,
    String? bannerName,
  }) {
    return ApiService.multipart(
      'POST',
      '/events',
      fields: fields,
      fileField: 'banner',
      fileBytes: bannerBytes,
      fileName: bannerName,
    );
  }

  static Future<dynamic> update({
    required int id,
    required Map<String, String> fields,
    Uint8List? bannerBytes,
    String? bannerName,
  }) {
    return ApiService.multipart(
      'PATCH',
      '/events/$id',
      fields: fields,
      fileField: 'banner',
      fileBytes: bannerBytes,
      fileName: bannerName,
    );
  }

  static Future<dynamic> delete(int id) {
    return ApiService.delete('/events/$id');
  }

  static Future<List<EventItem>> mine(int userId) async {
    final hasil = <EventItem>[];
    var page = 1;
    var totalPages = 1;

    while (page <= totalPages && page <= 10) {
      final result = await list(
        page: page,
        limit: 50,
        sortBy: 'date',
        order: 'asc',
      );

      hasil.addAll(result.items.where((event) => event.createdBy == userId));
      totalPages = result.totalPages;
      page++;
    }

    return hasil;
  }

  static Future<List<Ticket>> participants(int eventId) async {
    final response = await ApiService.get('/events/$eventId/registrations');
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
}
