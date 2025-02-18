import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class cetakpdf extends StatefulWidget {
  final List<Map<String, dynamic>> cetak;
  final String PenjualanID;
  const cetakpdf({Key? key, required this.cetak, required this.PenjualanID}) : super(key: key);

  @override
  _cetakpdfState createState() => _cetakpdfState();
}

class _cetakpdfState extends State<cetakpdf> {
  @override
  Widget build(BuildContext context) {
    // Kembalikan widget kosong karena kita tidak perlu menampilkan UI di sini
    return Container();
  }

  @override
  void initState() {
    super.initState();
    // Panggil fungsi untuk mencetak PDF saat halaman dimuat
    generateAndPrintPDF(widget.PenjualanID);
  }

  Future<void> generateAndPrintPDF(String PenjualanID) async {
    final pdf = pw.Document();
    
    // Ambil data penjualan dari Supabase
    var responseSales = await Supabase.instance.client
    .from('penjualan')
    .select('*, pelanggan!penjualan_PelangganID_fkey1(*)')  // Menggunakan relasi yang kedua
    .eq('PenjualanID', PenjualanID)
    .single();

    var responseSalesDetail = await Supabase.instance.client
        .from('detailpenjualan')
        .select('*, produk(*)')
        .eq('PenjualanID', int.parse(PenjualanID));

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text("Cookielicious", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 5),
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text("Step into the sweet world of Cookielicious!", style: pw.TextStyle(fontSize: 18, fontStyle: pw.FontStyle.italic)),
              ),
              pw.SizedBox(height: 10),
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text("JL.Strawberry Shortcake no.7, Desa Raspberry Torte, Kecamatan Lemon Meringue", style: pw.TextStyle(fontSize: 15)),
              ),
              pw.SizedBox(height: 30),
              pw.Text("Pelanggan: ${responseSales['pelanggan']['NamaPelanggan']}", style: pw.TextStyle(fontSize: 18)),
              pw.Text("Tanggal: ${responseSales['TanggalPenjualan']}", style: pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ["Produk", "Jumlah", "Subtotal"],
                data: responseSalesDetail.map((detail) => [
                  detail['produk']['NamaProduk'],
                  detail['JumlahProduk'].toString(),
                  detail['Subtotal'].toString()
                ]).toList(),
              ),
              pw.SizedBox(height: 10),
              pw.Text("Total Harga: ${responseSales['TotalHarga']}", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
