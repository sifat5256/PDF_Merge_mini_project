// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:syncfusion_flutter_docio/docio.dart';
// import 'package:syncfusion_flutter_pdf/pdf.dart';
// import 'package:syncfusion_docio_to_pdf/docio_to_pdf.dart';
// import 'package:open_file/open_file.dart';
//
// class DocxToPdfConverter extends StatefulWidget {
//   @override
//   _DocxToPdfConverterState createState() => _DocxToPdfConverterState();
// }
//
// class _DocxToPdfConverterState extends State<DocxToPdfConverter> {
//   String _status = 'Ready to convert';
//   bool _isConverting = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('DOCX to PDF Converter'),
//         backgroundColor: Colors.blue,
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(20.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.picture_as_pdf,
//               size: 100,
//               color: Colors.red,
//             ),
//             SizedBox(height: 30),
//             Text(
//               'Convert DOCX to PDF',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 20),
//             Text(
//               _status,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey[600],
//               ),
//             ),
//             SizedBox(height: 40),
//             ElevatedButton.icon(
//               onPressed: _isConverting ? null : _pickAndConvertFile,
//               icon: _isConverting
//                   ? SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: CircularProgressIndicator(strokeWidth: 2),
//               )
//                   : Icon(Icons.upload_file),
//               label: Text(_isConverting ? 'Converting...' : 'Select DOCX File'),
//               style: ElevatedButton.styleFrom(
//                 padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//                 textStyle: TextStyle(fontSize: 16),
//               ),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton.icon(
//               onPressed: _convertSampleDocument,
//               icon: Icon(Icons.description),
//               label: Text('Convert Sample Document'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//                 textStyle: TextStyle(fontSize: 16),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> _pickAndConvertFile() async {
//     try {
//       setState(() {
//         _isConverting = true;
//         _status = 'Selecting file...';
//       });
//
//       // Pick DOCX file
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['docx'],
//       );
//
//       if (result != null && result.files.single.path != null) {
//         setState(() {
//           _status = 'Converting document...';
//         });
//
//         File file = File(result.files.single.path!);
//         await _convertDocxToPdf(file.readAsBytesSync(), result.files.single.name);
//       } else {
//         setState(() {
//           _status = 'No file selected';
//           _isConverting = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _status = 'Error: ${e.toString()}';
//         _isConverting = false;
//       });
//     }
//   }
//
//   Future<void> _convertSampleDocument() async {
//     setState(() {
//       _isConverting = true;
//       _status = 'Creating sample document...';
//     });
//
//     try {
//       // Create a sample DOCX document
//       final WordDocument document = WordDocument();
//
//       // Add a section to the document
//       final WSection section = document.sections.addSection();
//
//       // Add a paragraph
//       final WParagraph paragraph = section.addParagraph();
//       paragraph.appendText('Hello World! This is a sample DOCX document.');
//
//       // Add another paragraph with formatting
//       final WParagraph paragraph2 = section.addParagraph();
//       final WTextRange textRange = paragraph2.appendText('This text is formatted.');
//       textRange.characterFormat.bold = true;
//       textRange.characterFormat.fontSize = 16;
//       textRange.characterFormat.fontColor = Color.fromARGB(255, 255, 0, 0);
//
//       // Add a third paragraph
//       final WParagraph paragraph3 = section.addParagraph();
//       paragraph3.appendText('This document will be converted to PDF using Syncfusion Flutter packages.');
//
//       // Save document as bytes
//       final List<int> docxBytes = document.saveAsStream();
//       document.dispose();
//
//       setState(() {
//         _status = 'Converting to PDF...';
//       });
//
//       await _convertDocxToPdf(Uint8List.fromList(docxBytes), 'sample_document.docx');
//
//     } catch (e) {
//       setState(() {
//         _status = 'Error creating sample: ${e.toString()}';
//         _isConverting = false;
//       });
//     }
//   }
//
//   Future<void> _convertDocxToPdf(Uint8List docxBytes, String fileName) async {
//     try {
//       // Load the DOCX document
//       final WordDocument document = WordDocument.fromBytes(docxBytes);
//
//       // Convert DOCX to PDF
//       final DocToPdfConverter converter = DocToPdfConverter();
//       final PdfDocument pdfDocument = converter.convertToPdf(document);
//
//       // Save PDF
//       final List<int> pdfBytes = pdfDocument.saveAsStream();
//
//       // Dispose documents
//       document.dispose();
//       pdfDocument.dispose();
//       converter.dispose();
//
//       // Save to device
//       await _savePdfFile(pdfBytes, fileName.replaceAll('.docx', '.pdf'));
//
//     } catch (e) {
//       setState(() {
//         _status = 'Conversion failed: ${e.toString()}';
//         _isConverting = false;
//       });
//     }
//   }
//
//   Future<void> _savePdfFile(List<int> pdfBytes, String fileName) async {
//     try {
//       // Get the directory to save the file
//       final Directory? directory = await getExternalStorageDirectory();
//       final String path = directory!.path;
//       final File file = File('$path/$fileName');
//
//       // Write PDF bytes to file
//       await file.writeAsBytes(pdfBytes);
//
//       setState(() {
//         _status = 'PDF saved successfully!\nLocation: ${file.path}';
//         _isConverting = false;
//       });
//
//       // Show success dialog
//       _showSuccessDialog(file.path);
//
//     } catch (e) {
//       setState(() {
//         _status = 'Failed to save PDF: ${e.toString()}';
//         _isConverting = false;
//       });
//     }
//   }
//
//   void _showSuccessDialog(String filePath) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Conversion Successful!'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('PDF has been saved to:'),
//               SizedBox(height: 10),
//               Text(
//                 filePath,
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontFamily: 'monospace',
//                   color: Colors.blue,
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text('OK'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 OpenFile.open(filePath);
//               },
//               child: Text('Open PDF'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }