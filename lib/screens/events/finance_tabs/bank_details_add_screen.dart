import 'package:flutter/material.dart';
import 'package:spotseeker_app/widgets/background_gradient.dart';

class BankDetailsAddScreen extends StatefulWidget {
  final Function(Map<String, dynamic>)? onSave;
  final VoidCallback? onCancel;

  const BankDetailsAddScreen({super.key, this.onSave, this.onCancel});

  @override
  State<BankDetailsAddScreen> createState() => _BankDetailsAddScreenState();
}

class _BankDetailsAddScreenState extends State<BankDetailsAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountHolderController =
      TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _branchController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountHolderController.dispose();
    _accountNumberController.dispose();
    _branchController.dispose();
    super.dispose();
  }

  void _saveDetails() {
    FocusScope.of(context).unfocus();
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the errors and try again.')),
      );
      return;
    }

    setState(() => _submitting = true);
    final data = {
      'bankName': _bankNameController.text.trim(),
      'accountName': _accountHolderController.text.trim(),
      'accountNumber': _accountNumberController.text.trim(),
      'branch': _branchController.text.trim(),
    };

    // Use callback if provided, otherwise use Navigator.pop
    try {
      if (widget.onSave != null) {
        widget.onSave!(data);
      } else {
        Navigator.pop(context, data);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
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
                  autovalidateMode: AutovalidateMode.onUserInteraction,
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
                            'Add New Bank Details',
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
                                textInputAction: TextInputAction.next,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: 'Bank Name',
                                  hintStyle:
                                      const TextStyle(color: Color(0xFF9E9E9E)),
                                  filled: true,
                                  fillColor:
                                      const Color(0xFFFFFFFF).withOpacity(0.12),
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
                                  errorStyle:
                                      const TextStyle(color: Colors.redAccent),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter bank name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),

                              // Account Holder Field

                              TextFormField(
                                controller: _accountHolderController,
                                textInputAction: TextInputAction.next,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: 'Account Holder Name',
                                  hintStyle:
                                      const TextStyle(color: Color(0xFF9E9E9E)),
                                  filled: true,
                                  fillColor:
                                      const Color(0xFFFFFFFF).withOpacity(0.12),
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
                                  errorStyle:
                                      const TextStyle(color: Colors.redAccent),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
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
                                textInputAction: TextInputAction.done,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: 'Account Number',
                                  hintStyle:
                                      const TextStyle(color: Color(0xFF9E9E9E)),
                                  filled: true,
                                  fillColor:
                                      const Color(0xFFFFFFFF).withOpacity(0.12),
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
                                  errorStyle:
                                      const TextStyle(color: Colors.redAccent),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter account number';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),

                              // Branch Field (optional)

                              TextFormField(
                                controller: _branchController,
                                textInputAction: TextInputAction.done,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: 'Branch (optional)',
                                  hintStyle:
                                      const TextStyle(color: Color(0xFF9E9E9E)),
                                  filled: true,
                                  fillColor:
                                      const Color(0xFFFFFFFF).withOpacity(0.12),
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
                          onPressed: _submitting ? null : _saveDetails,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _submitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
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
