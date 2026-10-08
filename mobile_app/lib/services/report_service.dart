import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/goat.dart';

class ReportService {
  Future<pw.Document> generatePdfReport(List<Goat> goats) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Goat Management Report',
                style: pw.TextStyle(
                  fontSize: 26,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Text('Total goats: ${goats.length}'),
              pw.SizedBox(height: 12),
              ...goats.map((goat) {
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 12),
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Goat Number: ${goat.goatNumber}'),
                      pw.Text('Owner: ${goat.owner}'),
                      pw.Text('Date of Birth: ${goat.dateOfBirth}'),
                      pw.Text('Vaccination Date: ${goat.vaccinationDate}'),
                      pw.Text('Herd Size: ${goat.herdSize}'),
                      pw.Text('Notes: ${goat.notes.isEmpty ? 'N/A' : goat.notes}'),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  Future<void> printReport(List<Goat> goats) async {
    final pdf = await generatePdfReport(goats);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<void> downloadPdf(List<Goat> goats) async {
    final pdf = await generatePdfReport(goats);
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'goat_report.pdf');
  }
}
