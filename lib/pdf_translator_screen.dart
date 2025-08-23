import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:archive/archive.dart';

class PDFTranslatorScreen extends StatefulWidget {
  const PDFTranslatorScreen({super.key});

  @override
  State<PDFTranslatorScreen> createState() => _PDFTranslatorScreenState();
}

class _PDFTranslatorScreenState extends State<PDFTranslatorScreen> {
  bool isLoading = false;
  String? translatedFilePath;

  /// Extract translated document from ZIP archive
  Future<void> extractDocumentFromZip(List<int> zipBytes, Directory dir) async {
    try {
      print("Extracting files from ZIP archive...");

      // Decode the ZIP archive
      final archive = ZipDecoder().decodeBytes(zipBytes);

      print("ZIP contains ${archive.length} files:");

      // List all files in the archive for debugging
      for (final file in archive) {
        print("- ${file.name} (${file.size} bytes, isFile: ${file.isFile})");
      }

      // Check if this is a DOCX file (contains Word document structure)
      bool isDocxStructure = archive.any((file) =>
      file.name.startsWith('word/') ||
          file.name == '[Content_Types].xml' ||
          file.name.startsWith('_rels/'));

      if (isDocxStructure) {
        print("Detected DOCX structure - saving complete ZIP as DOCX file");

        // Save the entire ZIP as a DOCX file since DOCX is essentially a ZIP
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final docxFile = File("${dir.path}/translated_$timestamp.docx");
        await docxFile.writeAsBytes(zipBytes);

        if (await docxFile.exists()) {
          final fileSize = await docxFile.length();
          print("DOCX file saved successfully. Size: $fileSize bytes");

          setState(() {
            translatedFilePath = docxFile.path;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Translation success, DOCX file saved")),
          );
          return;
        }
      }

      // Fallback: Look for individual document files
      ArchiveFile? targetFile;
      String targetExtension = '.pdf';

      // Priority order: PDF -> DOCX -> DOC -> TXT
      final extensionPriority = ['.pdf', '.docx', '.doc', '.txt', '.rtf'];

      for (final ext in extensionPriority) {
        for (final file in archive) {
          if (file.isFile && file.name.toLowerCase().endsWith(ext)) {
            targetFile = file;
            targetExtension = ext;
            print("Found document file: ${file.name}");
            break;
          }
        }
        if (targetFile != null) break;
      }

      // If no specific document found, get the largest meaningful file
      if (targetFile == null) {
        for (final file in archive) {
          if (file.isFile && file.size > 1000 && // Ignore very small files
              !file.name.startsWith('_') && // Ignore metadata files
              !file.name.contains('rels') && // Ignore relationship files
              file.name.contains('.')) { // Must have extension

            if (targetFile == null || file.size > targetFile.size) {
              targetFile = file;
              targetExtension = '.${file.name.split('.').last}';
            }
          }
        }
        if (targetFile != null) {
          print("Using largest meaningful file: ${targetFile.name} (${targetFile.size} bytes)");
        }
      }

      if (targetFile != null) {
        // Extract the individual file
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final translatedFile = File("${dir.path}/translated_$timestamp$targetExtension");

        final content = targetFile.content as List<int>;
        await translatedFile.writeAsBytes(content);

        if (await translatedFile.exists()) {
          final fileSize = await translatedFile.length();
          print("File extracted and saved successfully. Size: $fileSize bytes");

          // Check if the content is actually PDF (sometimes files have wrong extensions)
          if (content.length >= 4) {
            final header = String.fromCharCodes(content.take(4));
            if (header == '%PDF' && targetExtension != '.pdf') {
              // It's actually a PDF, rename it
              final pdfFile = File("${dir.path}/translated_$timestamp.pdf");
              await translatedFile.rename(pdfFile.path);
              setState(() {
                translatedFilePath = pdfFile.path;
              });
              print("File was actually PDF, renamed with .pdf extension");
            } else {
              setState(() {
                translatedFilePath = translatedFile.path;
              });
            }
          } else {
            setState(() {
              translatedFilePath = translatedFile.path;
            });
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("✅ Translation success, ${targetExtension.substring(1).toUpperCase()} file saved")),
          );
        } else {
          throw Exception("Failed to save extracted file");
        }
      } else {
        // Last resort: save entire ZIP for manual inspection
        throw Exception("No suitable files found in the ZIP archive");
      }
    } catch (e) {
      print("ZIP extraction error: $e");

      // Fallback: save as ZIP file for manual inspection
      final zipFile = File("${dir.path}/translated_archive_${DateTime.now().millisecondsSinceEpoch}.zip");
      await zipFile.writeAsBytes(zipBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("⚠️ Could not extract file automatically. ZIP saved for manual inspection."),
          backgroundColor: Colors.orange,
        ),
      );

      setState(() {
        translatedFilePath = zipFile.path;
      });

      print("ZIP file saved at: ${zipFile.path}");
    }
  }

  /// Pick a PDF file from device
  Future<void> pickAndTranslate() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      String filePath = result.files.single.path!;
      await translatePDF(filePath);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No file selected")),
      );
    }
  }

  /// Upload PDF to Systran API and download translated file
  Future<void> translatePDF(String filePath) async {
    setState(() {
      isLoading = true;
    });

    try {
      var uri = Uri.parse("https://api-translate.systran.net/translation/file/translate");
      var request = http.MultipartRequest("POST", uri);

      request.headers['Authorization'] = "Key aed17661-1bbe-47e4-971c-71841bbe133e";

      // Add the PDF file
      request.files.add(await http.MultipartFile.fromPath(
        'input',
        filePath,
        contentType: MediaType('application', 'pdf'),
      ));

      request.fields['source'] = "en";
      request.fields['target'] = "hi";
      request.fields['format'] = "application/pdf";

      print("Sending request to Systran API...");
      var response = await request.send();
      print("Response status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        // Get response headers to check content type
        String? contentType = response.headers['content-type'];
        print("Content-Type: $contentType");

        // Get the response bytes first
        final bodyBytes = await response.stream.toBytes();
        print("Response size: ${bodyBytes.length} bytes");

        // Check if response starts with PDF signature (%PDF) or PK (ZIP)
        if (bodyBytes.length >= 4) {
          String header = String.fromCharCodes(bodyBytes.take(4));
          print("Response header: $header");

          if (header == '%PDF') {
            // Direct PDF file
            print("Detected PDF response");
            final dir = await getApplicationDocumentsDirectory();
            final translatedFile = File("${dir.path}/translated_${DateTime.now().millisecondsSinceEpoch}.pdf");
            await translatedFile.writeAsBytes(bodyBytes);

            if (await translatedFile.exists()) {
              final fileSize = await translatedFile.length();
              print("PDF saved successfully. Size: $fileSize bytes");

              setState(() {
                translatedFilePath = translatedFile.path;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("✅ Translation success, PDF file saved")),
              );
            } else {
              throw Exception("Failed to save translated file");
            }
            return;
          } else if (header.startsWith('PK')) {
            // ZIP file containing translated document
            print("Detected ZIP/Archive response");
            final dir = await getApplicationDocumentsDirectory();
            await extractDocumentFromZip(bodyBytes, dir);
            return;
          }
        }

        // Try to decode as JSON if it's not a PDF or ZIP
        try {
          var bodyString = utf8.decode(bodyBytes);
          print("Response body (first 200 chars): ${bodyString.length > 200 ? bodyString.substring(0, 200) + '...' : bodyString}");

          final data = jsonDecode(bodyString);

          if (data['outputs'] != null && data['outputs'].isNotEmpty) {
            String downloadUrl = data['outputs'][0]['outputUrl'];
            print("Download URL: $downloadUrl");

            // Download the translated file
            await downloadTranslatedFile(downloadUrl);
          } else if (data['error'] != null) {
            throw Exception("API Error: ${data['error']['message'] ?? 'Unknown error'}");
          } else {
            throw Exception("Unexpected response format");
          }
        } catch (e) {
          if (e is FormatException) {
            // This might be binary data that's not UTF-8 decodable
            print("UTF-8 decode failed, treating as binary file");

            // Check if it might be a ZIP file based on magic bytes
            if (bodyBytes.length >= 2 && bodyBytes[0] == 0x50 && bodyBytes[1] == 0x4B) {
              final dir = await getApplicationDocumentsDirectory();
              await extractDocumentFromZip(bodyBytes, dir);
            } else {
              // Save as generic file
              final dir = await getApplicationDocumentsDirectory();
              final translatedFile = File("${dir.path}/translated_${DateTime.now().millisecondsSinceEpoch}.bin");
              await translatedFile.writeAsBytes(bodyBytes);

              setState(() {
                translatedFilePath = translatedFile.path;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("✅ Translation success, file saved")),
              );
            }
          } else {
            rethrow;
          }
        }
      } else {
        var errorBody = await response.stream.bytesToString();
        print("Error response: $errorBody");
        throw Exception("API request failed with status ${response.statusCode}: $errorBody");
      }

    } catch (e) {
      print("Translation error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Translation failed: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Download translated file from URL
  Future<void> downloadTranslatedFile(String downloadUrl) async {
    try {
      print("Downloading file from: $downloadUrl");

      var fileResponse = await http.get(
        Uri.parse(downloadUrl),
        headers: {
          'Authorization': "Key aed17661-1bbe-47e4-971c-71841bbe133e",
        },
      );

      print("File download status: ${fileResponse.statusCode}");

      if (fileResponse.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();

        // Determine file type from response
        final bodyBytes = fileResponse.bodyBytes;
        String fileExtension = '.pdf'; // Default

        if (bodyBytes.length >= 4) {
          String header = String.fromCharCodes(bodyBytes.take(4));
          if (header == '%PDF') {
            fileExtension = '.pdf';
          } else if (header.startsWith('PK')) {
            // Could be DOCX or ZIP
            fileExtension = '.docx'; // Assume DOCX for now
          }
        }

        final translatedFile = File("${dir.path}/translated_${DateTime.now().millisecondsSinceEpoch}$fileExtension");
        await translatedFile.writeAsBytes(bodyBytes);

        // Verify file was written
        if (await translatedFile.exists()) {
          final fileSize = await translatedFile.length();
          print("File saved successfully. Size: $fileSize bytes");

          setState(() {
            translatedFilePath = translatedFile.path;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("✅ Translation success, ${fileExtension.substring(1).toUpperCase()} file saved")),
          );
        } else {
          throw Exception("Failed to save translated file");
        }
      } else {
        throw Exception("Failed to download translated file: ${fileResponse.statusCode}");
      }
    } catch (e) {
      print("Download error: $e");
      throw Exception("Failed to download translated file: $e");
    }
  }

  /// Open translated file using open_filex
  void openTranslatedFile() async {
    if (translatedFilePath != null) {
      try {
        // Verify file exists before opening
        final file = File(translatedFilePath!);
        if (await file.exists()) {
          print("Opening file: $translatedFilePath");
          final result = await OpenFilex.open(translatedFilePath!);
          print("Open file result: ${result.message}");

          if (result.type != ResultType.done) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Could not open file: ${result.message}"),
                action: SnackBarAction(
                  label: "Try Again",
                  onPressed: openTranslatedFile,
                ),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Translated file not found")),
          );
        }
      } catch (e) {
        print("Error opening file: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error opening file: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF Translator"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: isLoading
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Translating PDF...", style: TextStyle(fontSize: 16)),
            ],
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.picture_as_pdf,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),
              const Text(
                "PDF Translator",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "English to Hindi",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: pickAndTranslate,
                icon: const Icon(Icons.upload_file),
                label: const Text("Pick & Translate PDF"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              if (translatedFilePath != null) ...[
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 30,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Translation Complete!",
                  style: TextStyle(color: Colors.green, fontSize: 16),
                ),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: openTranslatedFile,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text("Open Translated File"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}