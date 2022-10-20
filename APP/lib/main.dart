import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:text_to_speech/text_to_speech.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget imgWidget = const SizedBox();
  String productName = '제품을 찾기 위해 카메라 버튼을 누른후 바코드를 봐주세요';
  TextToSpeech tts = TextToSpeech();

  @override
  void initState() {
    super.initState();
  }

  Map<String, dynamic> getProductName({required String htmlString}) {
    if (htmlString.contains('noresult')) {
      setState(() {
        imgWidget = const SizedBox();
        productName = '제품을 찾기 위해 카메라 버튼을 누른후 바코드를 봐주세요';
      });
      return {'result': false, 'productName': '등록되지 않은 바코드입니다'};
    } else {
      var result = htmlString.split('\n');
      var imgTag = result[391].split('"');

      setState(() {
        imgWidget = Image.network(imgTag[1]);
        productName = result[381].substring(44);
      });
      return {
        'result': true,
        'productName': result[381].substring(44),
        'imgUrl': imgTag[1],
      };
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    var url = Uri.parse(
        'http://www.koreannet.or.kr/home/hpisSrchGtin.gs1?gtin=$barcodeScanRes');
    var response = await http.get(url);

    var productname = getProductName(htmlString: response.body);
    debugPrint('product name : ${productname['result']}');
    tts.speak('${productname['productName']}');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Barcode scan'),
          actions: [
            IconButton(
              icon: new Icon(Icons.camera_alt),
              tooltip: 'open camera',
              onPressed: () => {scanBarcodeNormal()},
            ),
          ],
        ),
        body: Builder(
          builder: (BuildContext context) {
            return Container(
              alignment: Alignment.center,
              child: Flex(
                direction: Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  imgWidget,
                  Text(productName),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
