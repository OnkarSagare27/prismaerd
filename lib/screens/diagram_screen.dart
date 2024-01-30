import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prismaerd/providers/services_provider.dart';
import 'package:prismaerd/widgets/show_toast.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image_gallery_saver/image_gallery_saver.dart';

class DiagramScreen extends StatelessWidget {
  DiagramScreen({super.key});
  final GlobalKey globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leadingWidth: 60.w,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.deepPurpleAccent,
          ),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text('Output'),
        titleTextStyle: TextStyle(
          color: Colors.deepPurpleAccent,
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: RepaintBoundary(
        key: globalKey,
        child: WebViewWidget(
            controller: Provider.of<ServicesProvider>(context).webController!),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurpleAccent,
        onPressed: () => _saveImage(),
        child: const Icon(
          Icons.save_rounded,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> _saveImage() async {
    RenderRepaintBoundary boundary =
        globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List uint8List = byteData!.buffer.asUint8List();
    final result = await ImageGallerySaver.saveImage(uint8List);

    if (result['isSuccess']) {
      showToast('Image saved at ${result['filePath']}');
    } else {
      showToast('Failed to save image');
    }
  }
}
