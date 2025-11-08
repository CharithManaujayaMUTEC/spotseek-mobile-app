
class InvitationStats {
  final int total;
  final int spotseeker;
  final int special;

  InvitationStats({required this.total, required this.spotseeker, required this.special});

  factory InvitationStats.fromJson(Map<String, dynamic> j) => InvitationStats(
        total: (j['total'] as num).toInt(),
        spotseeker: (j['spotseeker'] as num).toInt(),
        special: (j['special'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {'total': total, 'spotseeker': spotseeker, 'special': special};
}

class Invitation {
  final String initial;
  final String name;
  final String phone;
  final String category;
  final String type;
  final String deliveryStatus;
  final String deliveryBadge;
  final String scanned;
  final String progress;
  final String tickets;

  Invitation({
    required this.initial,
    required this.name,
    required this.phone,
    required this.category,
    required this.type,
    required this.deliveryStatus,
    required this.deliveryBadge,
    required this.scanned,
    required this.progress,
    required this.tickets,
  });

  factory Invitation.fromJson(Map<String, dynamic> j) => Invitation(
        initial: j['initial'] as String? ?? '',
        name: j['name'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
        category: j['category'] as String? ?? '',
        type: j['type'] as String? ?? '',
        deliveryStatus: j['deliveryStatus'] as String? ?? '',
        deliveryBadge: j['deliveryBadge'] as String? ?? '',
        scanned: j['scanned'] as String? ?? '',
        progress: j['progress'] as String? ?? '0',
        tickets: j['tickets'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'initial': initial,
        'name': name,
        'phone': phone,
        'category': category,
        'type': type,
        'deliveryStatus': deliveryStatus,
        'deliveryBadge': deliveryBadge,
        'scanned': scanned,
        'progress': progress,
        'tickets': tickets,
      };
}

class BulkInvitation {
  final String initial;
  final String name;
  final String date;
  final String category;
  final String type;
  final String tickets;
  final String scanned;
  final String progress;
  final String deliveryStatus;
  final String deliveryBadge;

  BulkInvitation({
    required this.initial,
    required this.name,
    required this.date,
    required this.category,
    required this.type,
    required this.tickets,
    required this.scanned,
    required this.progress,
    required this.deliveryStatus,
    required this.deliveryBadge,
  });

  factory BulkInvitation.fromJson(Map<String, dynamic> j) => BulkInvitation(
        initial: j['initial'] as String? ?? '',
        name: j['name'] as String? ?? '',
        date: j['date'] as String? ?? '',
        category: j['category'] as String? ?? '',
        type: j['type'] as String? ?? '',
        tickets: j['tickets'] as String? ?? '',
        scanned: j['scanned'] as String? ?? '',
        progress: j['progress'] as String? ?? '0',
        deliveryStatus: j['deliveryStatus'] as String? ?? '',
        deliveryBadge: j['deliveryBadge'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'initial': initial,
        'name': name,
        'date': date,
        'category': category,
        'type': type,
        'tickets': tickets,
        'scanned': scanned,
        'progress': progress,
        'deliveryStatus': deliveryStatus,
        'deliveryBadge': deliveryBadge,
      };
}
