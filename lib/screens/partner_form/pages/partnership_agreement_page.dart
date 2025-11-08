import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:spotseeker_app/core/constants/api_constants.dart';
import 'package:spotseeker_app/models/partner/partner_models.dart';
import 'package:spotseeker_app/core/api/api_client.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:spotseeker_app/services/partner_service.dart';
import 'package:spotseeker_app/utils/colors.dart';
import 'package:spotseeker_app/widgets/signature_pad.dart';

enum ContractStatus { pending, rejected, accepted }

class PartnershipAgreementPage extends StatefulWidget {
  final Function(bool hasAgreed, bool hasSignature) onStateChanged;
  final Future<void> Function(List<String>? fieldsToResolve)? onResolveIssues;

  const PartnershipAgreementPage({
    super.key,
    required this.onStateChanged,
    this.onResolveIssues,
  });

  @override
  State<PartnershipAgreementPage> createState() =>
      _PartnershipAgreementPageState();
}

class _PartnershipAgreementPageState extends State<PartnershipAgreementPage> {
  ContractStatus _status = ContractStatus.pending;
  bool _hasAgreed = false;
  Uint8List? _signatureData;
  final PartnerService _partnerService = PartnerService();

  @override
  void initState() {
    _fetchStatus();
    super.initState();
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
          message:
              'Hang tight!\nWe\'re preparing your contract.\nYou\'ll be notified once it\'s ready to be signed.',
        );
      case ContractStatus.rejected:
        return _buildStatusView(
          key: const ValueKey('rejected'),
          iconPath: 'assets/agreement.gif',
          statusText: 'Rejected',
          statusColor: Colors.red,
          message:
              'Your contract has been rejected as some details require correction!',
          button: ElevatedButton(
            onPressed: () async {
              try {
                final ApplicationStatusUpdate statusUpdate =
                    await _partnerService.getApplicationStatus();
                await widget.onResolveIssues
                    ?.call(statusUpdate.fieldsToResolve);
              } catch (_) {
                await widget.onResolveIssues?.call(null);
              }
            },
            child: const Text('Resolve Issues'),
          ),
        );
      case ContractStatus.accepted:
        return _buildGeneratedView(key: const ValueKey('accepted'));
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
          style:
              const TextStyle(color: hintTextColor, fontSize: 16, height: 1.5),
        ),
        if (button != null) ...[
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 24.0), // Give button some padding
            child: button,
          ),
        ]
      ],
    );
  }

  Future<void> _fetchStatus() async {
    try {
      final applicationStatus = await _partnerService.getApplicationStatus();
      final normalizedStatus =
          applicationStatus.applicationStatus.toLowerCase();

      if (mounted) {
        setState(() => _status = normalizedStatus.toLowerCase() == 'pending'
            ? ContractStatus.pending
            : normalizedStatus.toLowerCase() == 'rejected'
                ? ContractStatus.rejected
                : ContractStatus.accepted);
      }
    } catch (_) {
      // keep default pending on errors
    }
  }

  // Expose data to parent without altering UI
  Uint8List? getSignatureData() => _signatureData;
  bool getHasAgreed() => _hasAgreed;

  Widget _buildGeneratedView({required Key key}) {
    return Column(
      key: key,
      children: [
        Image.asset('assets/agreement.gif', height: 120),
        const SizedBox(height: 30),
        _buildStatusChip(
            text: 'Contract Generated',
            color: Colors.green,
            icon: Icons.check_circle),
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
              ? (_signatureData == null
                  ? _buildSignatureBox()
                  : _buildSignatureDisplay())
              : const SizedBox.shrink(key: ValueKey('empty_signature')),
        ),
      ],
    );
  }

  Widget _buildStatusChip(
      {required String text, required Color color, IconData? icon}) {
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
          Text(text,
              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
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
          const Expanded(
              child: Text('Partnership Contract',
                  style: TextStyle(color: textColor))),
          IconButton(
            icon: const Icon(Icons.download_for_offline_outlined,
                color: hintTextColor),
            onPressed: _downloadApplicationPdf,
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
              border:
                  Border.all(color: _hasAgreed ? Colors.green : hintTextColor),
              borderRadius: BorderRadius.circular(4),
            ),
            child: _hasAgreed
                ? const Icon(Icons.check, color: Colors.black87, size: 18)
                : null,
          ),
          const SizedBox(width: 12),
          const Expanded(
              child: Text('I agree to the Terms & Conditions.',
                  style: TextStyle(color: textColor))),
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
          child: Text('Signature',
              style: TextStyle(color: hintTextColor, fontSize: 16)),
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

  Future<void> _downloadApplicationPdf() async {
    const String url =
        '${ApiConstants.mobileApiBaseUrl}/${ApiConstants.apiVersion}/partners/application-download';
    try {
      final dio = ApiClient().dio;
      final response = await dio.get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Accept': 'application/pdf',
          },
        ),
      );

      final bytes = response.data as List<int>;
      final dir = await getTemporaryDirectory();
      final filePath =
          '${dir.path}/partnership_application_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = await File(filePath).writeAsBytes(bytes);

      final fileUri = Uri.file(file.path);
      final canOpen = await canLaunchUrl(fileUri);
      if (canOpen) {
        await launchUrl(fileUri, mode: LaunchMode.platformDefault);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Downloaded to: ${file.path}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to download file')),
        );
      }
    }
  }
}
