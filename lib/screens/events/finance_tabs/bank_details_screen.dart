import 'package:flutter/material.dart';
import 'package:spotseeker_app/models/event_model.dart';
import 'package:spotseeker_app/utils/colors.dart';
import 'package:spotseeker_app/widgets/background_gradient.dart';
import 'package:spotseeker_app/screens/events/finance_tabs/bank_details_edit_screen.dart';
import 'package:spotseeker_app/screens/events/finance_tabs/bank_details_add_screen.dart';
import 'package:spotseeker_app/services/finance_service.dart';

class BankAccount {
  final String id;
  String bankName;
  String accountNumber;
  String accountHolder;
  bool isSelected;
  String? branch;

  BankAccount({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolder,
    this.isSelected = false,
    this.branch,
  });
}

class BankDetails extends StatefulWidget {
  final EventModel event;
  final VoidCallback? onBack; // Optional callback to go back to withdraw funds
  final void Function(Map<String, dynamic>)? onSelect; // Return selected bank

  const BankDetails(
      {super.key, required this.event, this.onBack, this.onSelect});

  @override
  State<BankDetails> createState() => _BankDetailsState();
}

class _BankDetailsState extends State<BankDetails> {
  final FinanceService _service = FinanceService();
  List<BankAccount> accounts = [];
  bool _loading = true;
  String? _error;

  // Track which view to show
  String _currentView = 'list'; // 'list', 'add', 'edit'
  BankAccount? _editingAccount;

  @override
  void initState() {
    super.initState();
    _fetchAccounts();
  }

  Future<void> _fetchAccounts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await _service.listBankDetails();
      final mapped = rows.map((e) {
        // Prefer exact keys from sample response; keep legacy fallbacks
        final id = (e['id'] ?? e['bankId'] ?? '').toString();
        return BankAccount(
          id: id,
          bankName: (e['bankName'] ?? e['bank_name'] ?? '').toString(),
          accountNumber:
              (e['accountNumber'] ?? e['account_number'] ?? '').toString(),
          accountHolder: (e['accountName'] ??
                  e['accountHolder'] ??
                  e['account_holder'] ??
                  '')
              .toString(),
          branch: e['branch'] is String ? e['branch'] as String : null,
        );
      }).toList();
      setState(() {
        accounts = mapped;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void toggleSelection(String id) {
    setState(() {
      final index = accounts.indexWhere((account) => account.id == id);
      if (index != -1) {
        // Make this the only selected account
        for (var a in accounts) {
          a.isSelected = false;
        }
        accounts[index].isSelected = true;
      }
    });
    // Callback with selected account and close if requested
    final selected = accounts.firstWhere((a) => a.isSelected,
        orElse: () => BankAccount(
            id: '', bankName: '', accountNumber: '', accountHolder: ''));
    if (selected.id.isNotEmpty) {
      widget.onSelect?.call({
        'id': selected.id,
        'bankName': selected.bankName,
        'accountNumber': selected.accountNumber,
        'accountName': selected.accountHolder,
        'branch': selected.branch,
      });
      widget.onBack?.call();
    }
  }

  Future<void> deleteAccount(String id) async {
    try {
      final parsed = int.tryParse(id);
      if (parsed != null) {
        await _service.deleteBankDetailsById(parsed);
      }
      await _fetchAccounts();
    } catch (_) {}
  }

  void addAccount() {
    setState(() {
      _currentView = 'add';
    });
  }

  void editAccount(BankAccount account) {
    setState(() {
      _currentView = 'edit';
      _editingAccount = account;
    });
  }

  void _saveNewAccount(Map<String, dynamic> data) {
    // Persist via API then refresh
    try {
      print('[BankDetails] _saveNewAccount data: ' + data.toString());
    } catch (_) {}
    (() async {
      try {
        print('[BankDetails] calling addBankDetails');
        await _service.addBankDetails(
          bankName: (data['bankName'] ?? '').toString(),
          accountNumber: (data['accountNumber'] ?? '').toString(),
          accountName: (data['accountName'] ?? '').toString(),
          branch: (data['branch'] ?? '').toString(),
        );
        print('[BankDetails] addBankDetails success');
        await _fetchAccounts();
      } finally {
        if (mounted) setState(() => _currentView = 'list');
      }
    })();
  }

  void _saveEditedAccount(Map<String, dynamic> data) {
    (() async {
      try {
        final idStr = (data['bankId'] ?? '').toString();
        final id = int.tryParse(idStr);
        if (id != null) {
          await _service.updateBankDetails(
            id: id,
            bankName: (data['bankName'] ?? '').toString(),
            accountNumber: (data['accountNumber'] ?? '').toString(),
            accountName: (data['accountHolder'] ?? '').toString(),
            branch: (data['branch'] ?? '').toString(),
          );
        }
        await _fetchAccounts();
      } finally {
        if (mounted) {
          setState(() {
            _currentView = 'list';
            _editingAccount = null;
          });
        }
      }
    })();
  }

  void _cancelEdit() {
    setState(() {
      _currentView = 'list';
      _editingAccount = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show Add screen
    if (_currentView == 'add') {
      return BankDetailsAddScreen(
        onSave: _saveNewAccount,
        onCancel: _cancelEdit,
      );
    }

    // Show Edit screen
    if (_currentView == 'edit' && _editingAccount != null) {
      return BankDetailsEditScreen(
        bankId: _editingAccount!.id,
        bankName: _editingAccount!.bankName,
        accountHolder: _editingAccount!.accountHolder,
        accountNumber: _editingAccount!.accountNumber,
        branch: _editingAccount?.branch ?? null,
        onSave: _saveEditedAccount,
        onCancel: _cancelEdit,
      );
    }

    // Show Bank Details List (default)
    return Scaffold(
      body: Container(
        decoration: backgroundGradient(),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (widget.onBack != null)
                          IconButton(
                            onPressed: widget.onBack,
                            icon: const Icon(Icons.arrow_back),
                            color: Colors.white,
                          ),
                        if (widget.onBack != null) const SizedBox(width: 8),
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
                    const SizedBox(height: 24),
                    Expanded(
                      child: Builder(builder: (_) {
                        if (_loading) {
                          return const Center(
                            child: CircularProgressIndicator(
                                color: hintTextColor, strokeWidth: 2),
                          );
                        }
                        if (_error != null) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Failed to load: $_error',
                                    style: const TextStyle(color: Colors.red)),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: _fetchAccounts,
                                  child: const Text('Retry'),
                                )
                              ],
                            ),
                          );
                        }
                        if (accounts.isEmpty) {
                          return const Center(
                            child: Text('No bank accounts yet',
                                style: TextStyle(color: hintTextColor)),
                          );
                        }
                        return ListView.builder(
                          itemCount: accounts.length,
                          itemBuilder: (context, index) {
                            final account = accounts[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: _buildBankAccountCard(account),
                            );
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: addAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Add Another Bank Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildBankAccountCard(BankAccount account) {
    return Row(
      children: [
        // Checkbox in its own box
        Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Checkbox(
              value: account.isSelected,
              onChanged: (value) => toggleSelection(account.id),
              fillColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.green.shade500;
                }
                return Colors.grey.shade800;
              }),
              side: BorderSide(
                color: account.isSelected
                    ? Colors.green.shade500
                    : Colors.grey.shade600,
                width: 2,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Bank account details in another box
        Expanded(
          child: GestureDetector(
            onTap: () => editAccount(account),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0x662a1548),
                    const Color(0x661f0f3a),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.purple.shade900.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              account.bankName,
                              style: TextStyle(
                                color: Colors.grey.shade300,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              account.accountNumber,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => deleteAccount(account.id),
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.red.shade500,
                        tooltip: 'Delete account',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
