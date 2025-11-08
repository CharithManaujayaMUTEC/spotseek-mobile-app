import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:spotseeker_app/models/event_model.dart';

class EventService {
  // Load events from JSON file
  // In the future, replace this with API call
  static Future<List<EventModel>> loadEvents() async {
    try {
      final String response = await rootBundle.loadString('assets/events_data.json');
      final List<dynamic> data = json.decode(response);
      return data.map((json) => EventModel.fromJson(json)).toList();
    } catch (e) {
      // Error loading events - returning empty list
      return [];
    }
  }

  // Filter events by category
  static List<EventModel> filterEventsByCategory(List<EventModel> events, String category) {
    if (category.toLowerCase() == 'all events') {
      return events;
    } else if (category.toLowerCase() == 'active events') {
      return events.where((event) => event.category == 'active').toList();
    } else if (category.toLowerCase() == 'inactive events') {
      return events.where((event) => event.category == 'inactive').toList();
    } else if (category.toLowerCase() == 'pending approval') {
      return events.where((event) => event.category == 'pending').toList();
    }
    return events;
  }

  // TODO: Replace with actual API call in the future
  // static Future<List<EventModel>> fetchEventsFromApi() async {
  //   final response = await http.get(Uri.parse('YOUR_API_ENDPOINT'));
  //   if (response.statusCode == 200) {
  //     final List<dynamic> data = json.decode(response.body);
  //     return data.map((json) => EventModel.fromJson(json)).toList();
  //   } else {
  //     throw Exception('Failed to load events');
  //   }
  // }
}
