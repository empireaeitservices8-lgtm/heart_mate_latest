import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../signup/view_model/signup_viewmodel.dart';
import '../../repositories/app_repository.dart';
import 'payment_simulation_dialog.dart';

class AgentWalletScreen extends StatefulWidget {
  const AgentWalletScreen({super.key});

  @override
  State<AgentWalletScreen> createState() => _AgentWalletScreenState();
}

class _AgentWalletScreenState extends State<AgentWalletScreen> {
  final AppRepository _appRepository = AppRepository();
  List<Map<String, dynamic>> _packages = [];
  bool _isPackagesLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPackages();
      final viewModel = Provider.of<SignUpViewModel>(context, listen: false);
      viewModel.fetchCoins();
      viewModel.fetchTransactions();
    });
  }

  void _loadPackages() async {
    setState(() {
      _isPackagesLoading = true;
    });
    try {
      final pkgs = await _appRepository.getCoinPackages();
      setState(() {
        _packages = pkgs;
      });
    } catch (e) {
      print('Error loading packages: $e');
    } finally {
      setState(() {
        _isPackagesLoading = false;
      });
    }
  }

  void _startSecurePayment(Map<String, dynamic> package) async {
    final viewModel = Provider.of<SignUpViewModel>(context, listen: false);
    final coins = (package['coins'] as num).toInt();
    final price = (package['price'] as num).toDouble();

    // 1. Show order initiation loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppTheme.accentRose),
      ),
    );

    try {
      // 2. Initiate order on backend
      final orderResult = await viewModel.initiateSecureCheckoutOrder(package['id'], price);
      final String orderId = orderResult['order_id'] ?? '';

      if (mounted) {
        Navigator.pop(context); // Dismiss order loader
      }

      // 3. Open Razorpay Simulation dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => PaymentSimulationDialog(
            orderId: orderId,
            coins: coins,
            price: price,
            onPaymentCompleted: (razorpayResponse) async {
              // 4. Show verification loader
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(color: AppTheme.accentRose),
                ),
              );

              // 5. Verify payment & credit coins
              final success = await viewModel.verifyAndCreditCoins(
                orderId: razorpayResponse['razorpay_order_id']!,
                paymentId: razorpayResponse['razorpay_payment_id']!,
                signature: razorpayResponse['razorpay_signature']!,
                coinsAmount: coins,
                price: price,
              );

              if (mounted) {
                Navigator.pop(context); // Dismiss verification loader
              }

              if (success) {
                _showSuccessSheet(coins);
              } else {
                _showFailureDialog(viewModel.errorMessage ?? 'Payment verification failed.');
              }
            },
            onPaymentCancelled: () {
              _showFailureDialog('Payment was not completed. (User cancelled)');
            },
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dismiss order loader
      }
      _showFailureDialog('Failed to create payment order. Network error.');
    }
  }

  void _showSuccessSheet(int coins) {
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
                color: AppTheme.callGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.callGreen,
                size: 56,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Coins Credited!',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Successfully added $coins coins to your wallet balance after verifying the transaction.',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.textPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Great!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFailureDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppTheme.borderTranslucent),
        ),
        title: const Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text(
              'Payment Failed',
              style: TextStyle(color: AppTheme.textPrimary),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: AppTheme.accentRose, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SignUpViewModel>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundObsidian,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 32),
                    const Text(
                      'My Wallet',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: AppTheme.textPrimary, size: 22),
                      onPressed: () {
                        viewModel.fetchCoins();
                        viewModel.fetchTransactions();
                      },
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),

                      // Premium Balance Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: AppTheme.glowShadow(AppTheme.accentViolet),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: -15,
                              bottom: -20,
                              child: Icon(
                                Icons.monetization_on_rounded,
                                size: 120,
                                color: Colors.white.withOpacity(0.12),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                      'Agent Coin Earnings',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'CURRENT COIN BALANCE',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    viewModel.isCoinsLoading && viewModel.coins == 0
                                        ? const SizedBox(
                                            height: 32,
                                            width: 32,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : Text(
                                            viewModel.coins.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 38,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Coins',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Transactions list
                      const Text(
                        "TRANSACTION HISTORY",
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (viewModel.isAgentTransactionsLoading && viewModel.agentTransactions.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: CircularProgressIndicator(color: AppTheme.accentRose),
                          ),
                        )
                      else if (viewModel.agentTransactions.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceCard,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.borderTranslucent),
                          ),
                          child: const Center(
                            child: Text(
                              'No transactions logged yet.',
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: viewModel.agentTransactions.length,
                          itemBuilder: (context, index) {
                            final tx = viewModel.agentTransactions[index];
                            final isCredit = tx['type'] == 'purchase';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceCard,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppTheme.borderTranslucent),
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
                                      isCredit ? Icons.add_circle_outline_rounded : Icons.remove_circle_outline_rounded,
                                      color: isCredit ? AppTheme.callGreen : AppTheme.accentRose,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tx['title'] ?? 'Transaction',
                                          style: const TextStyle(
                                            color: AppTheme.textPrimary,
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          tx['subtitle'] ?? 'Details',
                                          style: const TextStyle(
                                            color: AppTheme.textSecondary,
                                            fontSize: 12,
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
                                          fontSize: 15,
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
                        ),
                      const SizedBox(height: 36),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
