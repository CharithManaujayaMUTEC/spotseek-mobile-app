import 'package:flutter/material.dart';
import 'package:spotseeker_app/widgets/background_gradient.dart';

class BankDetailsEditScreen extends StatefulWidget {
  final String? bankName;
  final String? accountHolder;
  final String? accountNumber;
  final String? bankId;
  final String? branch;
  final Function(Map<String, dynamic>)? onSave;
  final VoidCallback? onCancel;

  const BankDetailsEditScreen({
    super.key,
    this.bankName,
    this.accountHolder,
    this.accountNumber,
    this.bankId,
    this.branch,
    this.onSave,
    this.onCancel,
  });

  @override
  State<BankDetailsEditScreen> createState() => _BankDetailsEditScreenState();
}

class _BankDetailsEditScreenState extends State<BankDetailsEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _bankNameController;
  late TextEditingController _accountHolderController;
  late TextEditingController _accountNumberController;

  @override
  void initState() {
    super.initState();
    _bankNameController = TextEditingController(text: widget.bankName ?? '');
    _accountHolderController =
        TextEditingController(text: widget.accountHolder ?? '');
    _accountNumberController =
        TextEditingController(text: widget.accountNumber ?? '');
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountHolderController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  void _saveDetails() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'bankName': _bankNameController.text,
        'accountHolder': _accountHolderController.text,
        'accountNumber': _accountNumberController.text,
        'bankId': widget.bankId,
      };

      // Use callback if provided, otherwise use Navigator.pop
      if (widget.onSave != null) {
        widget.onSave!(data);
      } else {
        Navigator.pop(context, data);
      }
    }
  }

  void _cancel() {
    if (widget.onCancel != null) {
      widget.onCancel!();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: backgroundGradient(),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button and title
                      Row(
                        children: [
                          IconButton(
                            onPressed: _cancel,
                            icon: const Icon(Icons.arrow_back),
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Bank Details',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Bank Name Field

                              TextFormField(
                                controller: _bankNameController,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: 'Enter bank name',
                                  hintStyle:
                                      const TextStyle(color: Color(0xFF9E9E9E)),
                                  filled: true,
                                  fillColor:
                                      const Color(0xFFFFFFFF).withOpacity(0.02),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                        color: const Color(0xFF9E9E9E)
                                            .withOpacity(0.2)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                        color: const Color(0xFF9E9E9E)
                                            .withOpacity(0.2)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                        color: Colors.deepPurple.shade200,
                                        width: 1.5),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter bank name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),

                              // Account Holder Field

                              TextFormField(
                                controller: _accountHolderController,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: 'Enter account holder name',
                                  hintStyle:
                                      const TextStyle(color: Color(0xFF9E9E9E)),
                                  filled: true,
                                  fillColor:
                                      const Color(0xFFFFFFFF).withOpacity(0.02),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                        color: const Color(0xFF9E9E9E)
                                            .withOpacity(0.2)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                        color: const Color(0xFF9E9E9E)
                                            .withOpacity(0.2)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                        color: Colors.deepPurple.shade200,
                                        width: 1.5),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter account holder name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),

                              // Account Number Field

                              TextFormField(
                                controller: _accountNumberController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: 'Enter account number',
                                  hintStyle:
                                      const TextStyle(color: Color(0xFF9E9E9E)),
                                  filled: true,
                                  fillColor:
                                      const Color(0xFFFFFFFF).withOpacity(0.02),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                        color: const Color(0xFF9E9E9E)
                                            .withOpacity(0.2)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                        color: const Color(0xFF9E9E9E)
                                            .withOpacity(0.2)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                        color: Colors.deepPurple.shade200,
                                        width: 1.5),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter account number';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveDetails,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
