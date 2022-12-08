import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:text_to_speech/text_to_speech.dart';
import 'product_info_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int gestureDetectCount = 0;
  TextToSpeech tts = TextToSpeech();

  @override
  void initState() {
    super.initState();
    if (gestureDetectCount == 0) {
      tts.speak('현재는 홈 화면 입니다 왼쪽 방향으로 화면을 스와이프 하면 바코드 검색 카메라 화면으로 넘어갑니다');
    }
  }

// Platform messages are asynchronous, so we initialize in an async method.
  Future<String> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    print('바코드 스캐너 함수 시작');
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      print('바코드 스캐너 결과 : ${barcodeScanRes}');
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return '카메라 종료';

    setState(() {
      gestureDetectCount = 0;
    });
    return barcodeScanRes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Barcode scan'),
      // ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (details) async {
          // Swiping in right direction.
          if (details.delta.dx > 0) {
            print('오른쪽 방향 스와이프');
          }
          // Swiping in left direction.
          if (details.delta.dx < 0) {
            if (gestureDetectCount == 0) {
              setState(() {
                gestureDetectCount = gestureDetectCount + 1;
              });
              String barcodeResult = await scanBarcodeNormal();
              if (barcodeResult != '-1') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProductInfoPage(
                            barcodeResult: barcodeResult,
                          )),
                );
              } else {
                tts.speak('카메라 화면을 종료하였습니다 다시 카메라를 키시려면 왼쪽 방향으로 화면을 스와이프 하세요');
              }
            }
          }
        },
        child: Container(
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            // color: Color(0xFFcbd5dd),
            color: Color(0xFFfeebb7),
          ),
          child: Flex(
            direction: Axis.vertical,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.3,
                  bottom: MediaQuery.of(context).size.height * 0.3,
                ),
                child: Image(
                  image: const AssetImage('assets/application_name.png'),
                  width: MediaQuery.of(context).size.width * 0.8,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Image(
                    image: AssetImage('assets/hufs_logo.png'),
                    height: 48,
                  ),
                  SizedBox(
                    //row 요소 간격용
                    width: 8,
                  ),
                  Text(
                    '한국외국어대학교 GBT학부',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF002444),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
