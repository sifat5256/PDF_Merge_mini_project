import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';


class PdfMergePageAPI extends StatefulWidget {
  @override
  _PdfMergePageAPIState createState() => _PdfMergePageAPIState();
}

class _PdfMergePageAPIState extends State<PdfMergePageAPI> {
  bool isLoading = false;
  String resultMessage = '';

  Future<void> uploadAndMergePDF() async {
    setState(() {
      isLoading = true;
      resultMessage = '';
    });

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      var uri = Uri.parse("https://nomad-ciel.onrender.com/merge-pdf/"); // Replace with your own IP if needed
      var request = http.MultipartRequest('POST', uri);

      for (var file in result.files) {
        request.files.add(await http.MultipartFile.fromPath(
          'files',
          file.path!,
        ));
      }

      try {
        var response = await request.send();

        if (response.statusCode == 200) {
          final bytes = await response.stream.toBytes();
          final dir = await getTemporaryDirectory();
          final file = File('${dir.path}/merged.pdf');
          await file.writeAsBytes(bytes);

          setState(() {
            resultMessage = "✅ Merge Successful!";
          });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ViewMergedPdfPage(path: file.path),
            ),
          );
        } else {
          setState(() {
            resultMessage = "❌ Merge failed. Status: ${response.statusCode}";
          });
        }
      } catch (e) {
        setState(() {
          resultMessage = "❌ Error occurred: $e";
        });
      }
    } else {
      setState(() {
        resultMessage = "⚠️ No file selected.";
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('PDF Merge App')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: isLoading ? null : uploadAndMergePDF,
              icon: Icon(Icons.picture_as_pdf),
              label: Text('Select & Merge PDF Files'),
            ),
            SizedBox(height: 20),
            if (isLoading) CircularProgressIndicator(),
            if (resultMessage.isNotEmpty)
              Text(
                resultMessage,
                style: TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}

class ViewMergedPdfPage extends StatelessWidget {
  final String path;
  const ViewMergedPdfPage({required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("View Merged PDF")),
      body: PDFView(
        filePath: path,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: false,
        pageFling: true,
      ),
    );
  }
}
