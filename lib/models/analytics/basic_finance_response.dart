import 'dart:math' as math;

import 'package:spotseeker_app/models/analytics/analytics_models.dart';

double _doubleOrZero(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  final parsed = double.tryParse(value.toString());
  return parsed ?? 0.0;
}

double? _doubleOrNull(dynamic value) {
  if (value == null) return null;
  final converted = _doubleOrZero(value);
  if (value is String && value.trim().isEmpty) return null;
  return converted;
}

int _intOrZero(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is num) return value.toInt();
  final parsed = int.tryParse(value.toString());
  return parsed ?? 0;
}

int? _intOrNull(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

bool? _boolOrNull(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.toLowerCase().trim();
    if (normalized.isEmpty) return null;
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
  }
  return null;
}

String? _stringOrNull(dynamic value) {
  if (value == null) return null;
  final stringValue = value.toString();
  if (stringValue.trim().isEmpty) return stringValue;
  if (stringValue.toLowerCase().trim() == 'null') return null;
  return stringValue;
}

List<int> _intList(dynamic value) {
  if (value is List) {
    return value.map((e) => _intOrNull(e) ?? 0).toList();
  }
  return const <int>[];
}

List<dynamic> _list(dynamic value) {
  if (value is List) return List<dynamic>.from(value);
  return const <dynamic>[];
}

Map<String, double> _stringDoubleMap(dynamic value) {
  final result = <String, double>{};
  if (value is Map) {
    value.forEach((key, val) {
      final name = key == null ? '' : key.toString();
      if (name.isEmpty) return;
      result[name] = _doubleOrZero(val);
    });
  }
  return result;
}

Map<String, int> _stringIntMap(dynamic value) {
  final result = <String, int>{};
  if (value is Map) {
    value.forEach((key, val) {
      final name = key == null ? '' : key.toString();
      if (name.isEmpty) return;
      result[name] = _intOrZero(val);
    });
  }
  return result;
}

Map<String, Map<String, double>> _nestedDoubleMap(dynamic value) {
  final result = <String, Map<String, double>>{};
  if (value is Map) {
    value.forEach((outerKey, innerValue) {
      final outerName = outerKey == null ? '' : outerKey.toString();
      if (outerName.isEmpty) return;
      result[outerName] = _stringDoubleMap(innerValue);
    });
  }
  return result;
}

Map<String, Map<String, int>> _nestedIntMap(dynamic value) {
  final result = <String, Map<String, int>>{};
  if (value is Map) {
    value.forEach((outerKey, innerValue) {
      final outerName = outerKey == null ? '' : outerKey.toString();
      if (outerName.isEmpty) return;
      result[outerName] = _stringIntMap(innerValue);
    });
  }
  return result;
}

Map<String, dynamic> _stringDynamicMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), val));
  }
  return <String, dynamic>{};
}

bool _looksLikeLegacyFinance(Map<String, dynamic> json) {
  return json.containsKey('totalSales') && json.containsKey('netRevenue');
}

class BasicFinanceResponse {
  final Map<String, dynamic> raw;
  final BasicFinanceEventDetails event;
  final double totalSales;
  final double totalHandlingCost;
  final double totalDiscounts;
  final List<BasicFinancePackage> packages;
  final List<BasicFinanceTicketPackage> ticketPackages;
  final List<int> customerCount;
  final Map<String, double> salesByDate;
  final Map<String, int> ticketsCountByDate;
  final Map<String, Map<String, double>> salesByPackageAndDate;
  final Map<String, Map<String, int>> ticketsCountByPackageAndDate;
  final int? totalInvitations;
  final int? totalAccepted;
  final int? totalRejected;
  final int? totalNoResponse;
  final BasicFinanceLiveStats? liveStats;
  final BasicFinanceVenue? venue;
  final BasicFinanceManager? manager;
  final List<BasicFinanceInvitation> invitations;
  final List<BasicFinanceTicketSale> ticketSales;
  final double? _netRevenueOverride;

  BasicFinanceResponse._({
    required this.raw,
    required this.event,
    required this.totalSales,
    required this.totalHandlingCost,
    required this.totalDiscounts,
    required this.packages,
    required this.ticketPackages,
    required this.customerCount,
    required this.salesByDate,
    required this.ticketsCountByDate,
    required this.salesByPackageAndDate,
    required this.ticketsCountByPackageAndDate,
    required this.totalInvitations,
    required this.totalAccepted,
    required this.totalRejected,
    required this.totalNoResponse,
    required this.liveStats,
    required this.venue,
    required this.manager,
    required this.invitations,
    required this.ticketSales,
    double? netRevenueOverride,
  }) : _netRevenueOverride = netRevenueOverride;

  factory BasicFinanceResponse.fromJson(Map<String, dynamic> input) {
    final map = Map<String, dynamic>.from(input);
    if (_looksLikeLegacyFinance(map)) {
      return BasicFinanceResponse._fromLegacy(map);
    }
    return BasicFinanceResponse._fromModern(map);
  }

  static BasicFinanceResponse _fromLegacy(Map<String, dynamic> json) {
    final totalSales = _doubleOrZero(json['totalSales']);
    final totalCommissions = _doubleOrZero(json['totalCommissions']);
    final totalDiscounts = _doubleOrZero(json['totalDiscounts']);
    final netRevenue = _doubleOrZero(json['netRevenue']);

    final packages = <BasicFinancePackage>[];
    final legacyPackages = json['salesByPackage'];
    if (legacyPackages is List) {
      for (final item in legacyPackages) {
        if (item is Map<String, dynamic>) {
          packages.add(BasicFinancePackage.fromLegacy(item));
        } else if (item is Map) {
          packages.add(BasicFinancePackage.fromLegacy(
              Map<String, dynamic>.from(item)));
        }
      }
    }

    return BasicFinanceResponse._(
      raw: json,
      event: BasicFinanceEventDetails.legacy(
        totalSales: totalSales,
        totalHandlingCost: totalCommissions,
        totalDiscounts: totalDiscounts,
      ),
      totalSales: totalSales,
      totalHandlingCost: totalCommissions,
      totalDiscounts: totalDiscounts,
      packages: packages,
      ticketPackages: const <BasicFinanceTicketPackage>[],
      customerCount: const <int>[],
      salesByDate: const <String, double>{},
      ticketsCountByDate: const <String, int>{},
      salesByPackageAndDate: const <String, Map<String, double>>{},
      ticketsCountByPackageAndDate: const <String, Map<String, int>>{},
      totalInvitations: null,
      totalAccepted: null,
      totalRejected: null,
      totalNoResponse: null,
      liveStats: null,
      venue: null,
      manager: null,
      invitations: const <BasicFinanceInvitation>[],
      ticketSales: const <BasicFinanceTicketSale>[],
      netRevenueOverride: netRevenue,
    );
  }

  static BasicFinanceResponse _fromModern(Map<String, dynamic> json) {
    final eventDetails = BasicFinanceEventDetails.fromJson(json);
    final totalSales = eventDetails.totalSales ?? _doubleOrZero(json['tot_sale']);
    final totalHandlingCost =
        eventDetails.totalHandlingCost ?? _doubleOrZero(json['tot_handling_cost']);
    final totalDiscounts =
        eventDetails.totalDiscounts ?? _doubleOrZero(json['tot_discounts']);

    final salesByPackageAndDate = _nestedDoubleMap(json['sales_by_package_and_date']);
    final ticketsCountByPackageAndDate =
        _nestedIntMap(json['tickets_count_by_package_and_date']);

    final aggregatedRevenue = <String, double>{};
    salesByPackageAndDate.values.forEach((value) {
      value.forEach((packageName, revenue) {
        aggregatedRevenue[packageName] =
            (aggregatedRevenue[packageName] ?? 0.0) + revenue;
      });
    });

    final aggregatedTicketCounts = <String, int>{};
    ticketsCountByPackageAndDate.values.forEach((value) {
      value.forEach((packageName, count) {
        aggregatedTicketCounts[packageName] =
            (aggregatedTicketCounts[packageName] ?? 0) + count;
      });
    });

    final ticketPackages = <BasicFinanceTicketPackage>[];
    final packages = <BasicFinancePackage>[];

    final ticketPackagesJson = json['ticket_packages'];
    if (ticketPackagesJson is List) {
      for (final item in ticketPackagesJson) {
        if (item is Map<String, dynamic>) {
          final ticketPackage = BasicFinanceTicketPackage.fromJson(item);
          ticketPackages.add(ticketPackage);

          final displayName = (ticketPackage.name == null ||
                  ticketPackage.name!.trim().isEmpty)
              ? 'Package ${ticketPackage.id ?? ticketPackages.length}'
              : ticketPackage.name!;

          var ticketsSold =
              ticketPackage.soldTicketCounts ?? ticketPackage.soldCount ?? 0;
          if (ticketsSold == 0 && aggregatedTicketCounts.containsKey(displayName)) {
            ticketsSold = aggregatedTicketCounts[displayName]!;
          }

          var revenue = ticketPackage.salesAmount ?? 0.0;
          if ((revenue == 0.0 || revenue.isNaN) &&
              aggregatedRevenue.containsKey(displayName)) {
            revenue = aggregatedRevenue[displayName]!;
          }

          packages.add(
            BasicFinancePackage(
              id: ticketPackage.id,
              name: displayName,
              ticketsSold: ticketsSold,
              revenue: revenue,
              source: ticketPackage,
            ),
          );

          aggregatedRevenue.remove(displayName);
          aggregatedTicketCounts.remove(displayName);
        } else if (item is Map) {
          final ticketPackage = BasicFinanceTicketPackage.fromJson(
            Map<String, dynamic>.from(item),
          );
          ticketPackages.add(ticketPackage);

          final displayName = (ticketPackage.name == null ||
                  ticketPackage.name!.trim().isEmpty)
              ? 'Package ${ticketPackage.id ?? ticketPackages.length}'
              : ticketPackage.name!;

          var ticketsSold =
              ticketPackage.soldTicketCounts ?? ticketPackage.soldCount ?? 0;
          if (ticketsSold == 0 && aggregatedTicketCounts.containsKey(displayName)) {
            ticketsSold = aggregatedTicketCounts[displayName]!;
          }

          var revenue = ticketPackage.salesAmount ?? 0.0;
          if ((revenue == 0.0 || revenue.isNaN) &&
              aggregatedRevenue.containsKey(displayName)) {
            revenue = aggregatedRevenue[displayName]!;
          }

          packages.add(
            BasicFinancePackage(
              id: ticketPackage.id,
              name: displayName,
              ticketsSold: ticketsSold,
              revenue: revenue,
              source: ticketPackage,
            ),
          );

          aggregatedRevenue.remove(displayName);
          aggregatedTicketCounts.remove(displayName);
        }
      }
    }

    if (aggregatedRevenue.isNotEmpty || aggregatedTicketCounts.isNotEmpty) {
      final remainingNames = {
        ...aggregatedRevenue.keys,
        ...aggregatedTicketCounts.keys,
      };

      for (final name in remainingNames) {
        if (name.trim().isEmpty) continue;
        packages.add(
          BasicFinancePackage(
            name: name,
            ticketsSold: aggregatedTicketCounts[name] ?? 0,
            revenue: aggregatedRevenue[name] ?? 0.0,
          ),
        );
      }
    }

    final invitations = <BasicFinanceInvitation>[];
    final invitationsJson = json['invitations'];
    if (invitationsJson is List) {
      for (final item in invitationsJson) {
        if (item is Map<String, dynamic>) {
          invitations.add(BasicFinanceInvitation.fromJson(item));
        } else if (item is Map) {
          invitations.add(
            BasicFinanceInvitation.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    final ticketSales = <BasicFinanceTicketSale>[];
    final ticketSalesJson = json['ticket_sales'];
    if (ticketSalesJson is List) {
      for (final item in ticketSalesJson) {
        if (item is Map<String, dynamic>) {
          ticketSales.add(BasicFinanceTicketSale.fromJson(item));
        } else if (item is Map) {
          ticketSales.add(
            BasicFinanceTicketSale.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    final liveStatsJson = json['liveStats'];
    final liveStats = liveStatsJson is Map<String, dynamic>
        ? BasicFinanceLiveStats.fromJson(liveStatsJson)
        : liveStatsJson is Map
            ? BasicFinanceLiveStats.fromJson(
                Map<String, dynamic>.from(liveStatsJson),
              )
            : null;

    final venueJson = json['venue'];
    final venue = venueJson is Map<String, dynamic>
        ? BasicFinanceVenue.fromJson(venueJson)
        : venueJson is Map
            ? BasicFinanceVenue.fromJson(Map<String, dynamic>.from(venueJson))
            : null;

    final managerJson = json['managerr'];
    final manager = managerJson is Map<String, dynamic>
        ? BasicFinanceManager.fromJson(managerJson)
        : managerJson is Map
            ? BasicFinanceManager.fromJson(Map<String, dynamic>.from(managerJson))
            : null;

    return BasicFinanceResponse._(
      raw: json,
      event: eventDetails,
      totalSales: totalSales,
      totalHandlingCost: totalHandlingCost,
      totalDiscounts: totalDiscounts,
      packages: packages,
      ticketPackages: ticketPackages,
      customerCount: _intList(json['customer_count']),
      salesByDate: _stringDoubleMap(json['sales_by_date']),
      ticketsCountByDate: _stringIntMap(json['tickets_count_by_date']),
      salesByPackageAndDate: salesByPackageAndDate,
      ticketsCountByPackageAndDate: ticketsCountByPackageAndDate,
      totalInvitations: _intOrNull(json['totalInvitations']),
      totalAccepted: _intOrNull(json['totalAccepted']),
      totalRejected: _intOrNull(json['totalRejected']),
      totalNoResponse: _intOrNull(json['totalNoResponse']),
      liveStats: liveStats,
      venue: venue,
      manager: manager,
      invitations: invitations,
      ticketSales: ticketSales,
      netRevenueOverride: null,
    );
  }

  FinanceSales toFinanceSales() {
    final totalCommissions = totalHandlingCost;
    final netRevenue = _netRevenueOverride ??
        math.max(0.0, totalSales - totalCommissions - totalDiscounts);

    return FinanceSales(
      totalSales: totalSales,
      totalCommissions: totalCommissions,
      netRevenue: netRevenue,
      salesByPackage: packages.map((e) => e.toSalesBreakdown()).toList(),
    );
  }
}

class BasicFinanceEventDetails {
  final int? id;
  final String? name;
  final String? organizer;
  final String? manager;
  final String? venueId;
  final String? startDate;
  final String? endDate;
  final String? status;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final String? type;
  final String? bannerImg;
  final String? thumbnailImg;
  final String? description;
  final bool? featured;
  final String? message;
  final String? uid;
  final bool? freeSeating;
  final String? subType;
  final String? jsonDesc;
  final double? handlingCost;
  final bool? handlingCostPercentage;
  final String? currency;
  final bool? invitationFeature;
  final int? addonsFeature;
  final int? invitationCount;
  final String? trailerUrl;
  final Map<String, dynamic> analyticsIds;
  final bool? bannerImgApproved;
  final String? dateApproved;
  final bool? descriptionApproved;
  final String? externalEventId;
  final bool? nameApproved;
  final bool? organizerApproved;
  final String? reviewedAt;
  final String? reviewedBy;
  final bool? subTypeApproved;
  final bool? thumbnailImgApproved;
  final bool? trailerUrlApproved;
  final bool? typeApproved;
  final bool? venueApproved;
  final int? partnerId;
  final double? ticketSalesSumTotalAmount;
  final int? ticketSalesSumTotalTicketCount;
  final int? verifiedBookings;
  final int? completedBookings;
  final int? failedBookings;
  final int? cancelledBookings;
  final int? totalBookings;
  final double? totalSales;
  final double? totalHandlingCost;
  final double? totalDiscounts;

  const BasicFinanceEventDetails({
    this.id,
    this.name,
    this.organizer,
    this.manager,
    this.venueId,
    this.startDate,
    this.endDate,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.type,
    this.bannerImg,
    this.thumbnailImg,
    this.description,
    this.featured,
    this.message,
    this.uid,
    this.freeSeating,
    this.subType,
    this.jsonDesc,
    this.handlingCost,
    this.handlingCostPercentage,
    this.currency,
    this.invitationFeature,
    this.addonsFeature,
    this.invitationCount,
    this.trailerUrl,
    this.analyticsIds = const <String, dynamic>{},
    this.bannerImgApproved,
    this.dateApproved,
    this.descriptionApproved,
    this.externalEventId,
    this.nameApproved,
    this.organizerApproved,
    this.reviewedAt,
    this.reviewedBy,
    this.subTypeApproved,
    this.thumbnailImgApproved,
    this.trailerUrlApproved,
    this.typeApproved,
    this.venueApproved,
    this.partnerId,
    this.ticketSalesSumTotalAmount,
    this.ticketSalesSumTotalTicketCount,
    this.verifiedBookings,
    this.completedBookings,
    this.failedBookings,
    this.cancelledBookings,
    this.totalBookings,
    this.totalSales,
    this.totalHandlingCost,
    this.totalDiscounts,
  });

  factory BasicFinanceEventDetails.fromJson(Map<String, dynamic> json) {
    return BasicFinanceEventDetails(
      id: _intOrNull(json['id']),
      name: _stringOrNull(json['name']),
      organizer: _stringOrNull(json['organizer']),
      manager: _stringOrNull(json['manager']),
      venueId: _stringOrNull(json['venue_id']),
      startDate: _stringOrNull(json['start_date']),
      endDate: _stringOrNull(json['end_date']),
      status: _stringOrNull(json['status']),
      createdAt: _stringOrNull(json['created_at']),
      updatedAt: _stringOrNull(json['updated_at']),
      deletedAt: _stringOrNull(json['deleted_at']),
      type: _stringOrNull(json['type']),
      bannerImg: _stringOrNull(json['banner_img']),
      thumbnailImg: _stringOrNull(json['thumbnail_img']),
      description: _stringOrNull(json['description']),
      featured: _boolOrNull(json['featured']),
      message: _stringOrNull(json['message']),
      uid: _stringOrNull(json['uid']),
      freeSeating: _boolOrNull(json['free_seating']),
      subType: _stringOrNull(json['sub_type']),
      jsonDesc: _stringOrNull(json['json_desc']),
      handlingCost: _doubleOrNull(json['handling_cost']),
      handlingCostPercentage: _boolOrNull(json['handling_cost_perc']),
      currency: _stringOrNull(json['currency']),
      invitationFeature: _boolOrNull(json['invitation_feature']),
      addonsFeature: _intOrNull(json['addons_feature']),
      invitationCount: _intOrNull(json['invitation_count']),
      trailerUrl: _stringOrNull(json['trailer_url']),
      analyticsIds: _stringDynamicMap(json['analytics_ids']),
      bannerImgApproved: _boolOrNull(json['banner_img_approved']),
      dateApproved: _stringOrNull(json['date_approved']),
      descriptionApproved: _boolOrNull(json['description_approved']),
      externalEventId: _stringOrNull(json['external_event_id']),
      nameApproved: _boolOrNull(json['name_approved']),
      organizerApproved: _boolOrNull(json['organizer_approved']),
      reviewedAt: _stringOrNull(json['reviewed_at']),
      reviewedBy: _stringOrNull(json['reviewed_by']),
      subTypeApproved: _boolOrNull(json['sub_type_approved']),
      thumbnailImgApproved: _boolOrNull(json['thumbnail_img_approved']),
      trailerUrlApproved: _boolOrNull(json['trailer_url_approved']),
      typeApproved: _boolOrNull(json['type_approved']),
      venueApproved: _boolOrNull(json['venue_approved']),
      partnerId: _intOrNull(json['partner_id']),
      ticketSalesSumTotalAmount: _doubleOrNull(json['ticket_sales_sum_tot_amount']),
      ticketSalesSumTotalTicketCount:
          _intOrNull(json['ticket_sales_sum_tot_ticket_count']),
      verifiedBookings: _intOrNull(json['verified_bookings']),
      completedBookings: _intOrNull(json['completed_bookings']),
      failedBookings: _intOrNull(json['failed_bookings']),
      cancelledBookings: _intOrNull(json['cancelled_bookings']),
      totalBookings: _intOrNull(json['tot_bookings']),
      totalSales: _doubleOrNull(json['tot_sale']),
      totalHandlingCost: _doubleOrNull(json['tot_handling_cost']),
      totalDiscounts: _doubleOrNull(json['tot_discounts']),
    );
  }

  factory BasicFinanceEventDetails.legacy({
    double? totalSales,
    double? totalHandlingCost,
    double? totalDiscounts,
  }) {
    return BasicFinanceEventDetails(
      totalSales: totalSales,
      totalHandlingCost: totalHandlingCost,
      totalDiscounts: totalDiscounts,
    );
  }
}

class BasicFinancePackage {
  final int? id;
  final String name;
  final int ticketsSold;
  final double revenue;
  final BasicFinanceTicketPackage? source;

  BasicFinancePackage({
    this.id,
    required this.name,
    required this.ticketsSold,
    required this.revenue,
    this.source,
  });

  factory BasicFinancePackage.fromLegacy(Map<String, dynamic> json) {
    final name = _stringOrNull(json['packageName']) ?? 'Unnamed package';
    final ticketsSold = _intOrZero(json['ticketsSold']);
    final revenue = _doubleOrZero(json['revenue']);
    return BasicFinancePackage(
      name: name,
      ticketsSold: ticketsSold,
      revenue: revenue,
    );
  }

  SalesBreakdown toSalesBreakdown() {
    return SalesBreakdown(
      packageName: name,
      ticketsSold: ticketsSold,
      revenue: revenue,
    );
  }
}

class BasicFinanceTicketPackage {
  final int? id;
  final int? eventId;
  final String? name;
  final double? price;
  final List<dynamic> seatingRange;
  final String? description;
  final int? totalTickets;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final int? availableTickets;
  final int? reservedTickets;
  final List<dynamic> reservedSeats;
  final List<dynamic> availableSeats;
  final bool? freeSeating;
  final bool? active;
  final bool? soldOut;
  final bool? privatePackage;
  final int? maxTicketsCanBuy;
  final String? adminReviewNotes;
  final String? datetimeApproved;
  final String? endDateTime;
  final String? externalPackageId;
  final String? nameApproved;
  final String? priceApproved;
  final int? releaseCount;
  final String? releaseCountApproved;
  final String? reviewedAt;
  final String? reviewedBy;
  final int? soldCount;
  final String? startDateTime;
  final String? status;
  final int? soldTicketCounts;
  final int? verifiedTicketCount;
  final int? completeTicketCount;
  final int? failedTicketCount;
  final int? cancelledTicketCount;
  final double? salesPrec;
  final double? salesAmount;

  const BasicFinanceTicketPackage({
    this.id,
    this.eventId,
    this.name,
    this.price,
    this.seatingRange = const <dynamic>[],
    this.description,
    this.totalTickets,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.availableTickets,
    this.reservedTickets,
    this.reservedSeats = const <dynamic>[],
    this.availableSeats = const <dynamic>[],
    this.freeSeating,
    this.active,
    this.soldOut,
    this.privatePackage,
    this.maxTicketsCanBuy,
    this.adminReviewNotes,
    this.datetimeApproved,
    this.endDateTime,
    this.externalPackageId,
    this.nameApproved,
    this.priceApproved,
    this.releaseCount,
    this.releaseCountApproved,
    this.reviewedAt,
    this.reviewedBy,
    this.soldCount,
    this.startDateTime,
    this.status,
    this.soldTicketCounts,
    this.verifiedTicketCount,
    this.completeTicketCount,
    this.failedTicketCount,
    this.cancelledTicketCount,
    this.salesPrec,
    this.salesAmount,
  });

  factory BasicFinanceTicketPackage.fromJson(Map<String, dynamic> json) {
    return BasicFinanceTicketPackage(
      id: _intOrNull(json['id']),
      eventId: _intOrNull(json['event_id']),
      name: _stringOrNull(json['name']),
      price: _doubleOrNull(json['price']),
      seatingRange: _list(json['seating_range']),
      description: _stringOrNull(json['desc']),
      totalTickets: _intOrNull(json['tot_tickets']),
      createdAt: _stringOrNull(json['created_at']),
      updatedAt: _stringOrNull(json['updated_at']),
      deletedAt: _stringOrNull(json['deleted_at']),
      availableTickets: _intOrNull(json['aval_tickets']),
      reservedTickets: _intOrNull(json['res_tickets']),
      reservedSeats: _list(json['reserved_seats']),
      availableSeats: _list(json['available_seats']),
      freeSeating: _boolOrNull(json['free_seating']),
      active: _boolOrNull(json['active']),
      soldOut: _boolOrNull(json['sold_out']),
      privatePackage: _boolOrNull(json['private']),
      maxTicketsCanBuy: _intOrNull(json['max_tickets_can_buy']),
      adminReviewNotes: _stringOrNull(json['admin_review_notes']),
      datetimeApproved: _stringOrNull(json['datetime_approved']),
      endDateTime: _stringOrNull(json['end_date_time']),
      externalPackageId: _stringOrNull(json['external_package_id']),
      nameApproved: _stringOrNull(json['name_approved']),
      priceApproved: _stringOrNull(json['price_approved']),
      releaseCount: _intOrNull(json['release_count']),
      releaseCountApproved: _stringOrNull(json['release_count_approved']),
      reviewedAt: _stringOrNull(json['reviewed_at']),
      reviewedBy: _stringOrNull(json['reviewed_by']),
      soldCount: _intOrNull(json['sold_count']),
      startDateTime: _stringOrNull(json['start_date_time']),
      status: _stringOrNull(json['status']),
      soldTicketCounts: _intOrNull(json['sold_ticket_counts']),
      verifiedTicketCount: _intOrNull(json['verified_ticket_count']),
      completeTicketCount: _intOrNull(json['complete_ticket_count']),
      failedTicketCount: _intOrNull(json['failed_ticket_count']),
      cancelledTicketCount: _intOrNull(json['cancelled_ticket_count']),
      salesPrec: _doubleOrNull(json['sales_prec']),
      salesAmount: _doubleOrNull(json['sales_amount']),
    );
  }
}

class BasicFinanceInvitation {
  final int? id;
  final String? invitationId;
  final int? eventId;
  final int? userId;
  final int? packageId;
  final String? seatNos;
  final int? ticketsCount;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  const BasicFinanceInvitation({
    this.id,
    this.invitationId,
    this.eventId,
    this.userId,
    this.packageId,
    this.seatNos,
    this.ticketsCount,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory BasicFinanceInvitation.fromJson(Map<String, dynamic> json) {
    return BasicFinanceInvitation(
      id: _intOrNull(json['id']),
      invitationId: _stringOrNull(json['invitation_id']),
      eventId: _intOrNull(json['event_id']),
      userId: _intOrNull(json['user_id']),
      packageId: _intOrNull(json['package_id']),
      seatNos: _stringOrNull(json['seat_nos']),
      ticketsCount: _intOrNull(json['tickets_count']),
      status: _stringOrNull(json['status']),
      createdAt: _stringOrNull(json['created_at']),
      updatedAt: _stringOrNull(json['updated_at']),
    );
  }
}

class BasicFinanceTicketSale {
  final int? id;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final int? userId;
  final int? eventId;
  final double? totalAmount;
  final String? paymentStatus;
  final String? paymentRefNo;
  final String? orderId;
  final String? transactionDateTime;
  final String? paymentMethod;
  final String? comment;
  final int? totalTicketCount;
  final String? bookingStatus;
  final String? eTicketUrl;
  final int? totalVerifiedTicketCount;
  final String? verifiedBy;
  final String? verifiedAt;

  const BasicFinanceTicketSale({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.userId,
    this.eventId,
    this.totalAmount,
    this.paymentStatus,
    this.paymentRefNo,
    this.orderId,
    this.transactionDateTime,
    this.paymentMethod,
    this.comment,
    this.totalTicketCount,
    this.bookingStatus,
    this.eTicketUrl,
    this.totalVerifiedTicketCount,
    this.verifiedBy,
    this.verifiedAt,
  });

  factory BasicFinanceTicketSale.fromJson(Map<String, dynamic> json) {
    return BasicFinanceTicketSale(
      id: _intOrNull(json['id']),
      createdAt: _stringOrNull(json['created_at']),
      updatedAt: _stringOrNull(json['updated_at']),
      deletedAt: _stringOrNull(json['deleted_at']),
      userId: _intOrNull(json['user_id']),
      eventId: _intOrNull(json['event_id']),
      totalAmount: _doubleOrNull(json['tot_amount']),
      paymentStatus: _stringOrNull(json['payment_status']),
      paymentRefNo: _stringOrNull(json['payment_ref_no']),
      orderId: _stringOrNull(json['order_id']),
      transactionDateTime: _stringOrNull(json['transaction_date_time']),
      paymentMethod: _stringOrNull(json['payment_method']),
      comment: _stringOrNull(json['comment']),
      totalTicketCount: _intOrNull(json['tot_ticket_count']),
      bookingStatus: _stringOrNull(json['booking_status']),
      eTicketUrl: _stringOrNull(json['e_ticket_url']),
      totalVerifiedTicketCount: _intOrNull(json['tot_verified_ticket_count']),
      verifiedBy: _stringOrNull(json['verified_by']),
      verifiedAt: _stringOrNull(json['verified_at']),
    );
  }
}

class BasicFinanceLiveStats {
  final int? fansInside;
  final List<dynamic> scanRate;
  final double? fansInPercent;
  final int? scanPerLastThirtyMins;

  const BasicFinanceLiveStats({
    this.fansInside,
    this.scanRate = const <dynamic>[],
    this.fansInPercent,
    this.scanPerLastThirtyMins,
  });

  factory BasicFinanceLiveStats.fromJson(Map<String, dynamic> json) {
    return BasicFinanceLiveStats(
      fansInside: _intOrNull(json['fansInside']),
      scanRate: _list(json['scanRate']),
      fansInPercent: _doubleOrNull(json['fansInPerc']),
      scanPerLastThirtyMins: _intOrNull(json['scanPerLastThirtyMins']),
    );
  }
}

class BasicFinanceVenue {
  final int? id;
  final String? name;
  final String? description;
  final int? seatingCapacity;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final String? seatMap;
  final String? locationUrl;

  const BasicFinanceVenue({
    this.id,
    this.name,
    this.description,
    this.seatingCapacity,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.seatMap,
    this.locationUrl,
  });

  factory BasicFinanceVenue.fromJson(Map<String, dynamic> json) {
    return BasicFinanceVenue(
      id: _intOrNull(json['id']),
      name: _stringOrNull(json['name']),
      description: _stringOrNull(json['desc']),
      seatingCapacity: _intOrNull(json['seating_capacity']),
      createdAt: _stringOrNull(json['created_at']),
      updatedAt: _stringOrNull(json['updated_at']),
      deletedAt: _stringOrNull(json['deleted_at']),
      seatMap: _stringOrNull(json['seat_map']),
      locationUrl: _stringOrNull(json['location_url']),
    );
  }
}

class BasicFinanceManager {
  final int? id;
  final String? name;
  final String? email;
  final String? emailVerifiedAt;
  final int? currentTeamId;
  final String? profilePhotoPath;
  final String? createdAt;
  final String? updatedAt;
  final String? firstName;
  final String? lastName;
  final String? phoneNo;
  final String? mobileVerifiedAt;
  final String? addressLineOne;
  final String? addressLineTwo;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final String? nic;
  final String? status;
  final String? mobile;
  final bool? mobileVerified;
  final bool? profileComplete;
  final String? userType;

  const BasicFinanceManager({
    this.id,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.currentTeamId,
    this.profilePhotoPath,
    this.createdAt,
    this.updatedAt,
    this.firstName,
    this.lastName,
    this.phoneNo,
    this.mobileVerifiedAt,
    this.addressLineOne,
    this.addressLineTwo,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.nic,
    this.status,
    this.mobile,
    this.mobileVerified,
    this.profileComplete,
    this.userType,
  });

  factory BasicFinanceManager.fromJson(Map<String, dynamic> json) {
    return BasicFinanceManager(
      id: _intOrNull(json['id']),
      name: _stringOrNull(json['name']),
      email: _stringOrNull(json['email']),
      emailVerifiedAt: _stringOrNull(json['email_verified_at']),
      currentTeamId: _intOrNull(json['current_team_id']),
      profilePhotoPath: _stringOrNull(json['profile_photo_path']),
      createdAt: _stringOrNull(json['created_at']),
      updatedAt: _stringOrNull(json['updated_at']),
      firstName: _stringOrNull(json['first_name']),
      lastName: _stringOrNull(json['last_name']),
      phoneNo: _stringOrNull(json['phone_no']),
      mobileVerifiedAt: _stringOrNull(json['mobile_verified_at']),
      addressLineOne: _stringOrNull(json['address_line_one']),
      addressLineTwo: _stringOrNull(json['address_line_two']),
      city: _stringOrNull(json['city']),
      state: _stringOrNull(json['state']),
      postalCode: _stringOrNull(json['postal_code']),
      country: _stringOrNull(json['country']),
      nic: _stringOrNull(json['nic']),
      status: _stringOrNull(json['status']),
      mobile: _stringOrNull(json['mobile']),
      mobileVerified: _boolOrNull(json['mobile_verified']),
      profileComplete: _boolOrNull(json['profile_complete']),
      userType: _stringOrNull(json['user_type']),
    );
  }
}

