import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../signup/view_model/signup_viewmodel.dart';

class AgentWalletScreen extends StatefulWidget {
  const AgentWalletScreen({super.key});

  @override
  State<AgentWalletScreen> createState() => _AgentWalletScreenState();
}

class _AgentWalletScreenState extends State<AgentWalletScreen> {
  int _selectedHistoryTab = 0; // 0: Withdrawals, 1: Earnings History

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAll();
    });
  }

  void _refreshAll() {
    final viewModel = Provider.of<SignUpViewModel>(context, listen: false);
    viewModel.fetchCoins();
    viewModel.fetchWithdrawals();
    viewModel.fetchTransactions();
    viewModel.fetchAgentDashboard();
  }

  void _openWithdrawalModal(BuildContext context, int availableCoins) {
    if (availableCoins < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text('Minimum withdrawal threshold is 100 Coins (₹100.00).'),
              ),
            ],
          ),
          backgroundColor: Colors.redAccent.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _WithdrawalBottomSheet(
        availableCoins: availableCoins,
        onSuccess: (refId) {
          _refreshAll();
          _showSuccessReceipt(refId);
        },
      ),
    );
  }

  void _showSuccessReceipt(String referenceId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(28),
        decoration: const BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(top: BorderSide(color: AppTheme.borderTranslucent)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.callGreen.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.callGreen,
                size: 56,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Withdrawal Requested!',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your payout request (Ref: $referenceId) is under verification. Transferred funds will be credited to your payout destination within 24 hours.',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentRose,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Understood',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SignUpViewModel>(context);
    final int coins = viewModel.coins;
    final double inrValue = coins * 1.0; // 1 Coin = ₹1

    // Calculate pending withdrawals
    double pendingAmount = 0.0;
    for (final w in viewModel.withdrawals) {
      if (w['status'] == 'pending' || w['status'] == 'processing') {
        final amt = w['amount'];
        if (amt is num) pendingAmount += amt.toDouble();
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundObsidian,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Agent Wallet',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Manage your earnings & withdrawals',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: AppTheme.textPrimary, size: 24),
                      onPressed: _refreshAll,
                      tooltip: 'Refresh Wallet',
                    ),
                  ],
                ),
              ),

              Expanded(
                child: RefreshIndicator(
                  color: AppTheme.accentRose,
                  onRefresh: () async => _refreshAll(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                      // Premium Earnings Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF9333EA), Color(0xFFEC4899)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF9333EA).withOpacity(0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
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
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.18),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.account_balance_wallet_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'AVAILABLE EARNINGS',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.verified_rounded, color: Colors.white, size: 14),
                                      SizedBox(width: 5),
                                      Text(
                                        'Verified Agent',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            // Cash value
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '₹${inrValue.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 34,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '($coins Coins)',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Payout Rate: 1 Coin = ₹1.00 INR',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Divider
                            Container(
                              height: 1,
                              color: Colors.white.withOpacity(0.18),
                            ),
                            const SizedBox(height: 16),

                            // Sub-metrics and Withdraw CTA
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'PENDING PAYOUTS',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.65),
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '₹${pendingAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => _openWithdrawalModal(context, coins),
                                  icon: const Icon(Icons.arrow_upward_rounded, size: 16),
                                  label: const Text(
                                    'Withdraw',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF6366F1),
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Quick Info Chips
                      Row(
                        children: [
                          Expanded(
                            child: _buildFeaturePill(
                              icon: Icons.flash_on_rounded,
                              iconColor: Colors.amberAccent,
                              title: 'Payout Speed',
                              subtitle: 'Within 24 Hours',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildFeaturePill(
                              icon: Icons.savings_rounded,
                              iconColor: AppTheme.callGreen,
                              title: 'Min. Payout',
                              subtitle: '₹100 (100 Coins)',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildFeaturePill(
                              icon: Icons.percent_rounded,
                              iconColor: AppTheme.accentRose,
                              title: 'Platform Fee',
                              subtitle: '0% Free Payout',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // History Tab Selection
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.borderTranslucent),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildTabButton(
                                label: 'Withdrawal Requests',
                                icon: Icons.payments_rounded,
                                isSelected: _selectedHistoryTab == 0,
                                onTap: () => setState(() => _selectedHistoryTab = 0),
                              ),
                            ),
                            Expanded(
                              child: _buildTabButton(
                                label: 'Earnings History',
                                icon: Icons.history_rounded,
                                isSelected: _selectedHistoryTab == 1,
                                onTap: () => setState(() => _selectedHistoryTab = 1),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Content of Selected Tab
                      if (_selectedHistoryTab == 0)
                        _buildWithdrawalsList(viewModel)
                      else
                        _buildTransactionsList(viewModel),

                      const SizedBox(height: 36),
                    ],
                  ),
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturePill({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderTranslucent),
        boxShadow: AppTheme.softCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentRose : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWithdrawalsList(SignUpViewModel viewModel) {
    if (viewModel.isWithdrawalsLoading && viewModel.withdrawals.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(color: AppTheme.accentRose),
        ),
      );
    }

    if (viewModel.withdrawals.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.borderTranslucent),
        ),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_rounded,
              size: 48,
              color: AppTheme.textSecondary.withOpacity(0.4),
            ),
            const SizedBox(height: 12),
            const Text(
              'No Withdrawal Requests Yet',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'When you request payouts, your request history & status updates will appear here.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: viewModel.withdrawals.length,
      itemBuilder: (context, index) {
        final item = viewModel.withdrawals[index];
        final amount = item['amount'] ?? 0;
        final coins = item['coins'] ?? 0;
        final method = (item['method'] ?? 'UPI').toString().toUpperCase();
        final status = (item['status'] ?? 'pending').toString().toLowerCase();
        final refId = item['reference_id'] ?? item['id'] ?? 'WD-${index + 1}';
        final date = item['date'] ?? 'Recently';

        Color statusColor = Colors.amberAccent;
        String statusLabel = 'Under Review';
        IconData statusIcon = Icons.hourglass_top_rounded;

        if (status == 'completed' || status == 'success') {
          statusColor = AppTheme.callGreen;
          statusLabel = 'Transferred';
          statusIcon = Icons.check_circle_rounded;
        } else if (status == 'processing') {
          statusColor = Colors.lightBlueAccent;
          statusLabel = 'Processing';
          statusIcon = Icons.sync_rounded;
        } else if (status == 'rejected') {
          statusColor = Colors.redAccent;
          statusLabel = 'Rejected';
          statusIcon = Icons.cancel_rounded;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.borderTranslucent),
            boxShadow: AppTheme.softCardShadow,
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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.accentRose.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_upward_rounded,
                          color: AppTheme.accentRose,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₹$amount ($coins Coins)',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$method Payout • $date',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Status pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, color: statusColor, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          statusLabel,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundObsidian.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ref: $refId',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const Text(
                      'Free Transfer',
                      style: TextStyle(
                        color: AppTheme.callGreen,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionsList(SignUpViewModel viewModel) {
    if (viewModel.isAgentTransactionsLoading && viewModel.agentTransactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(color: AppTheme.accentRose),
        ),
      );
    }

    if (viewModel.agentTransactions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.borderTranslucent),
        ),
        child: Column(
          children: [
            Icon(
              Icons.monetization_on_outlined,
              size: 48,
              color: AppTheme.textSecondary.withOpacity(0.4),
            ),
            const SizedBox(height: 12),
            const Text(
              'No Call Earnings Yet',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'When you complete audio and video calls with users, earnings will automatically be credited here.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: viewModel.agentTransactions.length,
      itemBuilder: (context, index) {
        final tx = viewModel.agentTransactions[index];
        final isCredit = tx['type'] == 'purchase' || tx['type'] == 'credit' || (tx['amount']?.toString().startsWith('+') ?? false);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.borderTranslucent),
            boxShadow: AppTheme.softCardShadow,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isCredit
                      ? AppTheme.callGreen.withOpacity(0.1)
                      : AppTheme.accentRose.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                  color: isCredit ? AppTheme.callGreen : AppTheme.accentRose,
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx['title'] ?? 'Earnings Transaction',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tx['subtitle'] ?? 'Call Reward',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    tx['amount'] ?? '0 Coins',
                    style: TextStyle(
                      color: isCredit ? AppTheme.callGreen : AppTheme.accentRose,
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tx['date'] ?? 'Today',
                    style: TextStyle(
                      color: AppTheme.textSecondary.withOpacity(0.7),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Interactive Withdrawal Bottom Sheet
// ---------------------------------------------------------------------------

class _WithdrawalBottomSheet extends StatefulWidget {
  final int availableCoins;
  final Function(String refId) onSuccess;

  const _WithdrawalBottomSheet({
    required this.availableCoins,
    required this.onSuccess,
  });

  @override
  State<_WithdrawalBottomSheet> createState() => _WithdrawalBottomSheetState();
}

class _WithdrawalBottomSheetState extends State<_WithdrawalBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _upiIdController = TextEditingController();
  final TextEditingController _upiNameController = TextEditingController();

  final TextEditingController _bankAccountController = TextEditingController();
  final TextEditingController _bankConfirmAccountController = TextEditingController();
  final TextEditingController _bankIfscController = TextEditingController();
  final TextEditingController _bankHolderNameController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();

  String _selectedMethod = 'UPI'; // 'UPI' or 'BANK'
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _upiIdController.dispose();
    _upiNameController.dispose();
    _bankAccountController.dispose();
    _bankConfirmAccountController.dispose();
    _bankIfscController.dispose();
    _bankHolderNameController.dispose();
    _bankNameController.dispose();
    super.dispose();
  }

  void _fillAmount(int coins) {
    setState(() {
      _amountController.text = coins.toString();
    });
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final coins = int.tryParse(_amountController.text.trim()) ?? 0;
    if (coins < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimum withdrawal is 100 Coins (₹100.00)')),
      );
      return;
    }
    if (coins > widget.availableCoins) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Withdrawal exceeds available balance.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final viewModel = Provider.of<SignUpViewModel>(context, listen: false);
    final Map<String, dynamic> payoutDetails = _selectedMethod == 'UPI'
        ? {
            'upi_id': _upiIdController.text.trim(),
            'name': _upiNameController.text.trim(),
          }
        : {
            'account_number': _bankAccountController.text.trim(),
            'ifsc': _bankIfscController.text.trim().toUpperCase(),
            'holder_name': _bankHolderNameController.text.trim(),
            'bank_name': _bankNameController.text.trim(),
          };

    final result = await viewModel.submitWithdrawal(
      coinsAmount: coins,
      cashAmount: coins * 1.0,
      method: _selectedMethod,
      payoutDetails: payoutDetails,
    );

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
    });

    if (result['success'] == true) {
      Navigator.pop(context);
      widget.onSuccess(result['reference_id'] ?? 'WD-SUCCESS');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Withdrawal failed.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: AppTheme.borderTranslucent)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top drag indicator
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Request Withdrawal',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textSecondary, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Available: ${widget.availableCoins} Coins (₹${widget.availableCoins.toDouble()})',
                style: const TextStyle(
                  color: AppTheme.callGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Payout Method Selector
              const Text(
                'CHOOSE PAYOUT METHOD',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildMethodSelector(
                      title: 'UPI (Instant)',
                      icon: Icons.account_balance_wallet_rounded,
                      method: 'UPI',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMethodSelector(
                      title: 'Bank Transfer',
                      icon: Icons.account_balance_rounded,
                      method: 'BANK',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Coins Amount Input
              const Text(
                'COINS AMOUNT TO WITHDRAW',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: 'Min. 100 Coins',
                  hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  prefixIcon: const Icon(Icons.monetization_on_rounded, color: AppTheme.accentGold),
                  suffixText: 'Coins',
                  suffixStyle: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
                  filled: true,
                  fillColor: AppTheme.backgroundObsidian,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppTheme.borderTranslucent),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppTheme.borderTranslucent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppTheme.accentRose, width: 1.5),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter coin amount.';
                  }
                  final parsed = int.tryParse(val.trim()) ?? 0;
                  if (parsed < 100) {
                    return 'Minimum withdrawal is 100 Coins.';
                  }
                  if (parsed > widget.availableCoins) {
                    return 'Amount exceeds available balance (${widget.availableCoins}).';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Quick fill chips
              Wrap(
                spacing: 8,
                children: [
                  _buildQuickChip('100 Coins (₹100)', 100),
                  if (widget.availableCoins >= 500) _buildQuickChip('500 Coins (₹500)', 500),
                  if (widget.availableCoins >= 1000) _buildQuickChip('1,000 Coins (₹1k)', 1000),
                  _buildQuickChip('MAX (${widget.availableCoins})', widget.availableCoins),
                ],
              ),
              const SizedBox(height: 22),

              // Dynamic Fields based on method
              if (_selectedMethod == 'UPI') ...[
                const Text(
                  'UPI DETAILS',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _upiIdController,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: _inputDecoration('UPI ID (e.g. yourname@upi / okaxis)', Icons.alternate_email_rounded),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'UPI ID is required';
                    if (!val.contains('@')) return 'Enter a valid UPI ID with @';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _upiNameController,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: _inputDecoration('Account Holder Name', Icons.person_outline_rounded),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Name is required' : null,
                ),
              ] else ...[
                const Text(
                  'BANK ACCOUNT DETAILS',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _bankHolderNameController,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: _inputDecoration('Account Holder Name', Icons.person_outline_rounded),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _bankNameController,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: _inputDecoration('Bank Name (e.g. HDFC, SBI)', Icons.business_rounded),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Bank name is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _bankAccountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: _inputDecoration('Account Number', Icons.credit_card_rounded),
                  validator: (val) => val == null || val.trim().length < 6 ? 'Enter valid account number' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _bankConfirmAccountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: _inputDecoration('Confirm Account Number', Icons.credit_card_rounded),
                  validator: (val) {
                    if (val != _bankAccountController.text) return 'Account numbers do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _bankIfscController,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: _inputDecoration('IFSC Code (e.g. HDFC0001234)', Icons.pin_drop_outlined),
                  validator: (val) => val == null || val.trim().length < 5 ? 'Enter valid IFSC code' : null,
                ),
              ],

              const SizedBox(height: 24),

              // Summary Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundObsidian,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderTranslucent),
                ),
                child: const Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Conversion Rate', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                        Text('1 Coin = ₹1.00 INR', style: TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Transfer Fee', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                        Text('₹0.00 (Free)', style: TextStyle(color: AppTheme.callGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Estimated Credit', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                        Text('Within 24 Hours', style: TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentRose,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          'Confirm & Submit Request',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodSelector({
    required String title,
    required IconData icon,
    required String method,
  }) {
    final isSelected = _selectedMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentRose.withOpacity(0.12) : AppTheme.backgroundObsidian,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.accentRose : AppTheme.borderTranslucent,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppTheme.accentRose : AppTheme.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppTheme.accentRose : AppTheme.textSecondary,
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChip(String label, int amount) {
    return ActionChip(
      label: Text(label),
      labelStyle: const TextStyle(color: AppTheme.textPrimary, fontSize: 11, fontWeight: FontWeight.bold),
      backgroundColor: AppTheme.backgroundObsidian,
      side: const BorderSide(color: AppTheme.borderTranslucent),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onPressed: () => _fillAmount(amount),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
      prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
      filled: true,
      fillColor: AppTheme.backgroundObsidian,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.borderTranslucent),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.borderTranslucent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.accentRose, width: 1.5),
      ),
    );
  }
}
