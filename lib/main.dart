import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'customBtn.dart'; 
import 'theme.dart';
import 'package:expressions/expressions.dart';
import 'dart:math' as math;
import 'package:auto_size_text/auto_size_text.dart';
import 'db_helper.dart';
import 'currency_converter.dart';
import 'unit_conversion.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Apptheme.lightTheme,
      darkTheme: Apptheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const CalculatorScreen(), 
    );
  }
}

class calcButton{
  final String text;
  final Color? textColor;
  final Color? bgColor;
  calcButton({
    required this.text,
    this.textColor,
    this.bgColor,
  });
}

final List<calcButton> myButtons = [
  calcButton(text: "X^2", textColor: Colors.indigo),
  calcButton(text: "√", textColor: Colors.indigo),
  calcButton(text: "(", textColor: Colors.indigo),
  calcButton(text: ")", textColor: Colors.indigo),
  calcButton(text: "AC", textColor: Colors.indigo),
  calcButton(text: "÷", textColor: Colors.indigo),
  calcButton(text: "X", textColor: Colors.indigo),
  calcButton(text: "<-", textColor: Colors.indigo),
  calcButton(text: "7"),
  calcButton(text: "8"),
  calcButton(text: "9"),
  calcButton(text: "-", textColor: Colors.indigo),
  calcButton(text: "4"),
  calcButton(text: "5"),
  calcButton(text: "6"),
  calcButton(text: "+", textColor: Colors.indigo),
  calcButton(text: "1"),
  calcButton(text: "2"),
  calcButton(text: "3"),
  calcButton(
    text: "=", 
    bgColor: Colors.indigo, 
    textColor: Colors.white,   
  ),
  calcButton(text: "%", textColor: Colors.indigo), 
  calcButton(text: "0"),                                                   
  calcButton(text: "."),

  calcButton(text: "1/x", textColor: Colors.indigo),
  calcButton(text: "MC", textColor: Colors.indigo),
  calcButton(text: "M+", textColor: Colors.indigo),
  calcButton(text: "M-", textColor: Colors.indigo),
  calcButton(text: "MR", textColor: Colors.indigo),
  calcButton(text: "X^3", textColor: Colors.indigo),
  calcButton(text: "X^Y", textColor: Colors.indigo),
  calcButton(text: "!", textColor: Colors.indigo),
  calcButton(text: "Y√x", textColor: Colors.indigo),
  calcButton(text: "e", textColor: Colors.indigo),
  calcButton(text: "ln", textColor: Colors.indigo),
  calcButton(text: "log", textColor: Colors.indigo),
  calcButton(text: "sin", textColor: Colors.indigo),
  calcButton(text: "cos", textColor: Colors.indigo),
  calcButton(text: "tan", textColor: Colors.indigo),
  calcButton(text: "2nd", textColor: Colors.indigo),
  calcButton(text: "rad", textColor: Colors.indigo),
  calcButton(text: "π", textColor: Colors.indigo),
];

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String equation = "";
  String history = "";
  int cursorIndex = 0;
  bool isEvaluated = false;
  bool isDegree = true;
  bool is2nd = false;
  double memory = 0;
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> calculationHistory = [];
  
  bool _isLockedToPortrait = true;
  late TextEditingController _equationController;
  
  final List<String> _functionButtons = ["sin", "cos", "tan", "log", "ln", "sinh", "cosh", "tanh"];
  final List<String> _2ndFunctionButtons = ["asin", "acos", "atan", "10^", "e^", "asinh", "acosh", "atanh"];

  double _sinh(double x) => (math.exp(x) - math.exp(-x)) / 2;
  double _cosh(double x) => (math.exp(x) + math.exp(-x)) / 2;
  double _tanh(double x) => _sinh(x) / _cosh(x);

  @override
  void initState() {
    super.initState();
    _equationController = TextEditingController(text: equation);  
    _loadHistoryFromDatabase();
  }
  
  @override
  void dispose() {
    _equationController.dispose();
    super.dispose();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    
    if (!isLandscape && !_isLockedToPortrait) {
      _isLockedToPortrait = true;
    } else if (isLandscape && _isLockedToPortrait) {
      _isLockedToPortrait = false;
    }
  }
  
  Future<void> _loadHistoryFromDatabase() async {
    final data = await _dbHelper.getHistory();
    setState(() {
      calculationHistory = data;
    });
  }

  void _toggleOrientation() async {
    setState(() {
      _isLockedToPortrait = !_isLockedToPortrait;
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
    
    if (_isLockedToPortrait) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  String _formatResult(dynamic result) {
    if (result == null) return "";
    double value = result is num ? result.toDouble() : double.tryParse(result.toString()) ?? 0.0;
    if (value == 0) value = 0;
    
    double tolerance = 0.0000000001;
    if ((value - value.toInt()).abs() < tolerance) {
      return value.toInt().toString();
    }
    
    String formatted = value.toString();
    if (formatted.contains('.')) {
      formatted = formatted.replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
    }
    return formatted;
  }

  String _preprocessExpression(String expr) {
  String processed = expr;
    
    processed = processed.replaceAll('X', '*');
    processed = processed.replaceAll('÷', '/');
    processed = processed.replaceAll('π', '${math.pi}');
    processed = processed.replaceAll('e', '${math.e}');
    
    processed = _handleSmartPercentage(processed);
    
    processed = processed.replaceAll('10^', 'pow(10,');
    processed = processed.replaceAll('e^', 'pow(${math.e},');
    
    return processed;
  }
  
  String _handleSmartPercentage(String expr) {
    String processed = expr;
    
    processed = processed.replaceAllMapped(
      RegExp(r'(\d+\.?\d*)\+(\d+\.?\d*)%'),
      (Match m) {
        double base = double.parse(m.group(1)!);
        double percent = double.parse(m.group(2)!);
        double result = base * (percent / 100);
        return '${m.group(1)}+${result.toString().replaceAll(RegExp(r'\.0$'), '')}';
      }
    );
    
    processed = processed.replaceAllMapped(
      RegExp(r'(\d+\.?\d*)\-(\d+\.?\d*)%'),
      (Match m) {
        double base = double.parse(m.group(1)!);
        double percent = double.parse(m.group(2)!);
        double result = base * (percent / 100);
        return '${m.group(1)}-${result.toString().replaceAll(RegExp(r'\.0$'), '')}';
      }
    );
    
    processed = processed.replaceAll('%', '/100');
    
    return processed;
  }
  
double _customEvaluate(String expr) {
    // 👇 YEH VALI CONDITION SAB SE UPAR ADD KAREIN
    // Agar input expression ke andar pehle se "Error" likha hua hai
    if (expr.contains("Error")) {
      throw Exception('Invalid'); // Yeh direct catch block mein bhej dega jahan "Error" set hota hai
    }

    String processed = _preprocessExpression(expr);
    
    processed = processed.replaceAll('√(', 'sqrt(');
    processed = processed.replaceAllMapped(
      RegExp(r'√(-[0-9]+\.?[0-9]*)'),
      (Match m) => 'sqrt(${m[1]})'
    );
    processed = processed.replaceAllMapped(
      RegExp(r'√([0-9]+)'),
      (Match m) => 'sqrt(${m[1]})'
    );
    processed = processed.replaceAllMapped(
      RegExp(r'√([0-9])'),
      (Match m) => 'sqrt(${m[1]})'
    );
    
    while (true) {
      RegExp funcRegex = RegExp(r'(sin|cos|tan|log|ln|sinh|cosh|tanh|sqrt|asin|acos|atan|asinh|acosh|atanh)\(([^()]+)\)');
      Match? match = funcRegex.firstMatch(processed);
      
      if (match == null) break;
      
      String funcName = match.group(1)!;
      String innerExpr = match.group(2)!;
      
      double innerValue = _evaluateSimpleExpression(innerExpr);
      
      double funcResult;
      try {
        funcResult = _applyFunction(funcName, innerValue);
      } catch (e) {
        throw Exception('Invalid');
      }
      
      processed = processed.replaceRange(match.start, match.end, funcResult.toString());
    }
    
    return _evaluateSimpleExpression(processed);
  }
  
  double _applyFunction(String funcName, double value) {
    switch (funcName) {
      case 'sin': return math.sin(_toRadians(value));
      case 'cos': return math.cos(_toRadians(value));
      case 'tan':
        double rad = _toRadians(value);
        if ((rad % (math.pi/2)).abs() < 0.0001 && (rad % math.pi).abs() > 0.0001) {
          throw Exception('Undefined');
        }
        return math.tan(rad);
      
      case 'asin': 
        if (value < -1 || value > 1) throw Exception('Invalid');
        return isDegree ? math.asin(value) * (180 / math.pi) : math.asin(value);
      case 'acos':
        if (value < -1 || value > 1) throw Exception('Invalid');
        return isDegree ? math.acos(value) * (180 / math.pi) : math.acos(value);
      case 'atan':
        return isDegree ? math.atan(value) * (180 / math.pi) : math.atan(value);
      
      case 'log': 
        if (value <= 0) throw Exception('Invalid');
        return math.log(value) / math.ln10;
      case 'ln': 
        if (value <= 0) throw Exception('Invalid');
        return math.log(value);
      
      case 'sinh': return _sinh(value);
      case 'cosh': return _cosh(value);
      case 'tanh': return _tanh(value);
      
      case 'asinh': return math.log(value + math.sqrt(value * value + 1));
      case 'acosh':
        if (value < 1) throw Exception('Invalid');
        return math.log(value + math.sqrt(value * value - 1));
      case 'atanh':
        if (value <= -1 || value >= 1) throw Exception('Invalid');
        return 0.5 * math.log((1 + value) / (1 - value));
      
      case 'sqrt':
        if (value < 0) throw Exception('Invalid');
        double result = math.sqrt(value);
        if (result.isNaN) throw Exception('Invalid');
        return result;
        
      default: return value;
    }
  }
  
  double _evaluateSimpleExpression(String expr) {
    if (expr.contains("Error")) {
      throw Exception('Invalid');
    }

    String processed = expr;
    
    if (processed.contains('sqrt(-')) {
      throw Exception('Invalid');
    }
    
    while (processed.contains('^')) {
      int caretIndex = processed.lastIndexOf('^');
      
      String left = processed.substring(0, caretIndex);
      String right = processed.substring(caretIndex + 1);
      
      String base = _extractLastOperand(left);
      String exponent = _extractFirstOperand(right);
      
      double baseVal = _parseOrEvaluate(base);
      double expVal = _parseOrEvaluate(exponent);
      double result = math.pow(baseVal, expVal).toDouble();
      
      processed = left.substring(0, left.length - base.length) + 
                  result.toString() + 
                  right.substring(exponent.length);
    }
    
    processed = insertMissingMultiplication(processed);
    final expression = Expression.parse(processed);
    const evaluator = ExpressionEvaluator();
    var res = evaluator.eval(expression, {});
    double result = res is num ? res.toDouble() : 0.0;
    
    if (result.isNaN || result.isInfinite) {
      throw Exception('Invalid');
    }
    
    return result;
  }
  
  String _extractLastOperand(String expr) {
    int i = expr.length - 1;
    int parenCount = 0;
    
    while (i >= 0) {
      String char = expr[i];
      if (char == ')') parenCount++;
      else if (char == '(') parenCount--;
      
      if (parenCount == 0 && (char == '+' || char == '-' || char == '*' || char == '/' || char == '^')) {
        if (i > 0 && char == '-' && (expr[i-1] == 'e' || expr[i-1] == 'E')) {
          i--;
          continue;
        }
        return expr.substring(i + 1);
      }
      i--;
    }
    return expr;
  }
  
  String _extractFirstOperand(String expr) {
    int i = 0;
    int parenCount = 0;
    
    while (i < expr.length) {
      String char = expr[i];
      if (char == '(') parenCount++;
      else if (char == ')') parenCount--;
      
      if (parenCount == 0 && i > 0 && (char == '+' || char == '-' || char == '*' || char == '/' || char == '^')) {
        return expr.substring(0, i);
      }
      i++;
    }
    return expr;
  }
  
  double _parseOrEvaluate(String expr) {
    expr = expr.trim();
    double? direct = double.tryParse(expr);
    if (direct != null) return direct;
    return _evaluateSimpleExpression(expr);
  }

  String calculateLiveResult(String expr) {
    if (expr.isEmpty || expr == "0") return "";
    if (expr.contains("Error")) return "Error";
    String lastChar = expr.substring(expr.length - 1);
    if (["+", "-", "X", "÷", "^", "."].contains(lastChar)) {
      return "Error";
    }
    if (lastChar == "(") {
      return "";
    }
    
    String evalExpr = _handleSmartPercentage(expr);
    
    int openParens = evalExpr.split('(').length - 1;
    int closeParens = evalExpr.split(')').length - 1;
    if (openParens > closeParens) {
      evalExpr += ')' * (openParens - closeParens);
    }
    
    if (RegExp(r'(sin|cos|tan|log|ln|sinh|cosh|tanh|sqrt|asin|acos|atan|asinh|acosh|atanh)$').hasMatch(expr)) {
      return "";
    }
    
    try {
      double result = _customEvaluate(evalExpr);
      return _formatResult(result);
    } catch (e) {
      return "Error";
    }
  }

  String insertMissingMultiplication(String expr) {
    String formatted = expr;

    // digit followed by '(' -> digit*(
    formatted = formatted.replaceAllMapped(
      RegExp(r'(\d)\('), 
      (Match m) => '${m[1]}*('
    );

    // ')' followed by digit -> )*digit
    formatted = formatted.replaceAllMapped(
      RegExp(r'\)(\d)'), 
      (Match m) => ')*${m[1]}'
    );

    // ')' followed by '(' -> )*(
    formatted = formatted.replaceAllMapped(
      RegExp(r'\)\('), 
      (Match m) => ')*('
    );

    return formatted;
  }

  double _evaluateExpression(String expr) {
    return _customEvaluate(expr);
  }

  double _toRadians(double degrees) {
    return isDegree ? degrees * (math.pi / 180) : degrees;
  }

  double _factorial(double n) {
    if (n < 0) return double.nan;
    if (n == 0 || n == 1) return 1;
    double result = 1;
    for (int i = 2; i <= n.toInt(); i++) {
      result *= i;
    }
    return result;
  }

  void numClick(String btntext) {
    setState(() {
      if (btntext == "2nd") {
        is2nd = !is2nd;
        setState(() {});  
        return;
      }

      if (btntext == "MC") { memory = 0; return; }
      if (btntext == "M+") {
        if (equation.isNotEmpty) {
          try { 
            memory += _evaluateExpression(equation); 
            setState(() {}); 
          } catch (e) {
            history = "Error";
            isEvaluated = true;  
          }
        }
        return;
      }
      if (btntext == "M-") {
        if (equation.isNotEmpty) {
          try { 
            memory -= _evaluateExpression(equation); 
            setState(() {}); 
          } catch (e) {
            history = "Error";
            isEvaluated = true;  
          }
        }
        return;
      }
      if (btntext == "MR") {
        if (isEvaluated) {
          equation = "";
          cursorIndex = 0;
          isEvaluated = false;
        }
        String memStr = _formatResult(memory);
        String leftText = equation.substring(0, cursorIndex);
        String rightText = equation.substring(cursorIndex);
        equation = leftText + memStr + rightText;
        cursorIndex += memStr.length;
        history = calculateLiveResult(equation);
        return;
      }

      if (btntext == "rad") { isDegree = !isDegree; return; }

      if (btntext == "AC") {
        equation = "";
        history = "";
        cursorIndex = 0;
        isEvaluated = false;
        return;
      } 

      if (btntext == "<-") {
        if (isEvaluated) {
          equation = "";
          history = "";
          cursorIndex = 0;
          isEvaluated = false;
        } else if (equation.isNotEmpty && cursorIndex > 0) {
          String beforeCursor = equation.substring(0, cursorIndex);
          
          List<String> allFunctions = [..._functionButtons, ..._2ndFunctionButtons];
          
          for (String func in allFunctions) {
            if (beforeCursor.endsWith(func + '(')) {
              equation = equation.substring(0, cursorIndex - func.length - 1) + 
                         equation.substring(cursorIndex);
              cursorIndex -= (func.length + 1);
              history = calculateLiveResult(equation);
              return;
            }
          }
          
          if (beforeCursor.endsWith('√(')) {
            equation = equation.substring(0, cursorIndex - 2) + 
                       equation.substring(cursorIndex);
            cursorIndex -= 2;
            history = calculateLiveResult(equation);
            return;
          } else if (beforeCursor.endsWith('√')) {
            equation = equation.substring(0, cursorIndex - 1) + 
                       equation.substring(cursorIndex);
            cursorIndex -= 1;
            history = calculateLiveResult(equation);
            return;
          }
          
          equation = equation.substring(0, cursorIndex - 1) + 
                     equation.substring(cursorIndex);
          cursorIndex--;
          history = calculateLiveResult(equation);
        }
        return;
      } 

      if (btntext == "=") {
        if (isEvaluated || equation.isEmpty) return;
        if (equation.contains("Error")) {
          history = "Error";
          isEvaluated = true;
          return;
        }
        int openParens = equation.split('(').length - 1;
        int closeParens = equation.split(')').length - 1;
        if (openParens > closeParens) {
          equation += ')' * (openParens - closeParens);
        }
        
        String lastChar = equation.substring(equation.length - 1);
        if (["+", "-", "X", "÷", "^", ".", "("].contains(lastChar)) {
          history = "Error";
          isEvaluated = true;
          return;
        }
        try {
          double result = _evaluateExpression(equation);
          history = _formatResult(result);
          isEvaluated = true;
          _dbHelper.insertHistory(equation, history).then((_) {
            _loadHistoryFromDatabase();
          });
        } catch (e) {
          history = "Error";
          isEvaluated = true;
        }
        return;
      } 

      if (_functionButtons.contains(btntext)) {
        if (isEvaluated) {
          equation = "";
          cursorIndex = 0;
          isEvaluated = false;
        }
        
        int funcIndex = _functionButtons.indexOf(btntext);
        String actualFunc = is2nd ? _2ndFunctionButtons[funcIndex] : btntext;
        
        String funcText;
        if (actualFunc == "10^" || actualFunc == "e^") {
          funcText = actualFunc;
        } else {
          funcText = actualFunc + "(";
        }
        
        String leftText = equation.substring(0, cursorIndex);
        String rightText = equation.substring(cursorIndex);
        equation = leftText + funcText + rightText;
        cursorIndex += funcText.length;
        history = calculateLiveResult(equation);
        
        is2nd = false;
        setState(() {});
        
        return;
      }

      if (btntext == "X^2" || btntext == "X^3") {
        if (isEvaluated) {
          equation = history + (btntext == "X^2" ? "^2" : "^3");
          isEvaluated = false;
        } else if (equation.isEmpty) {
          equation = btntext == "X^2" ? "^2" : "^3";
        } else {
          String leftText = equation.substring(0, cursorIndex);
          String rightText = equation.substring(cursorIndex);
          equation = leftText + (btntext == "X^2" ? "^2" : "^3") + rightText;
        }
        cursorIndex = equation.length;
        history = calculateLiveResult(equation);
        return;
      }

      if (btntext == "X^Y") {
        if (isEvaluated) {
          equation = history + "^";
          isEvaluated = false;
        } else if (equation.isEmpty) {
          equation = "^";
        } else {
          String leftText = equation.substring(0, cursorIndex);
          String rightText = equation.substring(cursorIndex);
          equation = leftText + "^" + rightText;
        }
        cursorIndex = equation.length;
        history = calculateLiveResult(equation);
        return;
      }

      if (btntext == "√") {
        if (isEvaluated) {
          equation = "√" + history;
          isEvaluated = false;
        } else {
          String leftText = equation.substring(0, cursorIndex);
          String rightText = equation.substring(cursorIndex);
          equation = leftText + "√" + rightText;
        }
        cursorIndex = equation.length;
        history = calculateLiveResult(equation);
        return;
      }

      if (btntext == "Y√x") {
        if (isEvaluated) {
          equation = history + "^(1/";
          isEvaluated = false;
        } else {
          String leftText = equation.substring(0, cursorIndex);
          String rightText = equation.substring(cursorIndex);
          equation = leftText + "^(1/" + rightText;
        }
        cursorIndex = equation.length;
        history = calculateLiveResult(equation);
        return;
      }

      if (["!", "1/x"].contains(btntext)) {
        try {
          double value = equation.isEmpty ? 0 : _evaluateExpression(equation);
          double result = 0;
          String customEquation = "";
          
          switch (btntext) {
            case "!":
              if (value != value.toInt()) {
                history = "Error";
                isEvaluated = true;
                return;
              }
              result = _factorial(value);
              customEquation = equation.isEmpty ? "0!" : "($equation)!";
              break;
            case "1/x":
              if (value == 0) {
                history = "Error";
                isEvaluated = true;
                return;
              }
              result = 1 / value;
              customEquation = equation.isEmpty ? "1/0" : "1/($equation)";
              break;
          }
          
          history = _formatResult(result);
          isEvaluated = true;
          _dbHelper.insertHistory(customEquation, history).then((_) {
            _loadHistoryFromDatabase();
          });
        } catch (e) {
          history = "Error";
          isEvaluated = true;
        }
        return;
      }

      if (btntext == ")") {
        int openParens = equation.substring(0, cursorIndex).split('(').length - 1;
        int closeParens = equation.substring(0, cursorIndex).split(')').length - 1;
        if (openParens > closeParens) {
          String leftText = equation.substring(0, cursorIndex);
          String rightText = equation.substring(cursorIndex);
          equation = leftText + ")" + rightText;
          cursorIndex++;
          history = calculateLiveResult(equation);
        }
        return;
      }

      if (isEvaluated) {
        if (["+", "-", "X", "÷", "%", "(", "^"].contains(btntext)) {
          equation = history; 
        } else {
          equation = "";
        }
        cursorIndex = equation.length;
        isEvaluated = false;
        history = "";
      }

      String leftText = equation.substring(0, cursorIndex);
      String rightText = equation.substring(cursorIndex);
      equation = leftText + btntext + rightText;
      cursorIndex += btntext.length;

      history = calculateLiveResult(equation);
    });
  }

  Widget buildButton(int index) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    
    String displayText = myButtons[index].text;
    String clickText = myButtons[index].text;
    
    if (is2nd) {
      switch (displayText) {
        case 'sin': displayText = 'sin⁻¹'; break;
        case 'cos': displayText = 'cos⁻¹'; break;
        case 'tan': displayText = 'tan⁻¹'; break;
        case 'log': displayText = '10ˣ'; break;
        case 'ln':  displayText = 'eˣ'; break;
        case 'sinh': displayText = 'sinh⁻¹'; break;
        case 'cosh': displayText = 'cosh⁻¹'; break;
        case 'tanh': displayText = 'tanh⁻¹'; break;
      }
    }
    
    Color finalBgColor = myButtons[index].bgColor ?? theme.cardColor;
    if (myButtons[index].text == "=" && isDarkMode) {
      finalBgColor = const Color(0xFFFFB74D); 
    }
    
    List<String> operators = ["+", "-", "X", "÷", "%", "<-", "AC", "X^2", "X^3", "X^Y", 
                               "√", "Y√x", "(", ")", 
                               "sin", "cos", "tan", "log", "ln", "π", "e", "!", "^", "1/x",
                               "MC", "M+", "M-", "MR", "2nd", "rad",
                               "sinh", "cosh", "tanh",
                               "sin⁻¹", "cos⁻¹", "tan⁻¹", "10ˣ", "eˣ", 
                               "sinh⁻¹", "cosh⁻¹", "tanh⁻¹"];
    
    Color finalTextColor = myButtons[index].textColor ?? 
        (isDarkMode ? Colors.white : Colors.black);
    
    if (isDarkMode && operators.contains(displayText)) {
      if (myButtons[index].text != "=") {
        finalTextColor = const Color(0xFFFFD700); 
      }
    }
    
    final isMRButton = clickText == "MR";
    
    Widget buttonWidget = CustomBtn(
      text: displayText,
      textColor: finalTextColor,
      bgColor: finalBgColor,
      onPressed: () {
        numClick(clickText);
      }
    );
    
    if (isMRButton) {
      buttonWidget = GestureDetector(
        onLongPress: () {
          if (memory != 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Memory: ${_formatResult(memory)}",
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                backgroundColor: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        child: buttonWidget,
      );
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: buttonWidget,
      ),
    );
  }

  Widget buildPortraitButtons() {
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [buildButton(0), buildButton(1), buildButton(2), buildButton(3)],
          ),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [buildButton(4), buildButton(5), buildButton(6), buildButton(7)],
          ),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [buildButton(8), buildButton(9), buildButton(10), buildButton(11)],
          ),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [buildButton(12), buildButton(13), buildButton(14), buildButton(15)],
          ),
        ),
        Expanded(
          flex: 2,
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
                        children: [buildButton(16), buildButton(17), buildButton(18)],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [buildButton(20), buildButton(21), buildButton(22)],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: buildButton(19),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildLandscapeButtons() {
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildButton(2), buildButton(3), buildButton(23), buildButton(24),
              buildButton(25), buildButton(26), buildButton(27),
            ],
          ),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildButton(0), buildButton(28), buildButton(29), buildButton(4),
              buildButton(5), buildButton(6), buildButton(7),
            ],
          ),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildButton(30), buildButton(1), buildButton(31), buildButton(8),
              buildButton(9), buildButton(10), buildButton(11),
            ],
          ),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildButton(32), buildButton(33), buildButton(34), buildButton(12),
              buildButton(13), buildButton(14), buildButton(15),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          buildButton(35), buildButton(36), buildButton(37),
                          buildButton(16), buildButton(17), buildButton(18),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          buildButton(38), buildButton(39), buildButton(40),
                          buildButton(20), buildButton(21), buildButton(22),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: buildButton(19),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRotationIcon(bool isDarkMode) {
    return IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return RotationTransition(
            turns: animation,
            child: child,
          );
        },
        child: Icon(
          _isLockedToPortrait 
            ? Icons.screen_rotation_rounded
            : Icons.screen_rotation_rounded,
          key: ValueKey<bool>(_isLockedToPortrait),
          color: isDarkMode ? Colors.white : Colors.black,
          size: 26,
        ),
      ),
      onPressed: _toggleOrientation,
      tooltip: _isLockedToPortrait ? 'Switch to Landscape' : 'Switch to Portrait',
      splashRadius: 20,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    
    _equationController.text = equation;
    _equationController.selection = TextSelection.fromPosition(
     TextPosition(offset: cursorIndex.clamp(0, equation.length))
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _buildRotationIcon(isDarkMode),
        actions: [
          if (memory != 0)
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: memory > 0 
                    ? (isDarkMode ? Colors.orange.withOpacity(0.2) : Colors.indigo.withOpacity(0.1))
                    : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  memory > 0 ? "M" : "M-",
                  style: TextStyle(
                    color: memory > 0 
                      ? (isDarkMode ? Colors.orange : Colors.indigo)
                      : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (is2nd)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: Text(
                  "2nd",
                  style: TextStyle(
                    color: isDarkMode ? Colors.orange : Colors.indigo,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (isLandscape)
            if (isDegree)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    "DEG",
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    "RAD",
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          IconButton(
            icon: Icon(
              Icons.scale_rounded,
              color: isDarkMode ? Colors.white : Colors.black,
              size: 26.0,
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const UnitConversionScreen()));
            },
          ),
          IconButton(
            icon: Icon(
              Icons.currency_exchange_rounded,
              color: isDarkMode ? Colors.white : Colors.black,
              size: 26.0,
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CurrencyConverterScreen()));
            },
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert_rounded,
              color: isDarkMode ? Colors.white : Colors.black,
              size: 32.0,
            ),
            onPressed: () {
              showGeneralDialog(
                context: context,
                barrierDismissible: true,
                barrierLabel: "HistoryMenu",
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
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
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
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context); 
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HistoryPage(
                                      history: calculationHistory,
                                      onClearHistory: () async {
                                        await _dbHelper.clearHistory();
                                        _loadHistoryFromDatabase();
                                      },
                                    ),
                                  ),
                                );
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.history_rounded, size: 22),
                                    SizedBox(width: 12),
                                    Text('History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Expanded(
                flex: isLandscape ? 1 : 2, 
                child: Container(
                  padding: const EdgeInsets.only(right: 16.0, bottom: 4.0, left: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: TextField(
                            controller: _equationController,
                            readOnly: true,
                            showCursor: !isEvaluated,
                            autofocus: true,
                            textAlign: TextAlign.end,
                            cursorColor: isDarkMode ? Colors.white : Colors.black,
                            cursorWidth: 4.0,
                            cursorRadius: const Radius.circular(2.0),
                            style: TextStyle(
                              fontSize: isLandscape ? (isEvaluated ? 22 : 30) : (isEvaluated ? 26 : 45), 
                              fontWeight: FontWeight.w400,
                              height: 1.0,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      if (history.isNotEmpty)
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300), 
                          curve: Curves.easeOutBack,
                          style: TextStyle(
                            fontSize: isLandscape ? (isEvaluated ? 30 : 22) : (isEvaluated ? 50 : 26), 
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          child: AutoSizeText(
                            history,
                            maxLines: 1,
                            minFontSize: 14,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              Expanded(
                flex: isLandscape ? 3 : 5, 
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF1E1E1E) : const Color.fromARGB(255, 243, 232, 232),
                    borderRadius: BorderRadius.circular(20), 
                  ),
                  padding: const EdgeInsets.all(6.0),
                  child: isLandscape 
                    ? buildLandscapeButtons()
                    : buildPortraitButtons(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  final List<Map<String, dynamic>> history;
  final VoidCallback onClearHistory;

  const HistoryPage({
    super.key,
    required this.history,
    required this.onClearHistory,
  });

  String _getFormattedGroupDate(String? dateTimeStr) {
    if (dateTimeStr == null) return "";
    try {
      DateTime parsedDate = DateTime.parse(dateTimeStr);
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      DateTime yesterday = today.subtract(const Duration(days: 1));
      DateTime compareDate = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);

      if (compareDate == today) {
        return "Today";
      } else if (compareDate == yesterday) {
        return "Yesterday";
      } else {
        List<String> months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
        return "${months[parsedDate.month - 1]} ${parsedDate.day}";
      }
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    String lastDisplayedDate = "";

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('History', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 22)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
                  title: Text('Clear History?', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                  content: Text('Do you want to delete all history?', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                      ),
                      child: const Text(
                        'Cancel', 
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        onClearHistory();
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text('Clear', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: history.isEmpty
          ? const Center(child: Text('No history yet', style: TextStyle(color: Colors.grey, fontSize: 18)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                String currentDate = _getFormattedGroupDate(item['date_time']);
                bool showHeader = false;
                if (currentDate.isNotEmpty && currentDate != lastDisplayedDate) {
                  showHeader = true;
                  lastDisplayedDate = currentDate; 
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showHeader) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0, bottom: 10.0, left: 4.0),
                        child: Text(
                          currentDate,
                          style: TextStyle(
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xff1e1e1e) : Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['expression'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 18)),
                          const SizedBox(height: 8),
                          Text(
                            '=${item['result']}',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}