import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf_merge/main.dart';
import 'package:pdf_merge/pdf_view_screen.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:io';

class PDFMergerScreen extends StatefulWidget {
  @override
  _PDFMergerScreenState createState() => _PDFMergerScreenState();
}

class _PDFMergerScreenState extends State<PDFMergerScreen> {
  List<PlatformFile> selectedFiles = [];
  String? mergedPdfPath;
  bool isLoading = false;
  double mergeProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await Permission.storage.request();
      await Permission.manageExternalStorage.request();
    }
  }

  Future<void> _pickPDFFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        List<PlatformFile> pdfFiles = result.files
            .where((file) => file.extension?.toLowerCase() == 'pdf')
            .take(10) // Allow up to 10 files
            .toList();

        if (pdfFiles.isEmpty) {
          _showErrorDialog('No valid PDF files selected');
          return;
        }

        setState(() {
          selectedFiles = pdfFiles;
          mergedPdfPath = null; // Reset merged PDF when new files are selected
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${pdfFiles.length} PDF file(s) selected'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('Error picking files: $e');
    }
  }

  Future<void> _mergePDFs() async {
    if (selectedFiles.length < 2) {
      _showErrorDialog('Please select at min  2 PDF files to merge');
      return;
    }

    setState(() {
      isLoading = true;
      mergeProgress = 0.0;
    });

    try {
      // Create a new PDF document using Syncfusion
      PdfDocument mergedDocument = PdfDocument();

      for (int i = 0; i < selectedFiles.length; i++) {
        setState(() {
          mergeProgress = (i / selectedFiles.length) * 0.9;
        });

        PlatformFile file = selectedFiles[i];
        if (file.path != null) {
          try {
            // Read the PDF file
            final bytes = await File(file.path!).readAsBytes();

            // Load the PDF document
            PdfDocument sourceDocument = PdfDocument(inputBytes: bytes);

            // Import all pages from the source document using the correct method
            for (int pageIndex = 0; pageIndex < sourceDocument.pages.count; pageIndex++) {
              // Get the page from source
              PdfPage sourcePage = sourceDocument.pages[pageIndex];

              // Create a new page in merged document with same size
              PdfPage newPage = mergedDocument.pages.add();

              // Import the page content using PdfPageTemplateElement
              PdfTemplate template = sourcePage.createTemplate();
              newPage.graphics.drawPdfTemplate(template, Offset.zero);
            }

            // Dispose the source document
            sourceDocument.dispose();

          } catch (e) {
            print('Error processing ${file.name}: $e');

            // Add an error page for files that couldn't be processed
            PdfPage errorPage = mergedDocument.pages.add();
            PdfGraphics graphics = errorPage.graphics;

            // Draw error message
            graphics.drawString(
              'Error loading: ${file.name}',
              PdfStandardFont(PdfFontFamily.helvetica, 20),
              bounds: Rect.fromLTWH(50, 100, errorPage.getClientSize().width - 100, 50),
              brush: PdfSolidBrush(PdfColor(255, 0, 0)),
            );

            graphics.drawString(
              'File could not be processed and merged.',
              PdfStandardFont(PdfFontFamily.helvetica, 14),
              bounds: Rect.fromLTWH(50, 150, errorPage.getClientSize().width - 100, 50),
              brush: PdfSolidBrush(PdfColor(128, 128, 128)),
            );
          }
        }
      }

      setState(() {
        mergeProgress = 0.95; // 95% - saving file
      });

      // Save the merged document
      List<int> mergedBytes = await mergedDocument.save();
      mergedDocument.dispose();

      // Get the application documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = 'merged_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final String filePath = '${appDir.path}/$fileName';

      // Write the merged PDF to file
      final File mergedFile = File(filePath);
      await mergedFile.writeAsBytes(mergedBytes);

      setState(() {
        mergedPdfPath = filePath;
        isLoading = false;
        mergeProgress = 1.0;
      });

      _showSuccessDialog('PDFs merged successfully!\nFile saved as: $fileName\nTotal files merged: ${selectedFiles.length}');
    } catch (e) {
      setState(() {
        isLoading = false;
        mergeProgress = 0.0;
      });
      _showErrorDialog('Error merging PDFs: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Success'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _clearFiles() {
    setState(() {
      selectedFiles.clear();
      mergedPdfPath = null;
    });
  }

  void _removeFile(int index) {
    setState(() {
      selectedFiles.removeAt(index);
      if (selectedFiles.isEmpty) {
        mergedPdfPath = null;
      }
    });
  }

  void _reorderFiles(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final PlatformFile item = selectedFiles.removeAt(oldIndex);
      selectedFiles.insert(newIndex, item);
    });
  }

  Future<void> _sharePDF() async {
    if (mergedPdfPath != null) {
      await Share.shareXFiles([XFile(mergedPdfPath!)], text: 'Merged PDF Document');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Merger'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.picture_as_pdf,
                        size: 48,
                        color: Colors.red[400],
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'PDF Merger Tool',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Select multiple PDF files to merge into one document',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Select Files Button
            ElevatedButton.icon(
              onPressed: isLoading ? null : _pickPDFFiles,
              icon: Icon(Icons.upload_file),
              label: Text('Select PDF Files'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                textStyle: TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            SizedBox(height: 16),

            // Selected Files List
            if (selectedFiles.isNotEmpty) ...[
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Selected Files (${selectedFiles.length})',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: isLoading ? null : _clearFiles,
                            icon: Icon(Icons.clear_all, size: 18),
                            label: Text('Clear All'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Drag to reorder files:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(height: 12),
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: selectedFiles.length,
                        onReorder: _reorderFiles,
                        itemBuilder: (context, index) {
                          PlatformFile file = selectedFiles[index];
                          return Container(
                            key: ValueKey(file.path),
                            margin: EdgeInsets.only(bottom: 8),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.drag_handle, color: Colors.grey[400], size: 20),
                                SizedBox(width: 8),
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red[100],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(Icons.picture_as_pdf, color: Colors.red[600], size: 20),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${index + 1}. ${file.name}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '${(file.size / 1024).toStringAsFixed(1)} KB',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: isLoading ? null : () => _removeFile(index),
                                  icon: Icon(Icons.remove_circle_outline, color: Colors.red[400]),
                                  constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Merge Button with Progress
              if (isLoading) ...[
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Merging PDFs...',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: mergeProgress,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${(mergeProgress * 100).toInt()}%',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                ElevatedButton.icon(
                  onPressed: selectedFiles.length >= 2 ? _mergePDFs : null,
                  icon: Icon(Icons.merge_type),
                  label: Text('Merge PDFs'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    textStyle: TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ],

            // Merged PDF Result
            if (mergedPdfPath != null) ...[
              SizedBox(height: 24),
              Card(
                color: Colors.green[50],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.green[600],
                          size: 32,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'PDF Files Combined!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Files have been combined into a single document',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PDFViewerScreen(pdfPath: mergedPdfPath!),
                                  ),
                                );
                              },
                              icon: Icon(Icons.visibility),
                              label: Text('View PDF'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange[600],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _sharePDF,
                              icon: Icon(Icons.share),
                              label: Text('Share'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple[600],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
