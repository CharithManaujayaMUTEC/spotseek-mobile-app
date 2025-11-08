import 'package:flutter/material.dart';
import 'package:spotseeker_app/screens/events/marketing_tabs/single_invitation_form.dart';
import 'package:spotseeker_app/screens/events/marketing_tabs/bulk_invitation_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spotseeker_app/models/invitation_models.dart';
import 'package:spotseeker_app/services/invitation_repository_mock.dart';

class MarketingTab extends StatefulWidget {
  const MarketingTab({super.key});

  @override
  State<MarketingTab> createState() => _MarketingTabState();
}

class _MarketingTabState extends State<MarketingTab> {
  int _selectedTab = 0;
  bool _showCreateForm = false;
  bool _showBulkForm = false;
  final Map<String, Set<String>> _selectedFilters = {
    'sort': <String>{},
    'category': <String>{},
    'scan': <String>{},
    'delivery': <String>{},
  };
  Map<String, Set<String>> _appliedFilters = {
    'sort': <String>{},
    'category': <String>{},
    'scan': <String>{},
    'delivery': <String>{},
  };

  List<Invitation> _singleInvitations = [];
  List<BulkInvitation> _bulkInvitations = [];
  Map<String, int> _invitationStats = {
    'total': 0,
    'spotseeker': 0,
    'special': 0,
    'spotseekerGeneral': 0,
    'spotseekerVip': 0,
    'spotseekerBackstage': 0,
    'specialGeneral': 0,
    'specialVip': 0,
    'specialBackstage': 0,
  };
  // Search controller and current query for the search widget
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMockDataFromAsset();
    // Keep track of the search text so UI can react live while typing
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMockDataFromAsset() async {
    try {
      final repo = MockInvitationRepository();
      final doc = await repo.loadRawDoc();

      setState(() {
        if (doc['stats'] is Map) {
          _invitationStats = Map<String, int>.from(
            doc['stats'].map((k, v) => MapEntry(k.toString(), (v as num).toInt())),
          );
        }
        if (doc['single'] is List) {
          _singleInvitations = (doc['single'] as List)
              .map((e) => Invitation.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        if (doc['bulk'] is List) {
          _bulkInvitations = (doc['bulk'] as List)
              .map((e) => BulkInvitation.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      });
    } catch (e) {
      print('Failed to load mock_invitations.json: $e');
      setState(() {
        _invitationStats = {
          'total': 0,
          'spotseeker': 0,
          'special': 0,
          'spotseekerGeneral': 0,
          'spotseekerVip': 0,
          'spotseekerBackstage': 0,
          'specialGeneral': 0,
          'specialVip': 0,
          'specialBackstage': 0,
        };
        _singleInvitations = [];
        _bulkInvitations = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showCreateForm) return _buildCreateInvitationForm();
    if (_showBulkForm) return _buildBulkInvitationForm();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 12),
          _buildTabs(),
          if (_selectedTab == 0) ...[
            const SizedBox(height: 32),
            _buildTotalInvitationsCard(),
            const SizedBox(height: 32),
            _buildInvitationBreakdown(),
            const SizedBox(height: 32),
            _buildActionButtons(),
            const SizedBox(height: 64),
            _buildSingleInvitations(),
            const SizedBox(height: 48),
            _buildBulkInvitations(),
            const SizedBox(height: 32),
          ] else if (_selectedTab == 1) ...[
            const SizedBox(height: 32),
            _buildSearch(),
            const SizedBox(height: 32),
            _buildInviteeListStyle(_filteredSingleInvitations().where((i) => i.type == 'Spotseeker Invitation').toList(), showFilter: true),
          ] else ...[
            const SizedBox(height: 32),
            _buildSearch(),
            const SizedBox(height: 32),
            const SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Bulk Invitations',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Onest',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Opacity(opacity: 0.60, child: Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20)),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            ..._filteredBulkInvitations().map((bulk) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildBulkInviteCard(bulk),
                )),
            _buildInviteeListStyle(_filteredSingleInvitations().where((i) => i.type == 'Special Invitation').toList(), showFilter: true, showBulk: true),
          ],
        ],
      ),
    );
  }

  Widget _buildInviteeListStyle(List<Invitation> invitations, {bool showFilter = false, bool showBulk = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showFilter)
          SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Invitees List',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Onest',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (sheetCtx) => SafeArea(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: StatefulBuilder(
                            builder: (BuildContext sbCtx, StateSetter setModalState) {
                              return _buildFilterStyle(context, setModalState);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/filter_icon.svg', width: 16, height: 16, color: Colors.white),
                      const SizedBox(width: 8),
                      const Text(
                        'Filter',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Onest',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          const Text(
            'Invitees List',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        const SizedBox(height: 16),
        ...invitations.map((inv) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildInviteeCard(inv, downloadLabel: showFilter ? 'Download E-Ticket' : 'Download QR'),
            )),
      ],
    );
  }

  Widget _buildSearch({String placeholder = 'Search Invitee Name Or Phone'}) {
    return Container(
      width: double.infinity,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: ShapeDecoration(
        color: Colors.black.withOpacity(0.10),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.30, color: Colors.white.withOpacity(0.16)),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          const Opacity(opacity: 0.60, child: Icon(Icons.search, color: Colors.white, size: 24)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Onest',
                fontWeight: FontWeight.w400,
              ),
              cursorColor: Colors.white,
              decoration: InputDecoration.collapsed(
                hintText: placeholder,
                hintStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Onest',
                  fontWeight: FontWeight.w400,
                ),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              onSubmitted: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteeCard(Invitation invitation, {String downloadLabel = 'Download QR'}) {
    final delivered = (invitation.deliveryBadge == 'delivered');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 15),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white.withOpacity(0.03),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: Colors.white.withOpacity(0.12)),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 149,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: ShapeDecoration(
              color: const Color(0xFF0F0729),
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1, color: Colors.white.withOpacity(0.12)),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFE50914),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                          ),
                          child: Center(
                            child: Text(
                              invitation.initial,
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              invitation.name,
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                              const SizedBox(height: 16),
                            Opacity(
                              opacity: 0.60,
                              child: Text(
                                invitation.phone,
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w400),
                              ),
                            ),
                          ],

                        )
                      ],
                    ),
                    const Opacity(opacity: 0.60, child: Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 26)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Opacity(opacity: 0.60, child: Text('Invitation Category', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w300))),
                          const SizedBox(height: 6),
                          Text(invitation.category, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Opacity(opacity: 0.60, child: Text('Delivery Status', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w300))),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: ShapeDecoration(
                            color: delivered ? const Color(0x333AF15D) : const Color(0x19F60000),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                invitation.deliveryStatus,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: delivered ? const Color(0xFF3AF15D) : const Color(0xFFF60000),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              if (!delivered) ...[
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Retrying delivery for ${invitation.name}')));
                                    },
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.cached, color: Color(0xFFF60000), size: 14),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset('assets/scanner_icon.svg', width: 18, height: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(invitation.scanned, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: ShapeDecoration(
                  color: const Color(0xFFE50914),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: Text(downloadLabel, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w400)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBulkInviteCard(BulkInvitation bulk) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 15),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white.withOpacity(0.03),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: Colors.white.withOpacity(0.12)),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 149,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: ShapeDecoration(
              color: const Color(0xFF0F0729),
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1, color: Colors.white.withOpacity(0.12)),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFE50914),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                          ),
                          child: Center(
                            child: Text(
                              bulk.initial.isNotEmpty ? bulk.initial : 'B',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bulk.name,
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            Opacity(
                              opacity: 0.60,
                              child: Text(
                                bulk.date,
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w400),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Opacity(opacity: 0.60, child: Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Opacity(opacity: 0.60, child: Text('Invitation Category', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w300))),
                          const SizedBox(height: 6),
                          Text(bulk.category, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Opacity(opacity: 0.60, child: Text('Delivery Status', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w300))),
                        const SizedBox(height: 6),
                          Builder(builder: (context) {
                          final delivered = (bulk.deliveryBadge == 'delivered');
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: ShapeDecoration(
                              color: delivered ? const Color(0x333AF15D) : const Color(0x19F60000),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  bulk.deliveryStatus,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: delivered ? const Color(0xFF3AF15D) : const Color(0xFFF60000),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                if (!delivered) ...[
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Retrying delivery for ${bulk.name}')),
                                      );
                                    },
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.cached,
                                        color: Color(0xFFF60000),
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset('assets/scanner_icon.svg', width: 18, height: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(bulk.scanned.isNotEmpty ? bulk.scanned : bulk.tickets, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: ShapeDecoration(
                  color: const Color(0xFFE50914),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: const Text('Download QR', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w400)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterStyle(BuildContext ctx, [StateSetter? modalSetState]) {
    return Container(
      width: double.infinity,
      height: 669,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.0, -0.6),
          radius: 1.5,
          colors: [Color(0xFF2E2250), Color(0xFF251A39), Color(0xFF0C0911)],
          stops: [0.0, 0.4, 1.0],
        ),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: -1196,
            child: Container(
              width: 430,
              height: 3345,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.50, 0.99),
                  end: Alignment(0.50, 0.96),
                  colors: [Colors.black, Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            left: -138,
            top: -110,
            child: Opacity(
              opacity: 0.15,
              child: Container(width: 653, height: 142, decoration: const ShapeDecoration(color: Color(0xFF653BFF), shape: OvalBorder())),
            ),
          ),
          Positioned(
            left: 69,
            top: -70,
            child: Opacity(opacity: 0.50, child: Container(width: 238, height: 53, decoration: const ShapeDecoration(color: Color(0xFF653BFF), shape: OvalBorder()))),
          ),
          const Positioned(
            top: 26,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Filters',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: 'Onest',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Positioned(
            top: 18,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(ctx).pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration: ShapeDecoration(
                  color: Colors.white.withOpacity(0.06),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Center(child: Icon(Icons.close, color: Colors.white, size: 20)),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            top: 76,
            child: Container(
              height: 1,
              decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: Colors.white.withOpacity(0.10)))),
            ),
          ),
          Positioned(
            left: 18,
            top: 101,
            right: 18,
            bottom: 16,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text('Sort By', style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Onest', fontWeight: FontWeight.w400)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 7,
                    runSpacing: 8,
                    children: [
                      _buildFilterChip('sort', 'A → Z (Name Ascending)', modalSetState),
                      _buildFilterChip('sort', 'Z → A (Name Descending)', modalSetState),
                      _buildFilterChip('sort', 'Latest to Oldest', modalSetState),
                      _buildFilterChip('sort', 'Oldest to Latest', modalSetState),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Invitation category', style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Onest', fontWeight: FontWeight.w400)),
                  const SizedBox(height: 12),
                  Wrap(spacing: 7, runSpacing: 8, children: [
                    _buildFilterChip('category', 'All', modalSetState),
                    _buildFilterChip('category', 'VIP', modalSetState),
                    _buildFilterChip('category', 'General', modalSetState),
                    _buildFilterChip('category', 'Backstage', modalSetState),
                  ]),
                  const SizedBox(height: 24),
                  const Text('Scan Status', style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Onest', fontWeight: FontWeight.w400)),
                  const SizedBox(height: 12),
                  Wrap(spacing: 7, runSpacing: 8, children: [
                    _buildFilterChip('scan', 'Available', modalSetState),
                    _buildFilterChip('scan', 'Partially Verified', modalSetState),
                    _buildFilterChip('scan', 'Verified', modalSetState),
                  ]),
                  const SizedBox(height: 24),
                  const Text('Delivery Status', style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Onest', fontWeight: FontWeight.w400)),
                  const SizedBox(height: 12),
                  Wrap(spacing: 7, runSpacing: 8, children: [
                    _buildFilterChip('delivery', 'Delivered', modalSetState),
                    _buildFilterChip('delivery', 'Delivery Failed', modalSetState),
                  ]),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (modalSetState != null) {
                            modalSetState(() {
                              _selectedFilters.forEach((k, v) => v.clear());
                              _appliedFilters.forEach((k, v) => v.clear());
                            });
                          } else {
                            setState(() {
                              _selectedFilters.forEach((k, v) => v.clear());
                              _appliedFilters.forEach((k, v) => v.clear());
                            });
                          }
                        },
                        child: Container(
                          width: 184,
                          height: 52,
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(width: 1, color: Color(0xFFE50914)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Text('Reset', style: TextStyle(color: Color(0xFFE50914), fontSize: 16, fontFamily: 'Onest', fontWeight: FontWeight.w600, letterSpacing: 0.32)),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _appliedFilters = {
                              'sort': Set<String>.from(_selectedFilters['sort'] ?? <String>{}),
                              'category': Set<String>.from(_selectedFilters['category'] ?? <String>{}),
                              'scan': Set<String>.from(_selectedFilters['scan'] ?? <String>{}),
                              'delivery': Set<String>.from(_selectedFilters['delivery'] ?? <String>{}),
                            };
                          });

                          Navigator.of(ctx).pop();
                        },
                        child: Container(
                          width: 184,
                          height: 52,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFE50914),
                            shape: RoundedRectangleBorder(side: const BorderSide(width: 1, color: Color(0xFFE50914)), borderRadius: BorderRadius.circular(6)),
                          ),
                          alignment: Alignment.center,
                          child: const Text('Apply', style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Onest', fontWeight: FontWeight.w600, letterSpacing: 0.32)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String section, String label, [StateSetter? modalSetState]) {
    final selected = _selectedFilters[section]?.contains(label) ?? false;

    return GestureDetector(
      onTap: () {
        if (modalSetState != null) {
          modalSetState(() {
            final set = _selectedFilters[section] ??= <String>{};
            if (set.contains(label)) {
              set.remove(label);
            } else {
              set.add(label);
            }
          });
        } else {
          setState(() {
            final set = _selectedFilters[section] ??= <String>{};
            if (set.contains(label)) {
              set.remove(label);
            } else {
              set.add(label);
            }
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: ShapeDecoration(
          color: selected ? Colors.white : Colors.black.withOpacity(0.10),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.white.withOpacity(0.12)),
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: Opacity(
          opacity: selected ? 1.0 : 0.60,
          child: Text(label, style: TextStyle(color: selected ? Colors.black : Colors.white, fontSize: 14, fontFamily: 'Onest', fontWeight: FontWeight.w400)),
        ),
      ),
    );
  }

  Widget _buildCreateInvitationForm() {
    return SingleInvitationScreen(
      onBack: () {
        setState(() {
          _showCreateForm = false;
        });
      },
    );
  }

  Widget _buildBulkInvitationForm() {
    return BulkInvitationScreen(
      onBack: () {
        setState(() {
          _showBulkForm = false;
        });
      },
    );
  }

  Widget _buildTabs() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1, color: Colors.white.withOpacity(0.10)),
        ),
      ),
      child: Row(
        children: [
          _buildTab('Overview', 0),
          _buildTab('Spotseeker Invites', 1),
          _buildTab('Special Invites', 2),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            border: isSelected ? const Border(bottom: BorderSide(width: 2, color: Color(0xFFE50914))) : null,
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xFFE50914) : Colors.white.withOpacity(0.50),
                fontSize: 16,
                fontFamily: 'Onest',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalInvitationsCard() {
    return Container(
      width: double.infinity,
      height: 212,
      clipBehavior: Clip.antiAlias,
      decoration: const ShapeDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.00, 0.50),
          end: Alignment(1.00, 0.10),
          colors: [Color(0xFF6441A5), Color(0xFF2A0845)],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(100), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
        ),
      ),
      child: Stack(
        children: [
          Positioned(left: 267, top: -11, child: Container(width: 150, height: 150, decoration: ShapeDecoration(color: Colors.white.withOpacity(0.05), shape: const OvalBorder()))),
          Positioned(left: 232, top: -46, child: Container(width: 220, height: 220, decoration: ShapeDecoration(shape: OvalBorder(side: BorderSide(width: 1.50, color: Colors.white.withOpacity(0.05)))))),
          Positioned(left: 352, top: 164, child: Container(width: 15, height: 15, decoration: const ShapeDecoration(color: Color(0xFF3D1C5C), shape: OvalBorder()))),
          Positioned(left: 231, top: 33, child: Container(width: 10, height: 10, decoration: const ShapeDecoration(color: Color(0xFF4D2972), shape: OvalBorder()))),
          Positioned(
            left: 22,
            top: 19,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset('assets/crown-1.png', width: 24, height: 24, color: Colors.white, fit: BoxFit.contain),
                    const SizedBox(height: 8),
                    const Text('Total Invitations', style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'Onest', fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Opacity(opacity: 0.60, child: Text('${_invitationStats['total']}', style: const TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'Onest', fontWeight: FontWeight.w500))),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 7, height: 41, decoration: ShapeDecoration(gradient: LinearGradient(begin: const Alignment(0.50, -0.00), end: const Alignment(0.50, 1.00), colors: [Colors.white.withOpacity(0), Colors.white.withOpacity(0.60)]), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))))),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Opacity(opacity: 0.60, child: Text('Spotseeker Invitations', style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Onest', fontWeight: FontWeight.w400))),
                        const SizedBox(height: 8),
                        Text('${_invitationStats['spotseeker']}', style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Onest', fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Container(width: 7, height: 41, decoration: ShapeDecoration(gradient: LinearGradient(begin: const Alignment(0.50, -0.00), end: const Alignment(0.50, 1.00), colors: [Colors.white.withOpacity(0), Colors.white.withOpacity(0.60)]), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))))),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Opacity(opacity: 0.60, child: Text('Special Invitations', style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Onest', fontWeight: FontWeight.w400))),
                        const SizedBox(height: 8),
                        Text('${_invitationStats['special']}', style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Onest', fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationBreakdown() {
    return SizedBox(
      height: 180,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildBreakdownCard('Spotseeker Invitations', [
              ['General Invitations', '${_invitationStats['spotseekerGeneral']}'],
              ['VIP Invitations', '${_invitationStats['spotseekerVip']}'],
              ['Backstage Invitations', '${_invitationStats['spotseekerBackstage']}'],
            ]),
            const SizedBox(width: 16),
            _buildBreakdownCard('Special Invitations', [
              ['General Invitations', '${_invitationStats['specialGeneral']}'],
              ['VIP Invitations', '${_invitationStats['specialVip']}'],
              ['Backstage Invitations', '${_invitationStats['specialBackstage']}'],
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownCard(String title, List<List<String>> items) {
    return Container(
      width: 363,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white.withOpacity(0.03),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: Colors.white.withOpacity(0.12)),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(13),
            child: Row(
              children: [
                const Icon(Icons.bookmark_outline, color: Colors.white, size: 18),
                const SizedBox(width: 4),
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400)),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 13),
            padding: const EdgeInsets.all(14),
            decoration: ShapeDecoration(
              color: const Color(0xFF18082A),
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1, color: Colors.white.withOpacity(0.12)),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: Column(
              children: items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Opacity(opacity: 0.60, child: Text(item[0], style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w300))),
                      Text(item[1], style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 13),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildStyledActionButton(
            'Create a New Invite',
            Icons.confirmation_num,
            svgAsset: 'assets/ticket-star.svg',
            onTap: () {
              setState(() {
                _showCreateForm = true;
              });
            },
          ),
          const SizedBox(width: 16),
          _buildStyledActionButton(
            'Bulk Upload',
            Icons.upload_file,
            svgAsset: 'assets/document-upload.svg',
            onTap: () {
              setState(() {
                _showBulkForm = true;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStyledActionButton(String label, IconData icon, {String? svgAsset, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 189,
        height: 104,
        child: Stack(
          children: [
            Positioned(
              left: 20,
              top: 0,
              child: Container(
                width: 54,
                height: 54,
                decoration: const ShapeDecoration(
                  color: Color(0xFF270F42),
                  shape: OvalBorder(),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 23,
              child: Container(
                width: 189,
                height: 81,
                decoration: ShapeDecoration(
                  color: const Color(0xFF270E42),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                ),
              ),
            ),
            Positioned(
              left: 20,
              top: 64,
              child: SizedBox(
                width: 153,
                child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Onest', fontWeight: FontWeight.w400)),
              ),
            ),
            Positioned(
              left: 26,
              top: 6,
              child: Container(
                width: 42,
                height: 42,
                decoration: const ShapeDecoration(color: Color(0xFFE50914), shape: OvalBorder()),
              ),
            ),
            Positioned(
              left: 35,
              top: 15,
              child: SizedBox(
                width: 24,
                height: 24,
                child: svgAsset != null
                    ? SvgPicture.asset(svgAsset, width: 24, height: 24, color: Colors.white)
                    : Icon(icon, color: Colors.white, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleInvitations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Single Invitations', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500)),
        const SizedBox(height: 24),
        ..._filteredSingleInvitations().map((inv) => Padding(padding: const EdgeInsets.only(bottom: 16), child: _buildInviteeCard(inv))),
      ],
    );
  }

  Widget _buildBulkInvitations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Bulk Invitations', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500)),
        const SizedBox(height: 24),
        ..._filteredBulkInvitations().map((inv) => Padding(padding: const EdgeInsets.only(bottom: 16), child: _buildBulkInviteCard(inv))),
      ],
    );
  }

  // Simple filter implementations so the UI can work with mock data.
  List<Invitation> _filteredSingleInvitations() {
    final q = _searchQuery.trim().toLowerCase();
    return _singleInvitations.where((inv) {
      if (q.isNotEmpty) {
        final name = inv.name.toLowerCase();
        final phone = inv.phone.toLowerCase();
        if (!name.contains(q) && !phone.contains(q)) return false;
      }

      // category filter (if set and not 'All')
      final cats = _appliedFilters['category'] ?? <String>{};
      if (cats.isNotEmpty && !cats.contains('All')) {
        final cat = inv.category;
        if (!cats.contains(cat)) return false;
      }

      // delivery filter (basic check)
      final dels = _appliedFilters['delivery'] ?? <String>{};
      if (dels.isNotEmpty) {
        final delivered = inv.deliveryStatus.toLowerCase().contains('deliver');
        if (dels.contains('Delivered') && !delivered) return false;
        if (dels.contains('Delivery Failed') && delivered) return false;
      }

      // scan filter (basic check)
      final scans = _appliedFilters['scan'] ?? <String>{};
      if (scans.isNotEmpty) {
        final scanned = inv.scanned.toLowerCase();
        if (scans.contains('Available') && !scanned.contains('available')) return false;
      }

      return true;
    }).toList();
  }

  List<BulkInvitation> _filteredBulkInvitations() {
    final q = _searchQuery.trim().toLowerCase();
    return _bulkInvitations.where((inv) {
      if (q.isNotEmpty) {
        final name = inv.name.toLowerCase();
        final date = inv.date.toLowerCase();
        if (!name.contains(q) && !date.contains(q)) return false;
      }
      // Minimal filtering for bulk; mirror single's delivery/category handling if desired
      final dels = _appliedFilters['delivery'] ?? <String>{};
      if (dels.isNotEmpty) {
        final delivered = inv.deliveryStatus.toLowerCase().contains('deliver');
        if (dels.contains('Delivered') && !delivered) return false;
        if (dels.contains('Delivery Failed') && delivered) return false;
      }
      return true;
    }).toList();
  }

}