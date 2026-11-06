import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'customBtn.dart';
import 'db_helper.dart';

// --- BUTTON MODEL CLASS AND DATA LIST ---
class convButton {
  final String text;
  final Color? textColor;
  final Color? bgColor;
  convButton({
    required this.text,
    this.textColor,
    this.bgColor,
  });
}

final List<convButton> myConvButtons = [
  convButton(text: "7"),
  convButton(text: "8"),
  convButton(text: "9"),
  convButton(text: "4"),
  convButton(text: "5"),
  convButton(text: "6"),
  convButton(text: "1"),
  convButton(text: "2"),
  convButton(text: "3"),
  convButton(text: "00"),
  convButton(text: "0"),
  convButton(text: "."),
  convButton(text: "AC", textColor: Colors.indigo),
  convButton(text: "<-", textColor: Colors.indigo),
];

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final DBHelper _dbHelper = DBHelper();
  
  String topValue = "0.34";
  String bottomValue = "1.00";
  
  String topCurrency = "INR";
  String bottomCurrency = "PKR";
  
  bool isTopSelected = false;
  String searchQuery = "";
  
  bool isLoading = false;
  String lastUpdateTime = "";

  final Map<String, Map<String, dynamic>> allCurrencies = {
    "USD": {"name": "United States Dollar", "flag": "🇺🇸", "rate": 1.0},
    "PKR": {"name": "Pakistani Rupee", "flag": "🇵🇰", "rate": 278.40},
    "INR": {"name": "Indian Rupee", "flag": "🇮🇳", "rate": 83.50},
    "AED": {"name": "Emirati Dirham", "flag": "🇦🇪", "rate": 3.67},
    "SAR": {"name": "Saudi Riyal", "flag": "🇸🇦", "rate": 3.75},
    "GBP": {"name": "British Pound", "flag": "🇬🇧", "rate": 0.79},
    "EUR": {"name": "Euro", "flag": "🇪🇺", "rate": 0.92},
    "CAD": {"name": "Canadian Dollar", "flag": "🇨🇦", "rate": 1.37},
    "AUD": {"name": "Australian Dollar", "flag": "🇦🇺", "rate": 1.51},
    "SGD": {"name": "Singapore Dollar", "flag": "🇸🇬", "rate": 1.35},
    "KWD": {"name": "Kuwaiti Dinar", "flag": "🇰🇼", "rate": 0.31},
    "OMR": {"name": "Omani Rial", "flag": "🇴🇲", "rate": 0.38},
    "BHD": {"name": "Bahraini Dinar", "flag": "🇧🇭", "rate": 0.38},
    "QAR": {"name": "Qatari Riyal", "flag": "🇶🇦", "rate": 3.64},
    "TRY": {"name": "Turkish Lira", "flag": "🇹🇷", "rate": 32.85},
    "MYR": {"name": "Malaysian Ringgit", "flag": "🇲🇾", "rate": 4.71},
    "CNY": {"name": "Chinese Yuan", "flag": "🇨🇳", "rate": 7.26},
    "JPY": {"name": "Japanese Yen", "flag": "🇯🇵", "rate": 160.50},
    "NZD": {"name": "New Zealand Dollar", "flag": "🇳🇿", "rate": 1.64},
    "THB": {"name": "Thai Baht", "flag": "🇹🇭", "rate": 36.70},
    "ZAR": {"name": "South African Rand", "flag": "🇿🇦", "rate": 18.20},
    "ARS": {"name": "Argentine Peso", "flag": "🇦🇷", "rate": 915.00},
    "BDT": {"name": "Bangladeshi Taka", "flag": "🇧🇩", "rate": 117.50},
    "LKR": {"name": "Sri Lankan Rupee", "flag": "🇱🇰", "rate": 305.00},
  };

  Map<String, Map<String, dynamic>> currencies = {};

  @override
  void initState() {
    super.initState();
    // Lock to portrait only
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    currencies = Map.from(allCurrencies);
    _initializeRates();
  }

  @override
  void dispose() {
    // Reset to all orientations when leaving
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  Future<void> _initializeRates() async {
    setState(() => isLoading = true);
    
    final savedTopCurrency = await _dbHelper.getSavedTopCurrency();
    final savedBottomCurrency = await _dbHelper.getSavedBottomCurrency();
    
    if (savedTopCurrency.isNotEmpty && currencies.containsKey(savedTopCurrency)) {
      topCurrency = savedTopCurrency;
    }
    if (savedBottomCurrency.isNotEmpty && currencies.containsKey(savedBottomCurrency)) {
      bottomCurrency = savedBottomCurrency;
    }
    
    final savedData = await _dbHelper.getSavedCurrencyRates();
    final savedTime = await _dbHelper.getLastUpdateTime();
    
    if (savedData.isNotEmpty) {
      setState(() {
        currencies = savedData;
        lastUpdateTime = savedTime;
      });
      _updateConversion();
    }
    
    await _fetchLiveRates(showLoading: false);
    
    setState(() => isLoading = false);
  }

  Future<void> _saveSelectedCurrencies() async {
    await _dbHelper.saveSelectedCurrencies(topCurrency, bottomCurrency);
  }

  Future<void> _fetchLiveRates({bool showLoading = true}) async {
    if (showLoading) setState(() => isLoading = true);
    
    bool hasInternet = false;
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      hasInternet = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      hasInternet = false;
    }

    if (!hasInternet) {
      if (showLoading) {
        _showNoInternetSnack();
        setState(() => isLoading = false);
      }
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;
        
        setState(() {
          for (var entry in currencies.entries) {
            final code = entry.key;
            if (rates.containsKey(code)) {
              currencies[code]!['rate'] = (rates[code] as num).toDouble();
            }
          }
          currencies['USD']!['rate'] = 1.0;
          lastUpdateTime = _formatDateTime(DateTime.now());
        });
        
        await _dbHelper.saveCurrencyRatesWithTime(currencies, lastUpdateTime);
        await _dbHelper.saveCurrencyRates(currencies);
        
        _updateConversion();
        
        if (showLoading && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Rates updated successfully!'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (showLoading && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: ${e.toString()}'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    
    if (showLoading) setState(() => isLoading = false);
  }

  void _showNoInternetSnack() {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          lastUpdateTime.isEmpty 
              ? 'No internet. Using default rates.'
              : 'No internet. Using last saved rates.',
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.orange,
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", 
                    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return "${months[dt.month - 1]} ${dt.day}, ${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  void _updateConversion() {
    if (isTopSelected) {
      bottomValue = _convert(topValue, topCurrency, bottomCurrency);
    } else {
      topValue = _convert(bottomValue, bottomCurrency, topCurrency);
    }
  }

  void handleTap(String btnText) {
    setState(() {
      String currentInput = isTopSelected ? topValue : bottomValue;

      if (btnText == "AC") {
        currentInput = "0";
      } else if (btnText == "<-") {
        if (currentInput.length > 1) {
          currentInput = currentInput.substring(0, currentInput.length - 1);
        } else {
          currentInput = "0";
        }
      } else {
        if (currentInput == "0") {
          currentInput = btnText;
        } else {
          currentInput += btnText;
        }
      }

      if (isTopSelected) {
        topValue = currentInput;
        bottomValue = _convert(topValue, topCurrency, bottomCurrency);
      } else {
        bottomValue = currentInput;
        topValue = _convert(bottomValue, bottomCurrency, topCurrency);
      }
    });
  }

  String _convert(String amountStr, String fromCurrency, String toCurrency) {
    double amount = double.tryParse(amountStr) ?? 0.0;
    double fromRate = (currencies[fromCurrency]?["rate"] ?? 1.0) as double;
    double toRate = (currencies[toCurrency]?["rate"] ?? 1.0) as double;
    return ((amount / fromRate) * toRate).toStringAsFixed(2);
  }

  void _showMenu() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "CurrencyMenu",
      barrierColor: Colors.black.withOpacity(0.05),
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedValue = Curves.elasticOut.transform(animation.value);
        return Transform.scale(
          scale: curvedValue,
          alignment: const Alignment(0.9, -0.95),
          child: child,
        );
      },
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 60.0, right: 16.0),
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 220,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                  borderRadius: BorderRadius.circular(18.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _fetchLiveRates(showLoading: true);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.refresh_rounded,
                                size: 22,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Update Now',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider(
                        height: 1,
                        color: isDark ? Colors.white12 : Colors.black12,
                        indent: 16,
                        endIndent: 16,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 18,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              lastUpdateTime.isEmpty 
                                  ? 'Never updated' 
                                  : 'Last: $lastUpdateTime',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white38 : Colors.black38,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void openCurrencySelectionSheet(bool dynamicTopRow) {
    searchQuery = "";
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true, 
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            
            final filteredKeys = currencies.keys.where((code) {
              final name = currencies[code]!["name"].toString().toLowerCase();
              final matchesCode = code.toLowerCase().contains(searchQuery.toLowerCase());
              final matchesName = name.contains(searchQuery.toLowerCase());
              return matchesCode || matchesName;
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF121212) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(25.0)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(width: 45, height: 4.5, decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(10))),
                  const Padding(
                    padding: EdgeInsets.only(top: 20.0, bottom: 8.0),
                    child: Text("Select Currency", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: TextField(
                      onChanged: (value) {
                        setModalState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Search Country or Code...",
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredKeys.length,
                      itemBuilder: (context, index) {
                        final code = filteredKeys[index];
                        return ListTile(
                          leading: Text(currencies[code]!["flag"], style: const TextStyle(fontSize: 28)),
                          title: Text(code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Text(currencies[code]!["name"], style: const TextStyle(color: Colors.grey)),
                          onTap: () {
                            setState(() {
                              if (dynamicTopRow) {
                                topCurrency = code;
                                topValue = _convert(bottomValue, bottomCurrency, topCurrency);
                              } else {
                                bottomCurrency = code;
                                bottomValue = _convert(topValue, topCurrency, bottomCurrency);
                              }
                            });
                            _saveSelectedCurrencies();
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget buildButton(int index) {
    if (index >= myConvButtons.length) return const Expanded(child: SizedBox());
    
    final button = myConvButtons[index];
    if (button.text.isEmpty && button.bgColor == Colors.transparent) {
      return const Expanded(child: SizedBox());
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    Color finalBgColor = button.bgColor ?? theme.cardColor;
    List<String> actions = ["AC", "<-"];
    if (actions.contains(button.text)) {
      if (isDarkMode) {
        finalBgColor = const Color(0xFFFFB74D);
      } else {
        finalBgColor = Colors.indigo;
      }
    } else if (button.text.isEmpty) {
      return const Expanded(child: SizedBox()); 
    }

    Color finalTextColor = button.textColor ?? (isDarkMode ? Colors.white : Colors.black);
    if (actions.contains(button.text)) {
      finalTextColor = Colors.white;
    } else if (isDarkMode && ["7", "8", "9", "4", "5", "6", "1", "2", "3", "00", "0", "."].contains(button.text)) {
      finalTextColor = Colors.white;
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: CustomBtn(
          text: button.text,
          textColor: finalTextColor,
          bgColor: finalBgColor,
          onPressed: () {
            handleTap(button.text);
          },
        ),
      ),
    );
  }

  Widget buildScrollableText(String text, TextStyle style) {
    return SizedBox(
      width: 140,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Text(
          text,
          style: style,
          maxLines: 1,
          overflow: TextOverflow.visible,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gridBg = isDark ? const Color(0xFF1E1E1E) : const Color.fromARGB(255, 243, 232, 232);
    final activeColor = isDark ? const Color(0xFFFFB74D) : Colors.indigo;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Currency Conversion", 
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 22, fontWeight: FontWeight.w400),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
          IconButton(
            icon: Icon(Icons.more_vert_rounded, color: isDark ? Colors.white : Colors.black),
            onPressed: _showMenu,
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            InkWell(
              onTap: () => setState(() => isTopSelected = true),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
                color: isTopSelected
                    ? (isDark ? Colors.white10 : Colors.black.withOpacity(0.03))
                    : Colors.transparent,
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => openCurrencySelectionSheet(true),
                      child: Row(
                        children: [
                          Text(currencies[topCurrency]?["flag"] ?? "🇮🇳", style: const TextStyle(fontSize: 32)),
                          const SizedBox(width: 12),
                          Text(topCurrency, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        buildScrollableText(
                          topValue,
                          TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: isTopSelected
                                ? activeColor
                                : (isDark ? Colors.white : Colors.black),
                          ),
                        ),
                        Text(currencies[topCurrency]?["name"] ?? "", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Divider(),
            ),

            InkWell(
              onTap: () => setState(() => isTopSelected = false),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
                color: !isTopSelected
                    ? (isDark ? Colors.white10 : Colors.black.withOpacity(0.03))
                    : Colors.transparent,
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => openCurrencySelectionSheet(false),
                      child: Row(
                        children: [
                          Text(currencies[bottomCurrency]?["flag"] ?? "🇵🇰", style: const TextStyle(fontSize: 32)),
                          const SizedBox(width: 12),
                          Text(bottomCurrency, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        buildScrollableText(
                          bottomValue,
                          TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: !isTopSelected
                                ? activeColor
                                : (isDark ? Colors.white : Colors.black),
                          ),
                        ),
                        Text(currencies[bottomCurrency]?["name"] ?? "", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.only(left: 24.0, top: 20.0),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    lastUpdateTime.isEmpty 
                        ? "Never updated"
                        : "Updated on $lastUpdateTime",
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            Expanded(
              flex: 5,
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: gridBg,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                buildButton(0),
                                buildButton(1),
                                buildButton(2),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                buildButton(3),
                                buildButton(4),
                                buildButton(5),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                buildButton(6),
                                buildButton(7),
                                buildButton(8),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                buildButton(9),
                                buildButton(10),
                                buildButton(11),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Expanded(
                            child: buildButton(12),
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: buildButton(13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}