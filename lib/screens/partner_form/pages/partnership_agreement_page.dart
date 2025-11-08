import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:spotseeker_app/utils/colors.dart';
import 'package:spotseeker_app/widgets/signature_pad.dart';

enum ContractStatus { pending, rejected, generated }

class PartnershipAgreementPage extends StatefulWidget {
  final Function(bool hasAgreed, bool hasSignature) onStateChanged;

  const PartnershipAgreementPage({
    super.key,
    required this.onStateChanged,
  });

  @override
  State<PartnershipAgreementPage> createState() => _PartnershipAgreementPageState();
}

class _PartnershipAgreementPageState extends State<PartnershipAgreementPage> {
  ContractStatus _status = ContractStatus.pending;
  bool _hasAgreed = false;
  Uint8List? _signatureData;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _status = ContractStatus.generated;
        });
      }
    });
  }

  void _updateParentState() {
    widget.onStateChanged(_hasAgreed, _signatureData != null);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: _buildViewForStatus(),
    );
  }

  Widget _buildViewForStatus() {
    switch (_status) {
      case ContractStatus.pending:
        return _buildStatusView(
          key: const ValueKey('pending'),
          iconPath: 'assets/agreement.gif',
          statusText: 'Pending',
          statusColor: Colors.orange,
          message: 'Hang tight!\nWe\'re preparing your contract.\nYou\'ll be notified once it\'s ready to be signed.',
        );
      case ContractStatus.rejected:
        return _buildStatusView(
          key: const ValueKey('rejected'),
          iconPath: 'assets/agreement.gif',
          statusText: 'Rejected',
          statusColor: Colors.red,
          message: 'Your contract has been rejected as some details require correction!',
          button: ElevatedButton(
            onPressed: () { /* TODO: Navigate back */ },
            child: const Text('Resolve Issues'),
          ),
        );
      case ContractStatus.generated:
        return _buildGeneratedView(key: const ValueKey('generated'));
    }
  }
  
  // --- THIS IS THE MISSING CODE ---

  Widget _buildStatusView({
    required Key key,
    required String iconPath,
    required String statusText,
    required Color statusColor,
    required String message,
    Widget? button,
  }) {
    return Column(
      key: key,
      children: [
        Image.asset(iconPath, height: 120),
        const SizedBox(height: 30),
        _buildStatusChip(text: statusText, color: statusColor),
        const SizedBox(height: 20),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: hintTextColor, fontSize: 16, height: 1.5),
        ),
        if (button != null) ...[
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0), // Give button some padding
            child: button,
          ),
        ]
      ],
    );
  }

  Widget _buildGeneratedView({required Key key}) {
    return Column(
      key: key,
      children: [
        Image.asset('assets/agreement.gif', height: 120),
        const SizedBox(height: 30),
        _buildStatusChip(text: 'Contract Generated', color: Colors.green, icon: Icons.check_circle),
        const SizedBox(height: 20),
        const Text(
          'All set!\nYou\'re ready to proceed with the partnership agreement.',
          textAlign: TextAlign.center,
          style: TextStyle(color: hintTextColor, fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 30),
        _buildPdfDownloadLink(),
        const SizedBox(height: 20),
        _buildAgreementCheckbox(),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) {
            return SizeTransition(
              sizeFactor: animation,
              axisAlignment: -1.0,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: _hasAgreed
              ? (_signatureData == null ? _buildSignatureBox() : _buildSignatureDisplay())
              : const SizedBox.shrink(key: ValueKey('empty_signature')),
        ),
      ],
    );
  }

  Widget _buildStatusChip({required String text, required Color color, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, color: color, size: 16),
          if (icon != null) const SizedBox(width: 6),
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPdfDownloadLink() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Image.asset('assets/pdf_icon.png', height: 24),
          const SizedBox(width: 12),
          const Expanded(child: Text('Partnership Contract', style: TextStyle(color: textColor))),
          IconButton(
            icon: const Icon(Icons.download_for_offline_outlined, color: hintTextColor),
            onPressed: () { /* TODO: Implement PDF download */ },
          )
        ],
      ),
    );
  }
  
  // --- END OF MISSING CODE ---

  Widget _buildAgreementCheckbox() {
    return GestureDetector(
      onTap: () {
        setState(() => _hasAgreed = !_hasAgreed);
        _updateParentState();
      },
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _hasAgreed ? Colors.green : Colors.transparent,
              border: Border.all(color: _hasAgreed ? Colors.green : hintTextColor),
              borderRadius: BorderRadius.circular(4),
            ),
            child: _hasAgreed
                ? const Icon(Icons.check, color: Colors.black87, size: 18)
                : null,
          ),
          const SizedBox(width: 12),
          const Expanded(child: Text('I agree to the Terms & Conditions.', style: TextStyle(color: textColor))),
        ],
      ),
    );
  }

  Widget _buildSignatureBox() {
    return InkWell(
      key: const ValueKey('signature_box'),
      onTap: () async {
        final signature = await showSignaturePad(context);
        if (signature != null) {
          setState(() => _signatureData = signature);
          _updateParentState();
        }
      },
      child: Container(
        height: 100,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: const Center(
          child: Text('Signature', style: TextStyle(color: hintTextColor, fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildSignatureDisplay() {
    return InkWell(
      key: const ValueKey('signature_display'),
      onTap: () async {
        final signature = await showSignaturePad(context);
        if (signature != null) {
          setState(() => _signatureData = signature);
          _updateParentState();
        }
      },
      child: Container(
        height: 100,
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Image.memory(_signatureData!),
      ),
    );
  }
}