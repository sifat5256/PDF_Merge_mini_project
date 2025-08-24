
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf_merge/merge_screen.dart';
import 'package:pdf_merge/pdf_translator_screen.dart';
import 'package:pdf_merge/unique_card.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:io';

import 'business_card_2.dart';
import 'business_card_3.dart';
import 'business_card_4.dart';
import 'business_card_design.dart';
import 'fancy_business_card.dart';
import 'merge_pdf_with_api.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Merger',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CreativeBusinessCardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

