class EventModel {
  final int id;
  final String uid;
  final String name;
  final String description;
  final String type;
  final String subType;
  final String organizer;
  final String managerName;
  final String startDate;
  final String endDate;
  final String status;
  final String thumbnailImg;
  final String bannerImg;
  final bool featured;
  final String venueName;
  final String venueLocationUrl;
  final bool freeSeating;
  final String currency;
  final List<TicketPackage> ticketPackages;
  final String? externalEventId;

  /// Returns true if this event is from the legacy web API (has external_event_id)
  bool get isLegacyEvent =>
      externalEventId != null && externalEventId!.isNotEmpty;

  EventModel({
    required this.id,
    required this.uid,
    required this.name,
    required this.description,
    required this.type,
    required this.subType,
    required this.organizer,
    required this.managerName,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.thumbnailImg,
    required this.bannerImg,
    required this.featured,
    required this.venueName,
    required this.venueLocationUrl,
    required this.freeSeating,
    required this.currency,
    required this.ticketPackages,
    this.externalEventId,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    // Handle manager field - can be a string ID or an object with 'name'
    String managerName = '';
    final managerField = json['manager'];
    if (managerField is String) {
      managerName = managerField;
    } else if (managerField is Map<String, dynamic>) {
      managerName = managerField['name'] as String? ?? '';
    }

    // Handle venue field - can be a string ID or an object
    String venueName = '';
    String venueLocationUrl = '';
    final venueField = json['venue'];
    if (venueField is String) {
      venueName = venueField;
    } else if (venueField is Map<String, dynamic>) {
      venueName = venueField['name'] as String? ?? '';
      venueLocationUrl = venueField['location_url'] as String? ?? '';
    }
    // Handle venue_id field as fallback
    if (venueName.isEmpty && json['venue_id'] != null) {
      venueName = json['venue_id'].toString();
    }

    return EventModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      uid: json['uid'] as String? ?? '',
      name: json['name'] as String,
      description:
          json['description'] as String? ?? json['json_desc'] as String? ?? '',
      type: json['type'] as String? ?? '',
      subType: json['sub_type'] as String? ?? '',
      organizer: json['organizer'] as String? ?? '',
      managerName: managerName,
      startDate: json['start_date'] as String? ?? '',
      endDate: json['end_date'] as String? ?? '',
      status: json['status'] as String? ?? '',
      thumbnailImg: json['thumbnail_img'] as String? ?? '',
      bannerImg: json['banner_img'] as String? ?? '',
      featured: json['featured'] as bool? ?? false,
      venueName: venueName,
      venueLocationUrl: venueLocationUrl,
      freeSeating: json['free_seating'] as bool? ?? false,
      currency: json['currency'] as String? ?? 'LKR',
      externalEventId: json['external_event_id'] != null
          ? json['external_event_id'].toString()
          : null,
      ticketPackages: (json['ticket_packages'] as List<dynamic>?)
              ?.map((pkg) => TicketPackage.fromJson(pkg))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'name': name,
      'description': description,
      'type': type,
      'sub_type': subType,
      'organizer': organizer,
      'manager': {'name': managerName},
      'start_date': startDate,
      'end_date': endDate,
      'status': status,
      'thumbnail_img': thumbnailImg,
      'banner_img': bannerImg,
      'featured': featured,
      'venue': {'name': venueName, 'location_url': venueLocationUrl},
      'free_seating': freeSeating,
      'currency': currency,
      'external_event_id': externalEventId,
      'ticket_packages': ticketPackages.map((pkg) => pkg.toJson()).toList(),
    };
  }

  // Helper getters for compatibility with UI
  String get category {
    switch (status.toLowerCase()) {
      case 'ongoing':
      case 'active':
        return 'active';
      case 'pending':
      case 'pending_approval':
        return 'pending';
      case 'inactive':
      case 'completed':
        return 'inactive';
      default:
        return 'active';
    }
  }

  String get statusType {
    switch (status.toLowerCase()) {
      case 'ongoing':
      case 'active':
        return 'success';
      case 'pending':
      case 'pending_approval':
        return 'warning';
      case 'inactive':
      case 'completed':
        return 'error';
      default:
        return 'success';
    }
  }

  String get date => startDate.split(' ').first;
  String get startTime => startDate.split(' ').elementAtOrNull(1) ?? '';
  String get endTime => endDate.split(' ').elementAtOrNull(1) ?? '';
  String get venue => venueName;
  String get imageUrl => thumbnailImg;
}

class TicketPackage {
  final int id;
  final String name;
  final String price;
  final String desc;
  final bool soldOut;
  final bool active;
  final bool freeSeating;
  final bool promo;

  TicketPackage({
    required this.id,
    required this.name,
    required this.price,
    required this.desc,
    required this.soldOut,
    required this.active,
    required this.freeSeating,
    required this.promo,
  });

  factory TicketPackage.fromJson(Map<String, dynamic> json) {
    return TicketPackage(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] as String? ?? '',
      price: json['price'] as String? ?? '0.00',
      desc: json['desc'] as String? ?? '',
      soldOut: json['sold_out'] as bool? ?? false,
      active: json['active'] as bool? ?? true,
      freeSeating: json['free_seating'] as bool? ?? false,
      promo: json['promo'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'desc': desc,
      'sold_out': soldOut,
      'active': active,
      'free_seating': freeSeating,
      'promo': promo,
    };
  }
}
