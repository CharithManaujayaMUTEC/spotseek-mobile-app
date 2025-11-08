// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_models_new.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Promotion _$PromotionFromJson(Map<String, dynamic> json) => Promotion(
      promoCode: json['promoCode'] as String?,
      discAmount: json['discAmount'] as String?,
      discAmtIsPercentage: json['discAmtIsPercentage'] as bool? ?? false,
      isPerTicket: json['isPerTicket'] as bool? ?? false,
      minTickets: json['minTickets'] as String?,
      minAmount: json['minAmount'] as String?,
      maxTickets: json['maxTickets'] as String?,
      maxAmount: json['maxAmount'] as String?,
      startDateTime: json['startDateTime'] as String?,
      endDateTime: json['endDateTime'] as String?,
      isAutoApply: json['isAutoApply'] as bool? ?? false,
      redeems: json['redeems'] as String?,
    );

Map<String, dynamic> _$PromotionToJson(Promotion instance) => <String, dynamic>{
      'promoCode': instance.promoCode,
      'discAmount': instance.discAmount,
      'discAmtIsPercentage': instance.discAmtIsPercentage,
      'isPerTicket': instance.isPerTicket,
      'minTickets': instance.minTickets,
      'minAmount': instance.minAmount,
      'maxTickets': instance.maxTickets,
      'maxAmount': instance.maxAmount,
      'startDateTime': instance.startDateTime,
      'endDateTime': instance.endDateTime,
      'isAutoApply': instance.isAutoApply,
      'redeems': instance.redeems,
    };

TicketPackage _$TicketPackageFromJson(Map<String, dynamic> json) =>
    TicketPackage(
      packageName: json['packageName'] as String,
      packageDesc: json['packageDesc'] as String?,
      packagePrice: json['packagePrice'] as String,
      packageQty: json['packageQty'] as String,
      packageAvailQty: json['packageAvailQty'] as String,
      packageResQty: json['packageResQty'] as String?,
      packageAllocSeats: json['packageAllocSeats'] as String?,
      packageAvailSeats: json['packageAvailSeats'] as String?,
      packageFreeSeating: json['packageFreeSeating'] as bool? ?? true,
      sold_out: json['sold_out'] as bool? ?? false,
      promotions: json['promotions'] as bool? ?? false,
      promotion: (json['promotion'] as List<dynamic>?)
          ?.map((e) => Promotion.fromJson(e as Map<String, dynamic>))
          .toList(),
      active: json['active'] as bool? ?? true,
      deleted: json['deleted'] as bool? ?? false,
      maxBuyTickets: (json['maxBuyTickets'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$TicketPackageToJson(TicketPackage instance) =>
    <String, dynamic>{
      'packageName': instance.packageName,
      'packageDesc': instance.packageDesc,
      'packagePrice': instance.packagePrice,
      'packageQty': instance.packageQty,
      'packageAvailQty': instance.packageAvailQty,
      'packageResQty': instance.packageResQty,
      'packageAllocSeats': instance.packageAllocSeats,
      'packageAvailSeats': instance.packageAvailSeats,
      'packageFreeSeating': instance.packageFreeSeating,
      'sold_out': instance.sold_out,
      'promotions': instance.promotions,
      'promotion': instance.promotion,
      'active': instance.active,
      'deleted': instance.deleted,
      'maxBuyTickets': instance.maxBuyTickets,
    };

InvitationPackage _$InvitationPackageFromJson(Map<String, dynamic> json) =>
    InvitationPackage(
      packageName: json['packageName'] as String?,
      packageDesc: json['packageDesc'] as String?,
      packageQty: json['packageQty'] as String?,
      packageAvailQty: json['packageAvailQty'] as String?,
      packageSoldQty: json['packageSoldQty'] as String?,
      packageAllocSeats: json['packageAllocSeats'] as String?,
      active: json['active'] as bool? ?? true,
      deleted: json['deleted'] as bool? ?? false,
      packageFreeSeating: json['packageFreeSeating'] as bool? ?? true,
    );

Map<String, dynamic> _$InvitationPackageToJson(InvitationPackage instance) =>
    <String, dynamic>{
      'packageName': instance.packageName,
      'packageDesc': instance.packageDesc,
      'packageQty': instance.packageQty,
      'packageAvailQty': instance.packageAvailQty,
      'packageSoldQty': instance.packageSoldQty,
      'packageAllocSeats': instance.packageAllocSeats,
      'active': instance.active,
      'deleted': instance.deleted,
      'packageFreeSeating': instance.packageFreeSeating,
    };

EventAddon _$EventAddonFromJson(Map<String, dynamic> json) => EventAddon(
      addonName: json['addonName'] as String?,
      addonCategory: json['addonCategory'] as String?,
      addonPrice: json['addonPrice'] as String?,
      deleted: json['deleted'] as bool? ?? false,
    );

Map<String, dynamic> _$EventAddonToJson(EventAddon instance) =>
    <String, dynamic>{
      'addonName': instance.addonName,
      'addonCategory': instance.addonCategory,
      'addonPrice': instance.addonPrice,
      'deleted': instance.deleted,
    };

PaymentGateway _$PaymentGatewayFromJson(Map<String, dynamic> json) =>
    PaymentGateway(
      id: json['id'] as String?,
      name: json['name'] as String?,
      commission_rate: (json['commission_rate'] as num?)?.toDouble() ?? 0,
      apply_handling_fee: json['apply_handling_fee'] as bool? ?? true,
      deleted: json['deleted'] as bool? ?? false,
    );

Map<String, dynamic> _$PaymentGatewayToJson(PaymentGateway instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'commission_rate': instance.commission_rate,
      'apply_handling_fee': instance.apply_handling_fee,
      'deleted': instance.deleted,
    };

EventCreate _$EventCreateFromJson(Map<String, dynamic> json) => EventCreate(
      name: json['name'] as String,
      description: json['description'] as String,
      organizer: json['organizer'] as String,
      manager: json['manager'] as String,
      start_date: json['start_date'] as String,
      end_date: json['end_date'] as String,
      type: json['type'] as String,
      sub_type: json['sub_type'] as String,
      featured: json['featured'] as bool? ?? false,
      free_seating: json['free_seating'] as bool? ?? true,
      venue: json['venue'] as String,
      invoice: (json['invoice'] as List<dynamic>)
          .map((e) => TicketPackage.fromJson(e as Map<String, dynamic>))
          .toList(),
      sold_out_msg: json['sold_out_msg'] as String?,
      handling_cost: json['handling_cost'] as String?,
      handling_cost_perc: json['handling_cost_perc'] as bool? ?? false,
      currency: json['currency'] as String? ?? 'LKR',
      invitation_feature: json['invitation_feature'] as bool? ?? false,
      invitation_count: json['invitation_count'] as String?,
      invitation_packages: (json['invitation_packages'] as List<dynamic>?)
          ?.map((e) => InvitationPackage.fromJson(e as Map<String, dynamic>))
          .toList(),
      addons_feature: json['addons_feature'] as bool? ?? false,
      addons: (json['addons'] as List<dynamic>?)
          ?.map((e) => EventAddon.fromJson(e as Map<String, dynamic>))
          .toList(),
      trailer_url: json['trailer_url'] as String?,
      payment_gateways: (json['payment_gateways'] as List<dynamic>)
          .map((e) => PaymentGateway.fromJson(e as Map<String, dynamic>))
          .toList(),
      analytics_ids: (json['analytics_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$EventCreateToJson(EventCreate instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'organizer': instance.organizer,
      'manager': instance.manager,
      'start_date': instance.start_date,
      'end_date': instance.end_date,
      'type': instance.type,
      'sub_type': instance.sub_type,
      'featured': instance.featured,
      'free_seating': instance.free_seating,
      'venue': instance.venue,
      'invoice': instance.invoice,
      'sold_out_msg': instance.sold_out_msg,
      'handling_cost': instance.handling_cost,
      'handling_cost_perc': instance.handling_cost_perc,
      'currency': instance.currency,
      'invitation_feature': instance.invitation_feature,
      'invitation_count': instance.invitation_count,
      'invitation_packages': instance.invitation_packages,
      'addons_feature': instance.addons_feature,
      'addons': instance.addons,
      'trailer_url': instance.trailer_url,
      'payment_gateways': instance.payment_gateways,
      'analytics_ids': instance.analytics_ids,
    };

EventResponse _$EventResponseFromJson(Map<String, dynamic> json) =>
    EventResponse(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String,
      organizer: json['organizer'] as String,
      start_date: json['start_date'] as String,
      end_date: json['end_date'] as String,
      type: json['type'] as String,
      sub_type: json['sub_type'] as String,
      venue: json['venue'] as String,
      banner_img: json['banner_img'] as String?,
      thumbnail_img: json['thumbnail_img'] as String?,
      status: json['status'] as String,
      active: json['active'] as bool,
      created_at: DateTime.parse(json['created_at'] as String),
      updated_at: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$EventResponseToJson(EventResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'organizer': instance.organizer,
      'start_date': instance.start_date,
      'end_date': instance.end_date,
      'type': instance.type,
      'sub_type': instance.sub_type,
      'venue': instance.venue,
      'banner_img': instance.banner_img,
      'thumbnail_img': instance.thumbnail_img,
      'status': instance.status,
      'active': instance.active,
      'created_at': instance.created_at.toIso8601String(),
      'updated_at': instance.updated_at.toIso8601String(),
    };

PaginatedEventsResponse _$PaginatedEventsResponseFromJson(
        Map<String, dynamic> json) =>
    PaginatedEventsResponse(
      events: (json['events'] as List<dynamic>)
          .map((e) => EventResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
    );

Map<String, dynamic> _$PaginatedEventsResponseToJson(
        PaginatedEventsResponse instance) =>
    <String, dynamic>{
      'events': instance.events,
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
    };
