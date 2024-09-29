import 'package:buybit/data/modal/wallet.dart';
import 'package:buybit/data/modal/wallet_history.dart';
import 'package:buybit/data/provider/wallet_provider.dart';
import 'package:buybit/data/repository/wallet_history_repository.dart';
import 'package:buybit/data/repository/wallet_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late WalletProvider walletProvider;
  final WalletRepository walletRepo = WalletRepository.instance;
  List<Wallet> wallets = [];
  List<WalletHistory> walletHistories = [];
  Wallet? defaultWallet;
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadWallets();
    _loadWalletHistory();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    walletProvider = Provider.of<WalletProvider>(context);
    _loadWallets();
  }

  Future<void> _loadWallets() async {
    wallets = await walletRepo.getAllUserWallets();
    defaultWallet = wallets.firstWhere((wallet) => wallet.isDefault,
        orElse: () => wallets[0]);
    setState(() {});
  }

  Future<void> _loadWalletHistory() async {
    try {
      final wallets = await walletRepo.getAllUserWallets();
      walletHistories =
          await WalletHistoryRepository().getAllWalletHistories(wallets);
      _filterWalletHistory();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load wallet history')),
      );
    } finally {
      setState(() {});
    }
  }

  void _filterWalletHistory() {
    final DateTime now = DateTime.now();
    final Duration duration;

    switch (selectedFilter) {
      case '1 Day':
        duration = const Duration(days: 1);
        break;
      case '3 Days':
        duration = const Duration(days: 3);
        break;
      case '7 Days':
        duration = const Duration(days: 7);
        break;
      case '28 Days':
        duration = const Duration(days: 28);
        break;
      case '90 Days':
        duration = const Duration(days: 90);
        break;
      default:
        walletHistories.sort((a, b) => b.date.compareTo(a.date));
        return;
    }

    walletHistories = walletHistories.where((history) {
      return now.difference(history.date) <= duration;
    }).toList();

    walletHistories.sort((a, b) => b.date.compareTo(a.date));
  }

  void _createWallet(String walletName, String currency) async {
    await walletRepo.createWallet(walletName, currency);
    _loadWallets();
  }

  void _setDefaultWallet(Wallet wallet) async {
    await walletRepo.setDefaultWallet(wallet.id);
    defaultWallet = wallet;
    _loadWallets();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Default wallet changed to ${wallet.name}')),
    );
  }

  void _editWalletName(Wallet wallet, String newName) async {
    await walletRepo.updateWalletName(wallet.id, newName);
    _loadWallets();
  }

  void _topUpWallet(String walletId, double amount) async {
    try {
      await walletRepo.topUpWallet(walletId, amount);

      final WalletHistory history = WalletHistory(
        id: UniqueKey().toString(),
        walletId: walletId,
        action: 'top-up',
        amount: amount,
        date: DateTime.now(),
      );
      await WalletHistoryRepository().addHistory(history);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Successfully topped up $amount to the wallet.')),
      );
    } catch (e) {
      final WalletHistory failedHistory = WalletHistory(
        id: UniqueKey().toString(),
        walletId: walletId,
        action: 'top-up failed',
        amount: amount,
        date: DateTime.now(),
      );
      await WalletHistoryRepository().addHistory(failedHistory);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to top up wallet')),
      );
    } finally {
      _loadWallets();
      _loadWalletHistory();
    }
  }

  void _withdrawWallet(String walletId, double amount) async {
    try {
      await walletRepo.withdrawWallet(walletId, amount);

      final WalletHistory history = WalletHistory(
        id: UniqueKey().toString(),
        walletId: walletId,
        action: 'withdrawal',
        amount: amount,
        date: DateTime.now(),
      );
      await WalletHistoryRepository().addHistory(history);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Successfully withdrew $amount from the wallet.')),
      );
    } catch (e) {
      final WalletHistory failedHistory = WalletHistory(
        id: UniqueKey().toString(),
        walletId: walletId,
        action: 'withdrawal failed',
        amount: amount,
        date: DateTime.now(),
      );
      await WalletHistoryRepository().addHistory(failedHistory);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to withdraw from wallet')),
      );
    } finally {
      _loadWallets();
      _loadWalletHistory();
    }
  }

  String formatDateTime(DateTime dateTime) {
    return "${dateTime.year.toString().padLeft(4, '0')}-"
        "${(dateTime.month).toString().padLeft(2, '0')}-"
        "${(dateTime.day).toString().padLeft(2, '0')} "
        "${(dateTime.hour).toString().padLeft(2, '0')}:"
        "${(dateTime.minute).toString().padLeft(2, '0')}:"
        "${(dateTime.second).toString().padLeft(2, '0')}";
  }

  String formatBalance(double balance) {
    return balance < 0 ? balance.toString() : balance.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    walletProvider = Provider.of<WalletProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 58, 166, 254),
        title: const Row(
          children: [
            Icon(Icons.wallet, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'My Account',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18.0, 12.0, 18.0, 0.0),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Balance (USD)',
                        style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 2),
                    Consumer<WalletProvider>(
                      builder: (context, walletProvider, child) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatBalance(
                                  walletProvider.calculateTotalBalance()),
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _displayTopUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'Top Up',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'Transfer',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _showWithdrawOptions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.remove, size: 12), // Icon size set to 8
                        SizedBox(width: 4),
                        Text(
                          'Withdraw',
                          style: TextStyle(
                            fontSize: 12, // Text size set to 8
                            fontWeight: FontWeight.bold, // Bold text
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(18.0, 0.0, 18.0, 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Wallets'),
                IconButton(
                  onPressed: _displayCreateWallet,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(18.0, 0.0, 18.0, 0.0),
              itemCount: wallets.length,
              itemBuilder: (context, index) {
                final wallet = wallets[index];
                return GestureDetector(
                  onDoubleTap: () {
                    _setDefaultWallet(wallet);
                  },
                  onLongPress: () {
                    _displayEditWallet(wallet);
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(
                        color: wallet.isDefault
                            ? Colors.green
                            : const Color.fromARGB(255, 193, 193, 193),
                        width: wallet.isDefault ? 3 : 0,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ListTile(
                              title: Text(
                                wallet.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(wallet.id),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.copy),
                                        onPressed: () {
                                          Clipboard.setData(
                                              ClipboardData(text: wallet.id));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Wallet ID copied to clipboard')),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  Text(
                                      'Balance (${wallet.currency}): ${formatBalance(wallet.balance)}'),
                                ],
                              ),
                            ),
                          ),
                          if (wallet.isDefault)
                            const Padding(
                              padding: EdgeInsets.only(right: 12.0),
                              child: Text(
                                'Default',
                                style: TextStyle(
                                  color: Color.fromRGBO(76, 175, 80, 1),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // History Header with Dropdown
          Padding(
            padding: const EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('History',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  value: selectedFilter,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedFilter = newValue!;
                      _filterWalletHistory();
                    });
                  },
                  items: <String>[
                    'All',
                    '1 Day',
                    '3 Days',
                    '7 Days',
                    '28 Days',
                    '90 Days'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(18.0, 0.0, 18.0, 0.0),
              itemCount: walletHistories.length,
              itemBuilder: (context, index) {
                final history = walletHistories[index];
                final wallet =
                    wallets.firstWhere((w) => w.id == history.walletId);
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(history.action.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                )),
                            Text(
                              '${history.action == 'top-up' ? '+ ' : '- '}${formatBalance(history.amount)} ${wallet.currency}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: history.action == 'top-up'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatDateTime(history.date),
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _displayCreateWallet() {
    final TextEditingController nameController = TextEditingController();
    String selectedCurrency = 'USD';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Wallet'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Wallet Name'),
              ),
              DropdownButton<String>(
                value: selectedCurrency,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCurrency = newValue!;
                  });
                },
                items: <String>['USD']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Create'),
              onPressed: () {
                _createWallet(nameController.text, selectedCurrency);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _displayEditWallet(Wallet wallet) {
    final TextEditingController nameController =
        TextEditingController(text: wallet.name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Wallet Name'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Wallet Name'),
          ),
          actions: [
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                _editWalletName(wallet, nameController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _displayTopUp() {
    Wallet? selectedWallet;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Wallet to Top Up'),
              content: Container(
                width: 300,
                height: 400,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: wallets.map((wallet) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedWallet = wallet;
                                });
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: selectedWallet == wallet
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: ListTile(
                                  title: Text(wallet.name),
                                  subtitle: Text(
                                      'Balance (${wallet.currency}): ${formatBalance(wallet.balance)}'),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Next'),
                  onPressed: selectedWallet != null
                      ? () {
                          Navigator.of(context).pop();
                          if (selectedWallet != null) {
                            _showTopUpDialog(selectedWallet!);
                          }
                        }
                      : null,
                  style: TextButton.styleFrom(
                    backgroundColor:
                        selectedWallet != null ? Colors.blue : Colors.grey,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showWithdrawOptions() {
    Wallet? selectedWallet;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Wallet to Withdraw From'),
              content: Container(
                width: 300,
                height: 400,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: wallets.map((wallet) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedWallet = wallet;
                                });
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: selectedWallet == wallet
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: ListTile(
                                  title: Text(wallet.name),
                                  subtitle: Text(
                                      'Balance (${wallet.currency}): ${formatBalance(wallet.balance)}'),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Next'),
                  onPressed: selectedWallet != null
                      ? () {
                          Navigator.of(context).pop();
                          if (selectedWallet != null) {
                            _displayWithdraw(selectedWallet!);
                          }
                        }
                      : null,
                  style: TextButton.styleFrom(
                    backgroundColor:
                        selectedWallet != null ? Colors.blue : Colors.grey,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showTopUpDialog(Wallet wallet) {
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Top Up ${wallet.name}'),
          content: TextField(
            controller: amountController,
            decoration: const InputDecoration(labelText: 'Amount to Top Up'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              child: const Text('Top Up (USD)'),
              onPressed: () {
                final amount = double.tryParse(amountController.text) ?? 0.0;
                _topUpWallet(wallet.id, amount);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _displayWithdraw(Wallet wallet) {
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Withdraw from ${wallet.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'Available Balance (${wallet.currency}): ${formatBalance(wallet.balance)}'),
              TextField(
                controller: amountController,
                decoration:
                    const InputDecoration(labelText: 'Amount to Withdraw'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Withdraw'),
              onPressed: () {
                final amount = double.tryParse(amountController.text) ?? 0.0;
                _withdrawWallet(wallet.id, amount);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
