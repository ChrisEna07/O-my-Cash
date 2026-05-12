import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<Map<String, dynamic>?> scanReceipt(String imagePath) async {
    final InputImage inputImage = InputImage.fromFilePath(imagePath);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

    double? totalAmount;
    String? suggestedCategory;

    // Regex mejorado para Pesos Colombianos (COP)
    // Captura números con puntos o comas como separadores de miles/decimales
    final RegExp amountRegExp = RegExp(r'(\d{1,3}([\.,]\d{3})*|(\d+))');
    final List<String> lines = recognizedText.text.split('\n');

    for (String line in lines) {
      String cleanLine = line.replaceAll('$', '').replaceAll(' ', '').trim();
      final String lowerLine = line.toLowerCase();
      
      // Buscamos palabras clave de "Total" o "Pagar"
      if (lowerLine.contains('total') || lowerLine.contains('pago') || lowerLine.contains('valor') || lowerLine.contains('importe')) {
        final Iterable<RegExpMatch> matches = amountRegExp.allMatches(cleanLine);
        if (matches.isNotEmpty) {
          // Tomamos el último número de la línea que suele ser el valor
          String match = matches.last.group(0)!;
          
          // Lógica para COP: Si el "decimal" tiene 3 dígitos, es un punto de mil
          // Ejemplo: 334.409 -> 334409
          totalAmount = _parseAmount(match);
        }
      }

      // Sugerencia de categoría básica
      if (suggestedCategory == null) {
        if (lowerLine.contains('restaurante') || lowerLine.contains('comida') || lowerLine.contains('cafe')) {
          suggestedCategory = 'Alimentación';
        } else if (lowerLine.contains('transporte') || lowerLine.contains('uber') || lowerLine.contains('gasol')) {
          suggestedCategory = 'Transporte';
        } else if (lowerLine.contains('netflix') || lowerLine.contains('cine') || lowerLine.contains('spotify')) {
          suggestedCategory = 'Ocio';
        }
      }
    }

    // Si no encontramos con "total", buscamos el número más grande al final del ticket
    if (totalAmount == null) {
      final Iterable<RegExpMatch> allMatches = amountRegExp.allMatches(recognizedText.text.replaceAll('$', '').replaceAll(' ', ''));
      if (allMatches.isNotEmpty) {
        List<double> values = allMatches
            .map((m) => _parseAmount(m.group(0)!))
            .where((v) => v > 0)
            .toList();
        if (values.isNotEmpty) {
          values.sort();
          totalAmount = values.last; // El número más grande suele ser el total
        }
      }
    }

    if (totalAmount != null) {
      return {
        'amount': totalAmount,
        'category': suggestedCategory ?? 'Otros',
      };
    }

    return null;
  }

  double _parseAmount(String match) {
    // Lógica para COP: Si el "decimal" tiene 3 dígitos, es un punto de mil
    // Ejemplo: 334.409 -> 334409
    try {
      if (match.contains('.') || match.contains(',')) {
        List<String> parts = match.split(RegExp(r'[\.,]'));
        if (parts.last.length == 3) {
          // Es un separador de miles
          return double.tryParse(match.replaceAll('.', '').replaceAll(',', '')) ?? 0;
        } else {
          // Es un decimal (ej. 1500.50)
          return double.tryParse(match.replaceAll(',', '.')) ?? 0;
        }
      }
      return double.tryParse(match) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}
