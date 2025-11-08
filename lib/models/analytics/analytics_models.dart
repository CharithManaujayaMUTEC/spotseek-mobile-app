import 'package:json_annotation/json_annotation.dart';

part 'analytics_models.g.dart';

/// Event Overview Stats
@JsonSerializable()
class EventOverview {
  final int totalTicketsSold;
  final double totalRevenue;
  final int totalCheckIns;
  final int remainingTickets;
  final Map<String, dynamic>? additionalStats;

  EventOverview({
    required this.totalTicketsSold,
    required this.totalRevenue,
    required this.totalCheckIns,
    required this.remainingTickets,
    this.additionalStats,
  });

  factory EventOverview.fromJson(Map<String, dynamic> json) => _$EventOverviewFromJson(json);

  Map<String, dynamic> toJson() => _$EventOverviewToJson(this);
}

/// Live Stats
@JsonSerializable()
class LiveStats {
  final int currentCheckIns;
  final int liveAttendance;
  final double realtimeRevenue;
  final Map<String, dynamic>? breakdown;

  LiveStats({
    required this.currentCheckIns,
    required this.liveAttendance,
    required this.realtimeRevenue,
    this.breakdown,
  });

  factory LiveStats.fromJson(Map<String, dynamic> json) => _$LiveStatsFromJson(json);

  Map<String, dynamic> toJson() => _$LiveStatsToJson(this);
}

/// Finance Sales
@JsonSerializable()
class FinanceSales {
  final double totalSales;
  final double totalCommissions;
  final double netRevenue;
  final List<SalesBreakdown>? salesByPackage;

  FinanceSales({
    required this.totalSales,
    required this.totalCommissions,
    required this.netRevenue,
    this.salesByPackage,
  });

  factory FinanceSales.fromJson(Map<String, dynamic> json) => _$FinanceSalesFromJson(json);

  Map<String, dynamic> toJson() => _$FinanceSalesToJson(this);
}

@JsonSerializable()
class SalesBreakdown {
  final String packageName;
  final int ticketsSold;
  final double revenue;

  SalesBreakdown({
    required this.packageName,
    required this.ticketsSold,
    required this.revenue,
  });

  factory SalesBreakdown.fromJson(Map<String, dynamic> json) => _$SalesBreakdownFromJson(json);

  Map<String, dynamic> toJson() => _$SalesBreakdownToJson(this);
}

/// Finance Breakdown
@JsonSerializable()
class FinanceBreakdown {
  final double ticketSales;
  final double platformFees;
  final double paymentGatewayFees;
  final double taxes;
  final double netAmount;
  final Map<String, dynamic>? additionalCharges;

  FinanceBreakdown({
    required this.ticketSales,
    required this.platformFees,
    required this.paymentGatewayFees,
    required this.taxes,
    required this.netAmount,
    this.additionalCharges,
  });

  factory FinanceBreakdown.fromJson(Map<String, dynamic> json) => _$FinanceBreakdownFromJson(json);

  Map<String, dynamic> toJson() => _$FinanceBreakdownToJson(this);
}
