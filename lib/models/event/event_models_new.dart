import 'package:json_annotation/json_annotation.dart';

part 'event_models_new.g.dart';

/// Promotion Model
@JsonSerializable()
class Promotion {
  final String? promoCode;
  final String? discAmount;
  final bool discAmtIsPercentage;
  final bool isPerTicket;
  final String? minTickets;
  final String? minAmount;
  final String? maxTickets;
  final String? maxAmount;
  final String? startDateTime;
  final String? endDateTime;
  final bool isAutoApply;
  final String? redeems;

  Promotion({
    this.promoCode,
    this.discAmount,
    this.discAmtIsPercentage = false,
    this.isPerTicket = false,
    this.minTickets,
    this.minAmount,
    this.maxTickets,
    this.maxAmount,
    this.startDateTime,
    this.endDateTime,
    this.isAutoApply = false,
    this.redeems,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) =>
      _$PromotionFromJson(json);

  Map<String, dynamic> toJson() => _$PromotionToJson(this);
}

/// Ticket Package Model (Invoice)
@JsonSerializable()
class TicketPackage {
  final String packageName;
  final String? packageDesc;
  final String packagePrice;
  final String packageQty;
  final String packageAvailQty;
  final String? packageResQty;
  final String? packageAllocSeats;
  final String? packageAvailSeats;
  final bool packageFreeSeating;
  final bool sold_out;
  final bool promotions;
  final List<Promotion>? promotion;
  final bool active;
  final bool deleted;
  final int maxBuyTickets;

  TicketPackage({
    required this.packageName,
    this.packageDesc,
    required this.packagePrice,
    required this.packageQty,
    required this.packageAvailQty,
    this.packageResQty,
    this.packageAllocSeats,
    this.packageAvailSeats,
    this.packageFreeSeating = true,
    this.sold_out = false,
    this.promotions = false,
    this.promotion,
    this.active = true,
    this.deleted = false,
    this.maxBuyTickets = 0,
  });

  factory TicketPackage.fromJson(Map<String, dynamic> json) =>
      _$TicketPackageFromJson(json);

  Map<String, dynamic> toJson() => _$TicketPackageToJson(this);
}

/// Invitation Package Model
@JsonSerializable()
class InvitationPackage {
  final String? packageName;
  final String? packageDesc;
  final String? packageQty;
  final String? packageAvailQty;
  final String? packageSoldQty;
  final String? packageAllocSeats;
  final bool active;
  final bool deleted;
  final bool packageFreeSeating;

  InvitationPackage({
    this.packageName,
    this.packageDesc,
    this.packageQty,
    this.packageAvailQty,
    this.packageSoldQty,
    this.packageAllocSeats,
    this.active = true,
    this.deleted = false,
    this.packageFreeSeating = true,
  });

  factory InvitationPackage.fromJson(Map<String, dynamic> json) =>
      _$InvitationPackageFromJson(json);

  Map<String, dynamic> toJson() => _$InvitationPackageToJson(this);
}

/// Event Addon Model
@JsonSerializable()
class EventAddon {
  final String? addonName;
  final String? addonCategory;
  final String? addonPrice;
  final bool deleted;

  EventAddon({
    this.addonName,
    this.addonCategory,
    this.addonPrice,
    this.deleted = false,
  });

  factory EventAddon.fromJson(Map<String, dynamic> json) =>
      _$EventAddonFromJson(json);

  Map<String, dynamic> toJson() => _$EventAddonToJson(this);
}

/// Payment Gateway Model
@JsonSerializable()
class PaymentGateway {
  final String? id;
  final String? name;
  final double commission_rate;
  final bool apply_handling_fee;
  final bool deleted;

  PaymentGateway({
    this.id,
    this.name,
    this.commission_rate = 0,
    this.apply_handling_fee = true,
    this.deleted = false,
  });

  factory PaymentGateway.fromJson(Map<String, dynamic> json) =>
      _$PaymentGatewayFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentGatewayToJson(this);
}

/// Complete Event Model (for creating/updating events)
@JsonSerializable()
class EventCreate {
  final String name;
  final String description; // Rich JSON as string
  final String organizer;
  final String manager;
  final String start_date; // "2025-10-28 12:00"
  final String end_date;
  final String type;
  final String sub_type;
  final bool featured;
  final bool free_seating;
  final String venue; // venue ID as string
  final List<TicketPackage> invoice; // Ticket packages
  final String? sold_out_msg;
  final String? handling_cost;
  final bool handling_cost_perc;
  final String currency;
  final bool invitation_feature;
  final String? invitation_count;
  final List<InvitationPackage>? invitation_packages;
  final bool addons_feature;
  final List<EventAddon>? addons;
  final String? trailer_url;
  final List<PaymentGateway> payment_gateways;
  final List<String> analytics_ids;

  EventCreate({
    required this.name,
    required this.description,
    required this.organizer,
    required this.manager,
    required this.start_date,
    required this.end_date,
    required this.type,
    required this.sub_type,
    this.featured = false,
    this.free_seating = true,
    required this.venue,
    required this.invoice,
    this.sold_out_msg,
    this.handling_cost,
    this.handling_cost_perc = false,
    this.currency = 'LKR',
    this.invitation_feature = false,
    this.invitation_count,
    this.invitation_packages,
    this.addons_feature = false,
    this.addons,
    this.trailer_url,
    required this.payment_gateways,
    this.analytics_ids = const [],
  });

  factory EventCreate.fromJson(Map<String, dynamic> json) =>
      _$EventCreateFromJson(json);

  Map<String, dynamic> toJson() => _$EventCreateToJson(this);
}

/// Event Response Model (from API)
@JsonSerializable()
class EventResponse {
  final int id;
  final String name;
  final String description;
  final String organizer;
  final String start_date;
  final String end_date;
  final String type;
  final String sub_type;
  final String venue;
  final String? banner_img;
  final String? thumbnail_img;
  final String status;
  final bool active;
  final DateTime created_at;
  final DateTime updated_at;

  EventResponse({
    required this.id,
    required this.name,
    required this.description,
    required this.organizer,
    required this.start_date,
    required this.end_date,
    required this.type,
    required this.sub_type,
    required this.venue,
    this.banner_img,
    this.thumbnail_img,
    required this.status,
    required this.active,
    required this.created_at,
    required this.updated_at,
  });

  factory EventResponse.fromJson(Map<String, dynamic> json) =>
      _$EventResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EventResponseToJson(this);
}

/// Paginated Events Response
@JsonSerializable()
class PaginatedEventsResponse {
  final List<EventResponse> events;
  final int total;
  final int page;
  final int limit;

  PaginatedEventsResponse({
    required this.events,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory PaginatedEventsResponse.fromJson(Map<String, dynamic> json) =>
      _$PaginatedEventsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PaginatedEventsResponseToJson(this);
}
