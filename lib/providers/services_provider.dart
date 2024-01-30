// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prismaerd/screens/diagram_screen.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import '../widgets/show_toast.dart';

class ServicesProvider extends ChangeNotifier {
  bool isLoading = false;
  WebViewController? webController;

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  TextEditingController inputController = TextEditingController();

  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  ConnectivityResult get connectionStatus => _connectionStatus;

  String? _htmlString;
  String? get htmlString => _htmlString;

  set htmlString(String? value) => _htmlString;

  ServicesProvider() {
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void disposeConnection() {
    _connectivitySubscription.cancel();
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
      return;
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    _connectionStatus = result;
    notifyListeners();
  }

  void generate(context, String schema) async {
    isLoading = true;
    notifyListeners();
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    await getData(schema, context);

    if (htmlString != null) {
      controller
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.white)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              debugPrint('WebView is loading (progress : $progress%)');
            },
            onPageStarted: (String url) {
              debugPrint('Page started loading: $url');
            },
            onPageFinished: (String url) async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DiagramScreen(),
                ),
              );
              reset();
            },
            onWebResourceError: (WebResourceError error) {
              //     debugPrint('''
              //       Page resource error:
              //         code: ${error.errorCode}
              //         description: ${error.description}
              //         errorType: ${error.errorType}
              //         isForMainFrame: ${error.isForMainFrame}
              // ''');
            },
            onNavigationRequest: (NavigationRequest request) {
              if (request.url.startsWith('https://www.youtube.com/')) {
                debugPrint('blocking navigation to ${request.url}');
                return NavigationDecision.prevent;
              }
              debugPrint('allowing navigation to ${request.url}');
              return NavigationDecision.navigate;
            },
            onUrlChange: (UrlChange change) {
              debugPrint('url change to ${change.url}');
            },
          ),
        )
        ..addJavaScriptChannel(
          'Toaster',
          onMessageReceived: (JavaScriptMessage message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message.message)),
            );
          },
        )
        ..loadHtmlString(
            Provider.of<ServicesProvider>(context, listen: false).htmlString!);

      if (controller.platform is AndroidWebViewController) {
        AndroidWebViewController.enableDebugging(true);
        (controller.platform as AndroidWebViewController)
            .setMediaPlaybackRequiresUserGesture(false);
      }

      webController = controller;
    }
  }

  void reset() {
    _htmlString = null;
    isLoading = false;
    notifyListeners();
  }

  Future<void> getData(String data, BuildContext context) async {
    String baseUrl = 'https://api.onkarsagare.com/prisma-erd/generate';

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"data": data}),
      );
      if (response.statusCode == 200) {
        _htmlString = response.body;
        notifyListeners();
      } else {
        isLoading = false;
        notifyListeners();
        showToast('Something went wrong');
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      showToast(e.toString());
    }
  }
}
