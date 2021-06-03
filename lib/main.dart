import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
  await FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
      );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey webViewKey = GlobalKey();
  bool _isLoading = true;

  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
          useShouldOverrideUrlLoading: true,
          mediaPlaybackRequiresUserGesture: false,
          useOnDownloadStart: true),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(children: <Widget>[
          InAppWebView(
            initialUrlRequest: URLRequest(
                url: Uri.parse(
                    "https://sosyalbilgiler.biz/forum/konu/cocuk-haklari-her-yerde-ders-notu.62761/")),
            initialOptions: options,
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            onLoadStop: (controller, url) {
              setState(() {
                _isLoading = false;
              });
            },
            onLoadStart: (controller, url) {
              setState(() {
                _isLoading = true;
              });
            },
            onDownloadStart: (controller, url) async {
              print("indirme adresi: $url");
              final status = await Permission.storage.request();
              if (status.isGranted) {
                final savedDir = await getExternalStorageDirectory();
                FlutterDownloader.enqueue(
                    url: url.toString(),
                    savedDir: savedDir!.path,
                    showNotification: true,
                    openFileFromNotification: true);
              } else {
                print("izin hatası");
              }
            },
          ),
          _isLoading
              ? Center(
                  child: Container(
                      height: 80,
                      width: 80,
                      margin: EdgeInsets.all(5),
                      child: LoadingIndicator(
                        indicatorType: Indicator.ballRotateChase,
                        color: Colors.red,
                      )),
                )
              : Container(),
        ]),
      ),
    );
  }
}
