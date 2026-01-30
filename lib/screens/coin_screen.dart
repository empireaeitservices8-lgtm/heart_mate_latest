import 'package:flutter/material.dart';

class CoinBalanceScreen extends StatelessWidget {
  const CoinBalanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Exact colors from the image
    const Color bgColor = Color(0xFF222B32);
    const Color cardColor = Color(0xFF38444D);

    // Sample data for the coin packages
    final List<Map<String, String>> coinPackages = [
      {'coins': '1900.0', 'price': '₹ 99'},
      {'coins': '3800.0', 'price': '₹ 199'},
      {'coins': '12500.0', 'price': '₹ 499'},
      {'coins': '25000.0', 'price': '₹ 999'},
      {'coins': '55000.0', 'price': '₹ 1999'},
      {'coins': '125000.0', 'price': '₹ 4999'},
      {'coins': '230000.0', 'price': '₹ 9999'},
    ];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 45, 62, 75),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 45, 62, 75),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
        // gradient: LinearGradient(
        //   colors: [
        //     const Color.fromARGB(255, 21, 43, 65).withValues(alpha: 0.95),
        //     const Color.fromARGB(255, 239, 240, 240),
        //   ],
        // ),
          ),
        ),
        elevation: 0,
        actions: [
          TextButton(
        onPressed: () {},
        child: const Text(
          'History',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
        //   gradient: LinearGradient(
        // colors: [
        //             const Color.fromARGB(255, 21, 43, 65).withOpacity(0.95),

        //   const Color.fromARGB(255, 239, 240, 240),
        // ],
        //   ),
        ),
        child: Column(
        children: [
          // Balance Section
          const Text(
            'Current Balance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '150',
            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),

          // Grid of Coin Packages
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8, // Adjust for card height
                ),
                itemCount: coinPackages.length,
                itemBuilder: (context, index) {
                  return _buildCoinCard(
                    cardColor,
                    coinPackages[index]['coins']!,
                    coinPackages[index]['price']!,
                  );
                },
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildCoinCard(Color color, String coins, String price) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Spacer(),
          // Coin Icon (Replace with your actual asset)
          const Icon(
            Icons.monetization_on,
            color: Colors.orangeAccent,
            size: 40,
          ),
          const Spacer(),
          // White Banner for Coin Amount
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              coins,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFD84315), // Deep orange text
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          // Price text
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              price,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
