import 'package:flutter/material.dart';
import 'package:dating_app/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:dating_app/screens/signup/view_model/signup_viewmodel.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final signupVM = Provider.of<SignUpViewModel>(context, listen: false);
      signupVM.fetchCoins();
      signupVM.fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final signupVM = Provider.of<SignUpViewModel>(context);
    final transactions = signupVM.agentTransactions;
    final isLoading = signupVM.isAgentTransactionsLoading;
    final errorMessage = signupVM.transactionsError;

    return Scaffold(
      backgroundColor: AppTheme.backgroundObsidian,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.bgGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Coin History',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 48), // Spacing helper
                  ],
                ),
              ),

              // Wallet Balance Overview
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.borderTranslucent),
                    boxShadow: AppTheme.softCardShadow,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Wallet Balance',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${signupVM.coins} Coins',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.monetization_on_rounded,
                          color: AppTheme.accentGold,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Transactions List Section Header
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Text(
                    "RECENT TRANSACTIONS",
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

              // ListView of transactions
              Expanded(
                child: isLoading && transactions.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.accentRose,
                        ),
                      )
                    : errorMessage != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    color: AppTheme.accentRose,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    errorMessage,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      signupVM.fetchTransactions();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.accentRose,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : transactions.isEmpty
                            ? const Center(
                                child: Text(
                                  'No transactions yet',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                itemCount: transactions.length,
                                itemBuilder: (context, index) {
                                  final tx = transactions[index];
                                  final bool isIncome = tx['type'] == 'purchase';
                                  final IconData txIcon = tx['icon'] is IconData
                                      ? tx['icon'] as IconData
                                      : (isIncome
                                          ? Icons.add_circle_outline_rounded
                                          : Icons.remove_circle_outline_rounded);

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppTheme.surfaceCard,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: AppTheme.borderTranslucent),
                                    ),
                                    child: Row(
                                      children: [
                                        // Transaction Category Icon
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: isIncome
                                                ? AppTheme.callGreen.withOpacity(0.1)
                                                : AppTheme.accentRose.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            txIcon,
                                            color: isIncome ? AppTheme.callGreen : AppTheme.accentRose,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        
                                        // Title & Date
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                tx['title'] ?? 'Transaction',
                                                style: const TextStyle(
                                                  color: AppTheme.textPrimary,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                tx['subtitle'] ?? '',
                                                style: const TextStyle(
                                                  color: AppTheme.textSecondary,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Transaction amount
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              tx['amount'] ?? '0',
                                              style: TextStyle(
                                                color: isIncome ? AppTheme.callGreen : AppTheme.accentRose,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              tx['date'] ?? '',
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
