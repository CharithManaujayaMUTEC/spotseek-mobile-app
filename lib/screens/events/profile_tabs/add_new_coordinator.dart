import 'package:flutter/material.dart';

class AddNewCoordinator extends StatefulWidget {
  const AddNewCoordinator({Key? key}) : super(key: key);

  @override
  State<AddNewCoordinator> createState() => _AddNewCoordinatorState();
}

class _AddNewCoordinatorState extends State<AddNewCoordinator> {
  bool _dashboardChecked = false;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    const double sidePadding = 20.0;
    double availableWidthFromLeft(double left) =>
        (screenWidth - left - sidePadding).clamp(0.0, screenWidth);

    return SingleChildScrollView(
      child: SizedBox(
        height: 1356,
        child: Stack(
          children: [
            Positioned(
              left: 20,
              top: 21,
              child: SizedBox(
                width: availableWidthFromLeft(20),
                child: const Text(
                  'Add New Coordinator',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Onest',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              top: 313,
              child: SizedBox(
                width: availableWidthFromLeft(20),
                child: const Text(
                  'Assign Pages',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Onest',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              top: 79,
              child: SizedBox(
                width: availableWidthFromLeft(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 0),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldPlaceholder('Name'),
                        const SizedBox(height: 8),
                        _buildFieldPlaceholder('Email Address'),
                        const SizedBox(height: 8),
                        _buildFieldPlaceholder('Set Password'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 20,
              top: 1256,
              child: Container(
                width: availableWidthFromLeft(20),
                height: 52,
                decoration: ShapeDecoration(
                  color: const Color(0xFFE50914),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 1, color: Color(0xFFE50914)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Onest',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.32,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 20,
              top: 371,
              child: GestureDetector(
                onTap: () => setState(() => _dashboardChecked = !_dashboardChecked),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _dashboardChecked ? const Color(0xFFE50914) : const Color(0xFF141129),
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color: _dashboardChecked ? const Color(0xFFE50914) : Colors.white.withOpacity(0.12),
                      width: 1,
                    ),
                  ),
                  child: _dashboardChecked
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ),
            ),
            Positioned(
              left: 52,
              top: 371,
              child: SizedBox(
                width: availableWidthFromLeft(52),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Opacity(
                      opacity: 0.5,
                      child: Text(
                        'Dashboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Onest',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: 0.5,
                      child: Transform(
                        transform: Matrix4.identity()..rotateZ(3.14),
                        child: const SizedBox(width: 20, height: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const _NavRow(left: 52, top: 407, title: 'Overview'),
            const _NavRow(left: 52, top: 443, title: 'Event Preview'),
            const _NavRow(left: 52, top: 479, title: 'Live Stat'),
            const _NavRow(left: 52, top: 515, title: 'Achievements'),
            Positioned(
              left: 17,
              top: 560,
              child: Container(
                width: availableWidthFromLeft(17),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1,
                      strokeAlign: BorderSide.strokeAlignCenter,
                      color: Colors.white.withOpacity(0.10),
                    ),
                  ),
                ),
              ),
            ),
            const _NavRow(left: 54, top: 584, title: 'Finance', trailing: true),
            const _NavRow(left: 54, top: 620, title: 'Sales'),
            const _NavRow(left: 54, top: 656, title: 'Finance Breakdown'),
            const _NavRow(left: 54, top: 692, title: 'Withdraw Funds'),
            Positioned(
              left: 19,
              top: 736,
              child: Container(
                width: availableWidthFromLeft(19),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1,
                      strokeAlign: BorderSide.strokeAlignCenter,
                      color: Colors.white.withOpacity(0.10),
                    ),
                  ),
                ),
              ),
            ),
            const _NavRow(left: 52, top: 828, title: 'Marketing', trailing: true),
            const _NavRow(left: 52, top: 864, title: 'Invitations'),
            const _NavRow(left: 82, top: 900, title: 'Overview'),
            const _NavRow(left: 82, top: 936, title: 'Spotseeker Invitees'),
            const _NavRow(left: 82, top: 972, title: 'Special Invitees'),
            const _NavRow(left: 82, top: 1008, title: 'Create Invitation'),
            const _NavRow(left: 82, top: 1044, title: 'Bulk Upload'),
            Positioned(
              left: 17,
              top: 1152,
              child: Container(
                width: availableWidthFromLeft(17),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1,
                      strokeAlign: BorderSide.strokeAlignCenter,
                      color: Colors.white.withOpacity(0.10),
                    ),
                  ),
                ),
              ),
            ),
            const _NavRow(left: 52, top: 1080, title: 'SMS Campaign'),
            const _NavRow(left: 52, top: 1116, title: 'Email Campaign'),
            const _NavRow(left: 54, top: 760, title: 'QR scan'),
            Positioned(
              left: 19,
              top: 804,
              child: Container(
                width: availableWidthFromLeft(19),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1,
                      strokeAlign: BorderSide.strokeAlignCenter,
                      color: Colors.white.withOpacity(0.10),
                    ),
                  ),
                ),
              ),
            ),
            const _NavRow(left: 20, top: 1176, title: 'Services', leftOffsetForIcon: 20),
          ],
        ),
      ),
    );
  }

  static Widget _buildFieldPlaceholder(String label) {
    return Container(
      constraints: const BoxConstraints(minWidth: 0, maxWidth: double.infinity),
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.10),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Onest',
                fontWeight: FontWeight.w400,
              ),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: label,
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.50),
                  fontSize: 16,
                  fontFamily: 'Onest',
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavRow extends StatefulWidget {
  final double left;
  final double top;
  final String title;
  final bool trailing;
  final double leftOffsetForIcon;

  const _NavRow({
    Key? key,
    required this.left,
    required this.top,
    required this.title,
    this.trailing = false,
    this.leftOffsetForIcon = 52,
  }) : super(key: key);

  @override
  State<_NavRow> createState() => _NavRowState();
}

class _NavRowState extends State<_NavRow> {
  bool _checked = false;

  bool get _shouldShowBox =>
      widget.left == 52 || widget.left == 54 || widget.left == 82 || widget.left == 20;

  void _toggle() => setState(() => _checked = !_checked);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.left,
      top: widget.top,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_shouldShowBox) ...[
            GestureDetector(
              onTap: _toggle,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: _checked ? const Color(0xFFE50914) : const Color(0xFF141129),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(
                    color: _checked ? const Color(0xFFE50914) : Colors.white.withOpacity(0.12),
                    width: 1,
                  ),
                ),
                child: _checked
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Opacity(
            opacity: 0.50,
            child: Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Onest',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
