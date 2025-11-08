// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventOverview _$EventOverviewFromJson(Map<String, dynamic> json) =>
    EventOverview(
      totalTicketsSold: (json['totalTicketsSold'] as num).toInt(),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      totalCheckIns: (json['totalCheckIns'] as num).toInt(),
      remainingTickets: (json['remainingTickets'] as num).toInt(),
      additionalStats: json['additionalStats'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$EventOverviewToJson(EventOverview instance) =>
    <String, dynamic>{
      'totalTicketsSold': instance.totalTicketsSold,
      'totalRevenue': instance.totalRevenue,
      'totalCheckIns': instance.totalCheckIns,
      'remainingTickets': instance.remainingTickets,
      'additionalStats': instance.additionalStats,
    };

LiveStats _$LiveStatsFromJson(Map<String, dynamic> json) => LiveStats(
      currentCheckIns: (json['currentCheckIns'] as num).toInt(),
      liveAttendance: (json['liveAttendance'] as num).toInt(),
      realtimeRevenue: (json['realtimeRevenue'] as num).toDouble(),
      breakdown: json['breakdown'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$LiveStatsToJson(LiveStats instance) => <String, dynamic>{
      'currentCheckIns': instance.currentCheckIns,
      'liveAttendance': instance.liveAttendance,
      'realtimeRevenue': instance.realtimeRevenue,
      'breakdown': instance.breakdown,
    };

FinanceSales _$FinanceSalesFromJson(Map<String, dynamic> json) => FinanceSales(
      totalSales: (json['totalSales'] as num).toDouble(),
      totalCommissions: (json['totalCommissions'] as num).toDouble(),
      netRevenue: (json['netRevenue'] as num).toDouble(),
      salesByPackage: (json['salesByPackage'] as List<dynamic>?)
          ?.map((e) => SalesBreakdown.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FinanceSalesToJson(FinanceSales instance) =>
    <String, dynamic>{
      'totalSales': instance.totalSales,
      'totalCommissions': instance.totalCommissions,
      'netRevenue': instance.netRevenue,
      'salesByPackage': instance.salesByPackage,
    };

SalesBreakdown _$SalesBreakdownFromJson(Map<String, dynamic> json) =>
    SalesBreakdown(
      packageName: json['packageName'] as String,
      ticketsSold: (json['ticketsSold'] as num).toInt(),
      revenue: (json['revenue'] as num).toDouble(),
    );

Map<String, dynamic> _$SalesBreakdownToJson(SalesBreakdown instance) =>
    <String, dynamic>{
      'packageName': instance.packageName,
      'ticketsSold': instance.ticketsSold,
      'revenue': instance.revenue,
    };

FinanceBreakdown _$FinanceBreakdownFromJson(Map<String, dynamic> json) =>
    FinanceBreakdown(
      ticketSales: (json['ticketSales'] as num).toDouble(),
      platformFees: (json['platformFees'] as num).toDouble(),
      paymentGatewayFees: (json['paymentGatewayFees'] as num).toDouble(),
      taxes: (json['taxes'] as num).toDouble(),
      netAmount: (json['netAmount'] as num).toDouble(),
      additionalCharges: json['additionalCharges'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$FinanceBreakdownToJson(FinanceBreakdown instance) =>
    <String, dynamic>{
      'ticketSales': instance.ticketSales,
      'platformFees': instance.platformFees,
      'paymentGatewayFees': instance.paymentGatewayFees,
      'taxes': instance.taxes,
      'netAmount': instance.netAmount,
      'additionalCharges': instance.additionalCharges,
    };
