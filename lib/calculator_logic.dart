import 'package:expressions/expressions.dart';
import 'dart:math' as math;

class CalculatorLogic {
  bool isDegree = true;

  double _sinh(double x) => (math.exp(x) - math.exp(-x)) / 2;
  double _cosh(double x) => (math.exp(x) + math.exp(-x)) / 2;
  double _tanh(double x) => _sinh(x) / _cosh(x);

  String formatResult(dynamic result) {
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

  String preprocessExpression(String expr) {
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

  double customEvaluate(String expr) {
    if (expr.contains("Error")) {
      throw Exception('Invalid');
    }

    String processed = preprocessExpression(expr);
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
      double funcResult = _applyFunction(funcName, innerValue);
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
        if ((rad % (math.pi / 2)).abs() < 0.0001 && (rad % math.pi).abs() > 0.0001) {
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
        if (i > 0 && char == '-' && (expr[i - 1] == 'e' || expr[i - 1] == 'E')) {
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
      double result = customEvaluate(evalExpr);
      return formatResult(result);
    } catch (e) {
      return "Error";
    }
  }

  String insertMissingMultiplication(String expr) {
    String formatted = expr;
    formatted = formatted.replaceAllMapped(RegExp(r'(\d)\('), (Match m) => '${m[1]}*(');
    formatted = formatted.replaceAllMapped(RegExp(r'\)(\d)'), (Match m) => ')*${m[1]}');
    formatted = formatted.replaceAllMapped(RegExp(r'\)\('), (Match m) => ')*(');
    return formatted;
  }

  double evaluateExpression(String expr) {
    return customEvaluate(expr);
  }

  double _toRadians(double degrees) {
    return isDegree ? degrees * (math.pi / 180) : degrees;
  }

  double factorial(double n) {
    if (n < 0) return double.nan;
    if (n == 0 || n == 1) return 1;
    double result = 1;
    for (int i = 2; i <= n.toInt(); i++) {
      result *= i;
    }
    return result;
  }
}