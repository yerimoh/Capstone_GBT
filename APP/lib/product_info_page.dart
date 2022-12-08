import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:text_to_speech/text_to_speech.dart';

class ProductInfoPage extends StatefulWidget {
  ProductInfoPage({Key? key, required this.barcodeResult}) : super(key: key);
  final String barcodeResult;

  @override
  State<ProductInfoPage> createState() => _ProductInfoPageState();
}

class _ProductInfoPageState extends State<ProductInfoPage> {
  int gestureDetectCount = 0;
  String productName = '';
  Widget imgWidget = const SizedBox();
  TextToSpeech tts = TextToSpeech();

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await getProductName();
    });
    super.initState();
  }

  Future<void> getProductName() async {
    String barcodeScanRes = widget.barcodeResult;
    var url = Uri.parse(
        'http://www.koreannet.or.kr/home/hpisSrchGtin.gs1?gtin=$barcodeScanRes');
    // String response = (await http.get(url)) as String;

    var responseTest = await http.get(url);
    String response = responseTest.body;

    if (response.contains('noresult')) {
      setState(() {
        productName = "등록되지 않은 바코드 입니다 오른쪽 방향으로 스와이프 하시면 홈 화면으로 돌아갑니다";
      });
      tts.speak('등록되지 않은 바코드 입니다 오른쪽 방향으로 스와이프 하시면 홈 화면으로 돌아갑니다');
    } else {
      var result = response.split('\n');
      var imgTag = result[391].split('"');

      setState(() {
        imgWidget = ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Image.network(
            imgTag[1],
            fit: BoxFit.fill,
          ),
        );
        productName = result[381].substring(44);
      });
      print('product name : ${productName}');
      print('barcodeResult : ${barcodeScanRes}');
      tts.speak('제품명 ${productName} 오른쪽 방향으로 스와이프 하시면 홈 화면으로 돌아갑니다');
    }

    // var productname = getProductName(response: response.body);
    // debugPrint('product name : ${productname['result']}');
    // tts.speak('${productname['productName']}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (details) async {
          // Swiping in right direction.
          if (details.delta.dx > 0) {
            print('오른쪽 방향 스와이프');
            if (gestureDetectCount == 0) {
              setState(() {
                gestureDetectCount = gestureDetectCount + 1;
              });
              Navigator.pop(context);
            }
          }
          // Swiping in left direction.
          if (details.delta.dx < 0) {
            print('왼쪽 방향 스와이프');
          }
        },
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(
            left: 12,
            right: 12,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFFfeebb7),
          ),
          child: Flex(
            direction: Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              imgWidget,
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(
                  top: 28,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF002d57),
                    width: 3,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  color: const Color(0xFFffed02),
                ),
                child: Text(
                  productName,
                  style: const TextStyle(
                    color: Color(0xFF002d57),
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
