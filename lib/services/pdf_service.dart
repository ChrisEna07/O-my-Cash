import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../providers/finance_provider.dart';

class PdfService {
  static Future<void> generateAndPrintSummary(FinanceProvider provider) async {
    final pdf = pw.Document();
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0, 
                child: pw.Text('Resumen Financiero - O-myCash', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo))
              ),
              pw.SizedBox(height: 20),
              pw.Text('Hola, ${provider.userName.isEmpty ? 'Usuario' : provider.userName}', style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 30),
              
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.indigo50,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Balance General', style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
                    pw.SizedBox(height: 5),
                    pw.Text(currencyFormat.format(provider.balance), style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
                    pw.SizedBox(height: 10),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Ingresos Totales: ${currencyFormat.format(provider.totalIncome)}', style: pw.TextStyle(color: PdfColors.green700, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Gastos Totales: ${currencyFormat.format(provider.totalExpenses)}', style: pw.TextStyle(color: PdfColors.red700, fontWeight: pw.FontWeight.bold)),
                      ]
                    )
                  ]
                )
              ),
              pw.SizedBox(height: 30),

              pw.Header(level: 1, child: pw.Text('Distribución de Regla 50/30/20', style: pw.TextStyle(color: PdfColors.indigo))),
              pw.SizedBox(height: 10),
              pw.Text('Necesidades (50%): ${currencyFormat.format(provider.needsSpent)} / Límite: ${currencyFormat.format(provider.totalIncome * 0.5)}'),
              pw.SizedBox(height: 5),
              pw.Text('Deseos (30%): ${currencyFormat.format(provider.wantsSpent)} / Límite: ${currencyFormat.format(provider.totalIncome * 0.3)}'),
              pw.SizedBox(height: 5),
              pw.Text('Ahorro e Inversión (20%): ${currencyFormat.format(provider.savingsSpent)} / Límite: ${currencyFormat.format(provider.totalIncome * 0.2)}'),
              pw.SizedBox(height: 30),

              pw.Header(level: 1, child: pw.Text('Metas de Ahorro Activas', style: pw.TextStyle(color: PdfColors.indigo))),
              pw.SizedBox(height: 10),
              if (provider.goals.isEmpty) pw.Text('No hay metas de ahorro registradas.', style: const pw.TextStyle(color: PdfColors.grey)),
              ...provider.goals.map((g) {
                final progress = g.targetAmount > 0 ? (g.currentAmount / g.targetAmount * 100).toStringAsFixed(1) : '0';
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 10),
                  child: pw.Text('• ${g.goalName}: ${currencyFormat.format(g.currentAmount)} de ${currencyFormat.format(g.targetAmount)} ($progress% completado)'),
                );
              }).toList(),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Resumen_Financiero_OMyCash.pdf',
    );
  }
}
