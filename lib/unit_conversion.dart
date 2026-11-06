import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // ← NEW: For orientation control
import 'customBtn.dart';

// ==================== UNIT CONVERSION DATA ====================

class ConversionCategory {
  final String name;
  final IconData icon;
  final List<ConversionUnit> units;

  ConversionCategory({
    required this.name,
    required this.icon,
    required this.units,
  });
}

class ConversionUnit {
  final String name;
  final String symbol;
  final double toBase;

  ConversionUnit({
    required this.name,
    required this.symbol,
    required this.toBase,
  });
}

// ==================== ALL CONVERSION DATA ====================

final List<ConversionCategory> conversionCategories = [
  ConversionCategory(
    name: "Length",
    icon: Icons.straighten,
    units: [
      ConversionUnit(name: "Millimeter", symbol: "mm", toBase: 0.001),
      ConversionUnit(name: "Centimeter", symbol: "cm", toBase: 0.01),
      ConversionUnit(name: "Meter", symbol: "m", toBase: 1.0),
      ConversionUnit(name: "Kilometer", symbol: "km", toBase: 1000.0),
      ConversionUnit(name: "Inch", symbol: "in", toBase: 0.0254),
      ConversionUnit(name: "Foot", symbol: "ft", toBase: 0.3048),
      ConversionUnit(name: "Yard", symbol: "yd", toBase: 0.9144),
      ConversionUnit(name: "Mile", symbol: "mi", toBase: 1609.344),
      ConversionUnit(name: "Nautical Mile", symbol: "nmi", toBase: 1852.0),
    ],
  ),
  ConversionCategory(
    name: "Area",
    icon: Icons.crop_square,
    units: [
      ConversionUnit(name: "Square Millimeter", symbol: "mm²", toBase: 0.000001),
      ConversionUnit(name: "Square Centimeter", symbol: "cm²", toBase: 0.0001),
      ConversionUnit(name: "Square Meter", symbol: "m²", toBase: 1.0),
      ConversionUnit(name: "Square Kilometer", symbol: "km²", toBase: 1000000.0),
      ConversionUnit(name: "Square Inch", symbol: "in²", toBase: 0.00064516),
      ConversionUnit(name: "Square Foot", symbol: "ft²", toBase: 0.092903),
      ConversionUnit(name: "Square Yard", symbol: "yd²", toBase: 0.836127),
      ConversionUnit(name: "Acre", symbol: "ac", toBase: 4046.86),
      ConversionUnit(name: "Hectare", symbol: "ha", toBase: 10000.0),
    ],
  ),
  ConversionCategory(
    name: "Volume",
    icon: Icons.invert_colors,
    units: [
      ConversionUnit(name: "Milliliter", symbol: "mL", toBase: 0.001),
      ConversionUnit(name: "Centiliter", symbol: "cL", toBase: 0.01),
      ConversionUnit(name: "Liter", symbol: "L", toBase: 1.0),
      ConversionUnit(name: "Cubic Meter", symbol: "m³", toBase: 1000.0),
      ConversionUnit(name: "Cubic Inch", symbol: "in³", toBase: 0.016387),
      ConversionUnit(name: "Cubic Foot", symbol: "ft³", toBase: 28.3168),
      ConversionUnit(name: "US Gallon", symbol: "gal", toBase: 3.78541),
      ConversionUnit(name: "US Quart", symbol: "qt", toBase: 0.946353),
      ConversionUnit(name: "US Pint", symbol: "pt", toBase: 0.473176),
      ConversionUnit(name: "US Cup", symbol: "cup", toBase: 0.236588),
      ConversionUnit(name: "US Fluid Ounce", symbol: "fl oz", toBase: 0.0295735),
      ConversionUnit(name: "UK Gallon", symbol: "UK gal", toBase: 4.54609),
    ],
  ),
  ConversionCategory(
    name: "Time",
    icon: Icons.access_time,
    units: [
      ConversionUnit(name: "Millisecond", symbol: "ms", toBase: 0.001),
      ConversionUnit(name: "Second", symbol: "s", toBase: 1.0),
      ConversionUnit(name: "Minute", symbol: "min", toBase: 60.0),
      ConversionUnit(name: "Hour", symbol: "h", toBase: 3600.0),
      ConversionUnit(name: "Day", symbol: "d", toBase: 86400.0),
      ConversionUnit(name: "Week", symbol: "wk", toBase: 604800.0),
      ConversionUnit(name: "Month", symbol: "mo", toBase: 2628000.0),
      ConversionUnit(name: "Year", symbol: "yr", toBase: 31536000.0),
    ],
  ),
  ConversionCategory(
    name: "Temperature",
    icon: Icons.thermostat,
    units: [
      ConversionUnit(name: "Celsius", symbol: "°C", toBase: 1.0),
      ConversionUnit(name: "Fahrenheit", symbol: "°F", toBase: 1.0),
      ConversionUnit(name: "Kelvin", symbol: "K", toBase: 1.0),
    ],
  ),
  ConversionCategory(
    name: "Weight",
    icon: Icons.fitness_center,
    units: [
      ConversionUnit(name: "Milligram", symbol: "mg", toBase: 0.000001),
      ConversionUnit(name: "Gram", symbol: "g", toBase: 0.001),
      ConversionUnit(name: "Kilogram", symbol: "kg", toBase: 1.0),
      ConversionUnit(name: "Metric Ton", symbol: "t", toBase: 1000.0),
      ConversionUnit(name: "Ounce", symbol: "oz", toBase: 0.0283495),
      ConversionUnit(name: "Pound", symbol: "lb", toBase: 0.453592),
      ConversionUnit(name: "Stone", symbol: "st", toBase: 6.35029),
      ConversionUnit(name: "US Ton", symbol: "ton", toBase: 907.185),
      ConversionUnit(name: "UK Ton", symbol: "UK ton", toBase: 1016.05),
    ],
  ),
];

// ==================== BUTTON MODEL ====================

class unitButton {
  final String text;
  final Color? textColor;
  final Color? bgColor;
  unitButton({
    required this.text,
    this.textColor,
    this.bgColor,
  });
}

final List<unitButton> myUnitButtons = [
  unitButton(text: "7"),
  unitButton(text: "8"),
  unitButton(text: "9"),
  unitButton(text: "4"),
  unitButton(text: "5"),
  unitButton(text: "6"),
  unitButton(text: "1"),
  unitButton(text: "2"),
  unitButton(text: "3"),
  unitButton(text: "00"),
  unitButton(text: "0"),
  unitButton(text: "."),
  unitButton(text: "AC"),
  unitButton(text: "<-"),
];

// ==================== MAIN SCREEN ====================

class UnitConversionScreen extends StatefulWidget {
  const UnitConversionScreen({super.key});

  @override
  State<UnitConversionScreen> createState() => _UnitConversionScreenState();
}

class _UnitConversionScreenState extends State<UnitConversionScreen> {
  int selectedCategoryIndex = 0;
  String topValue = "0";
  String bottomValue = "0";
  int topUnitIndex = 0;
  int bottomUnitIndex = 1;
  bool isTopSelected = true;

  // ========== LIFECYCLE: Lock on open, restore on close ==========  // ← NEW

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([                              // ← NEW
      DeviceOrientation.portraitUp,                                      // ← NEW
      DeviceOrientation.portraitDown,                                    // ← NEW
    ]);                                                                  // ← NEW
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([                              // ← NEW
      DeviceOrientation.portraitUp,                                      // ← NEW
      DeviceOrientation.portraitDown,                                    // ← NEW
      DeviceOrientation.landscapeLeft,                                   // ← NEW
      DeviceOrientation.landscapeRight,                                  // ← NEW
    ]);                                                                  // ← NEW
    super.dispose();
  }

  // ========== CONVERSION LOGIC ==========

  String convertValue(String value, int fromIndex, int toIndex) {
    if (value.isEmpty || value == "0") return "0";
    double? input = double.tryParse(value);
    if (input == null) return "0";
    final category = conversionCategories[selectedCategoryIndex];
    final fromUnit = category.units[fromIndex];
    final toUnit = category.units[toIndex];
    if (category.name == "Temperature") {
      return _convertTemperature(input, fromUnit.name, toUnit.name);
    }
    double baseValue = input * fromUnit.toBase;
    double result = baseValue / toUnit.toBase;
    return _formatResult(result);
  }

  String _convertTemperature(double value, String from, String to) {
    double result;
    double celsius;
    if (from == "Celsius") {
      celsius = value;
    } else if (from == "Fahrenheit") {
      celsius = (value - 32) * 5 / 9;
    } else {
      celsius = value - 273.15;
    }
    if (to == "Celsius") {
      result = celsius;
    } else if (to == "Fahrenheit") {
      result = (celsius * 9 / 5) + 32;
    } else {
      result = celsius + 273.15;
    }
    return _formatResult(result);
  }

  String _formatResult(double value) {
    if (value == 0) return "0";
    if (value.abs() < 0.000001 || value.abs() > 1000000000) {
      return value.toStringAsExponential(6);
    }
    String result = value.toStringAsFixed(10);
    result = result.replaceAll(RegExp(r'0+$'), '');
    if (result.endsWith('.')) {
      result = result.substring(0, result.length - 1);
    }
    return result;
  }

  // ========== BUTTON HANDLING ==========

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
      } else if (btnText == ".") {
        if (!currentInput.contains(".")) {
          currentInput += btnText;
        }
      } else {
        if (currentInput == "0") {
          currentInput = btnText;
        } else {
          if (currentInput.length < 15) {
            currentInput += btnText;
          }
        }
      }
      if (isTopSelected) {
        topValue = currentInput;
        bottomValue = convertValue(topValue, topUnitIndex, bottomUnitIndex);
      } else {
        bottomValue = currentInput;
        topValue = convertValue(bottomValue, bottomUnitIndex, topUnitIndex);
      }
    });
  }

  // ========== UNIT SELECTION SHEET ==========

  void openUnitSelectionSheet(bool isTop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final category = conversionCategories[selectedCategoryIndex];
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF121212) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(25.0)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 45,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 16.0),
                    child: Text(
                      "Select ${category.name} Unit",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: category.units.length,
                      itemBuilder: (context, index) {
                        final unit = category.units[index];
                        final isSelected = isTop ? index == topUnitIndex : index == bottomUnitIndex;
                        return ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark ? const Color(0xFFFFB74D) : Colors.indigo)
                                  : (isDark ? const Color(0xFF2C2C2C) : Colors.grey[200]),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                unit.symbol,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : null,
                                ),
                              ),
                            ),
                          ),
                          title: Text(unit.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                          subtitle: Text(unit.symbol, style: const TextStyle(color: Colors.grey)),
                          trailing: isSelected
                              ? Icon(Icons.check_circle, color: isDark ? const Color(0xFFFFB74D) : Colors.indigo)
                              : null,
                          onTap: () {
                            setState(() {
                              if (isTop) {
                                topUnitIndex = index;
                                bottomValue = convertValue(topValue, topUnitIndex, bottomUnitIndex);
                              } else {
                                bottomUnitIndex = index;
                                topValue = convertValue(bottomValue, bottomUnitIndex, topUnitIndex);
                              }
                            });
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

  // ========== BUTTON BUILDER WITH THEME ==========

  Widget buildButton(int index) {
    if (index >= myUnitButtons.length) return const Expanded(child: SizedBox());
    final button = myUnitButtons[index];
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color finalBgColor;
    List<String> actions = ["AC", "<-"];
    if (actions.contains(button.text)) {
      finalBgColor = isDarkMode ? const Color(0xFFFFB74D) : Colors.indigo;
    } else {
      finalBgColor = isDarkMode ? const Color(0xFF2C2C2C) : Colors.white;
    }
    Color finalTextColor;
    if (actions.contains(button.text)) {
      finalTextColor = Colors.white;
    } else {
      finalTextColor = isDarkMode ? Colors.white : Colors.black;
    }
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: CustomBtn(
          text: button.text,
          textColor: finalTextColor,
          bgColor: finalBgColor,
          onPressed: () => handleTap(button.text),
        ),
      ),
    );
  }

  // ========== CATEGORY CHANGE HANDLER ==========

  void onCategoryChanged(int index) {
    setState(() {
      selectedCategoryIndex = index;
      topUnitIndex = 0;
      bottomUnitIndex = 1;
      topValue = "0";
      bottomValue = "0";
    });
  }

  // ========== BUILD METHOD ==========

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gridBg = isDark ? const Color(0xFF1E1E1E) : const Color.fromARGB(255, 243, 232, 232);
    final activeColor = isDark ? const Color(0xFFFFB74D) : Colors.indigo;
    final category = conversionCategories[selectedCategoryIndex];
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Unit Conversion",
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 22, fontWeight: FontWeight.w400),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: conversionCategories.length,
                itemBuilder: (context, index) {
                  final cat = conversionCategories[index];
                  final isSelected = index == selectedCategoryIndex;
                  return GestureDetector(
                    onTap: () => onCategoryChanged(index),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? activeColor
                            : (isDark ? const Color(0xFF2C2C2C) : Colors.grey[200]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(cat.icon, size: 18, color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black54)),
                          const SizedBox(width: 6),
                          Text(
                            cat.name,
                            style: TextStyle(
                              color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
              color: isTopSelected
                  ? (isDark ? Colors.white10 : Colors.black.withOpacity(0.03))
                  : Colors.transparent,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: () => openUnitSelectionSheet(true),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.units[topUnitIndex].name,
                            style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : Colors.black54),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                category.units[topUnitIndex].symbol,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const Icon(Icons.arrow_drop_down, size: 24),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: InkWell(
                      onTap: () => setState(() => isTopSelected = true),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: Text(
                          topValue,
                          textAlign: TextAlign.end,
                          softWrap: false,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: isTopSelected
                                ? activeColor
                                : (isDark ? Colors.white : Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Divider(),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
              color: !isTopSelected
                  ? (isDark ? Colors.white10 : Colors.black.withOpacity(0.03))
                  : Colors.transparent,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: () => openUnitSelectionSheet(false),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.units[bottomUnitIndex].name,
                            style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : Colors.black54),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                category.units[bottomUnitIndex].symbol,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const Icon(Icons.arrow_drop_down, size: 24),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: InkWell(
                      onTap: () => setState(() => isTopSelected = false),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: Text(
                          bottomValue,
                          textAlign: TextAlign.end,
                          softWrap: false,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: !isTopSelected
                                ? activeColor
                                : (isDark ? Colors.white : Colors.black),
                          ),
                        ),
                      ),
                    ),
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
                              children: [buildButton(0), buildButton(1), buildButton(2)],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [buildButton(3), buildButton(4), buildButton(5)],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [buildButton(6), buildButton(7), buildButton(8)],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [buildButton(9), buildButton(10), buildButton(11)],
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
                          Expanded(child: buildButton(12)),
                          const SizedBox(height: 6),
                          Expanded(child: buildButton(13)),
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