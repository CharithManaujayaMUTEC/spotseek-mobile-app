class InvoiceData {
  final String invoiceNumber;
  final DateTime invoiceDate;
  final EventInfo event;
  final List<RevenueItem> revenueItems;
  final RevenueSummary revenueSummary;
  final List<PromoCode> promoCodes;
  final PromoSummary promoSummary;
  final List<Withdrawal> withdrawals;
  final WithdrawalSummary withdrawalSummary;
  final FinancialSummary financialSummary;
  final CompanyInfo companyInfo;

  InvoiceData({
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.event,
    required this.revenueItems,
    required this.revenueSummary,
    required this.promoCodes,
    required this.promoSummary,
    required this.withdrawals,
    required this.withdrawalSummary,
    required this.financialSummary,
    required this.companyInfo,
  });

  factory InvoiceData.fromJson(Map<String, dynamic> j) => InvoiceData(
        invoiceNumber: j['invoiceNumber'] as String,
        invoiceDate: DateTime.parse(j['invoiceDate'] as String),
        event: EventInfo.fromJson(j['event'] as Map<String, dynamic>),
        revenueItems: (j['revenueItems'] as List).map((e) => RevenueItem.fromJson(e as Map<String, dynamic>)).toList(),
        revenueSummary: RevenueSummary.fromJson(j['revenueSummary'] as Map<String, dynamic>),
        promoCodes: (j['promoCodes'] as List).map((e) => PromoCode.fromJson(e as Map<String, dynamic>)).toList(),
        promoSummary: PromoSummary.fromJson(j['promoSummary'] as Map<String, dynamic>),
        withdrawals: (j['withdrawals'] as List).map((e) => Withdrawal.fromJson(e as Map<String, dynamic>)).toList(),
        withdrawalSummary: WithdrawalSummary.fromJson(j['withdrawalSummary'] as Map<String, dynamic>),
        financialSummary: FinancialSummary.fromJson(j['financialSummary'] as Map<String, dynamic>),
        companyInfo: CompanyInfo.fromJson(j['companyInfo'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'invoiceNumber': invoiceNumber,
        'invoiceDate': invoiceDate.toIso8601String(),
        'event': event.toJson(),
        'revenueItems': revenueItems.map((e) => e.toJson()).toList(),
        'revenueSummary': revenueSummary.toJson(),
        'promoCodes': promoCodes.map((e) => e.toJson()).toList(),
        'promoSummary': promoSummary.toJson(),
        'withdrawals': withdrawals.map((e) => e.toJson()).toList(),
        'withdrawalSummary': withdrawalSummary.toJson(),
        'financialSummary': financialSummary.toJson(),
        'companyInfo': companyInfo.toJson(),
      };
}

class EventInfo {
  final String name;
  final DateTime date;
  final String imageUrl;
  EventInfo({required this.name, required this.date, required this.imageUrl});
  factory EventInfo.fromJson(Map<String, dynamic> j) => EventInfo(
        name: j['name'] as String,
        date: DateTime.parse(j['date'] as String),
        imageUrl: j['imageUrl'] as String,
      );
  Map<String, dynamic> toJson() => {'name': name, 'date': date.toIso8601String(), 'imageUrl': imageUrl};
}

class RevenueItem {
  final String packageName;
  final int soldQuantity;
  final num price;
  final num total;
  RevenueItem({required this.packageName, required this.soldQuantity, required this.price, required this.total});
  factory RevenueItem.fromJson(Map<String, dynamic> j) => RevenueItem(
        packageName: j['packageName'] as String,
        soldQuantity: (j['soldQuantity'] as num).toInt(),
        price: j['price'] as num,
        total: j['total'] as num,
      );
  Map<String, dynamic> toJson() => {'packageName': packageName, 'soldQuantity': soldQuantity, 'price': price, 'total': total};
}

class RevenueSummary {
  final num totalRevenue;
  RevenueSummary({required this.totalRevenue});
  factory RevenueSummary.fromJson(Map<String, dynamic> j) => RevenueSummary(totalRevenue: j['totalRevenue'] as num);
  Map<String, dynamic> toJson() => {'totalRevenue': totalRevenue};
}

class PromoCode {
  final String code;
  final int usedQuantity;
  final String discount;
  final num totalDiscount;
  PromoCode({required this.code, required this.usedQuantity, required this.discount, required this.totalDiscount});
  factory PromoCode.fromJson(Map<String, dynamic> j) => PromoCode(
        code: j['code'] as String,
        usedQuantity: (j['usedQuantity'] as num).toInt(),
        discount: j['discount'] as String,
        totalDiscount: j['totalDiscount'] as num,
      );
  Map<String, dynamic> toJson() => {'code': code, 'usedQuantity': usedQuantity, 'discount': discount, 'totalDiscount': totalDiscount};
}

class PromoSummary {
  final num totalPromoDiscount;
  PromoSummary({required this.totalPromoDiscount});
  factory PromoSummary.fromJson(Map<String, dynamic> j) => PromoSummary(totalPromoDiscount: j['totalPromoDiscount'] as num);
  Map<String, dynamic> toJson() => {'totalPromoDiscount': totalPromoDiscount};
}

class Withdrawal {
  final String date;
  final String note;
  final num amount;
  Withdrawal({required this.date, required this.note, required this.amount});
  factory Withdrawal.fromJson(Map<String, dynamic> j) => Withdrawal(date: j['date'] as String, note: j['note'] as String, amount: j['amount'] as num);
  Map<String, dynamic> toJson() => {'date': date, 'note': note, 'amount': amount};
}

class WithdrawalSummary {
  final num totalWithdrawals;
  WithdrawalSummary({required this.totalWithdrawals});
  factory WithdrawalSummary.fromJson(Map<String, dynamic> j) => WithdrawalSummary(totalWithdrawals: j['totalWithdrawals'] as num);
  Map<String, dynamic> toJson() => {'totalWithdrawals': totalWithdrawals};
}

class FinancialSummary {
  final num adjustedRevenue;
  final num totalWithdrawals;
  final num remainingBalance;
  final num commissionRate;
  final num commissionAmount;
  final num finalPayout;
  FinancialSummary({
    required this.adjustedRevenue,
    required this.totalWithdrawals,
    required this.remainingBalance,
    required this.commissionRate,
    required this.commissionAmount,
    required this.finalPayout,
  });
  factory FinancialSummary.fromJson(Map<String, dynamic> j) => FinancialSummary(
        adjustedRevenue: j['adjustedRevenue'] as num,
        totalWithdrawals: j['totalWithdrawals'] as num,
        remainingBalance: j['remainingBalance'] as num,
        commissionRate: j['commissionRate'] as num,
        commissionAmount: j['commissionAmount'] as num,
        finalPayout: j['finalPayout'] as num,
      );
  Map<String, dynamic> toJson() => {
        'adjustedRevenue': adjustedRevenue,
        'totalWithdrawals': totalWithdrawals,
        'remainingBalance': remainingBalance,
        'commissionRate': commissionRate,
        'commissionAmount': commissionAmount,
        'finalPayout': finalPayout,
      };
}

class CompanyInfo {
  final String name;
  final String registrationNumber;
  final String signatureUrl;
  final DateTime signatureDate;
  CompanyInfo({required this.name, required this.registrationNumber, required this.signatureUrl, required this.signatureDate});
  factory CompanyInfo.fromJson(Map<String, dynamic> j) => CompanyInfo(
        name: j['name'] as String,
        registrationNumber: j['registrationNumber'] as String,
        signatureUrl: j['signatureUrl'] as String,
        signatureDate: DateTime.parse(j['signatureDate'] as String),
      );
  Map<String, dynamic> toJson() => {'name': name, 'registrationNumber': registrationNumber, 'signatureUrl': signatureUrl, 'signatureDate': signatureDate.toIso8601String()};
}
