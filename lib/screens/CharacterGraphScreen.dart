import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CharacterGraphScreen(),
    );
  }
}

class CharacterGraphScreen extends StatefulWidget {
  @override
  _CharacterGraphScreenState createState() => _CharacterGraphScreenState();
}

class _CharacterGraphScreenState extends State<CharacterGraphScreen> {
  // 丸のリスト
  List<CircleData> circles = [];

  // 丸同士が重ならないか確認する関数
  bool _isPositionAvailable(double left, double top) {
    for (var circle in circles) {
      double distance = sqrt(pow(circle.left - left, 2) + pow(circle.top - top, 2));
      if (distance < 100) { // 丸の半径100で重ならないようにチェック
        return false;
      }
    }
    return true;
  }

  // 新しい丸を作成する関数
  void _addCircle() {
    double newLeft = 100.0;
    double newTop = 100.0;
    
    // 重ならない位置を探す
    bool positionFound = false;
    Random random = Random();

    while (!positionFound) {
      newLeft = random.nextDouble() * (MediaQuery.of(context).size.width - 100); // 幅の範囲内でランダムに位置を決定
      newTop = random.nextDouble() * (MediaQuery.of(context).size.height - 100); // 高さの範囲内でランダムに位置を決定

      // 重ならない位置が見つかるまでループ
      positionFound = _isPositionAvailable(newLeft, newTop);
    }

    setState(() {
      circles.add(CircleData(
        left: newLeft,
        top: newTop,
        text: '', // 初期状態では空のテキスト
      ));
    });
  }

  // ダイアログを表示する関数
  void _showTextDialog(BuildContext context, CircleData circle) {
    TextEditingController controller = TextEditingController();
    controller.text = circle.text;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('テキストを入力してください'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: '入力してください'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  circle.text = controller.text; // テキストを更新
                });
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
              child: Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
              child: Text('キャンセル'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ドラッグ可能な丸い図形"),
      ),
      body: Stack(
        children: [
          // 丸のリストを表示
          ...circles.map((circle) {
            return Positioned(
              top: circle.top,
              left: circle.left,
              child: GestureDetector(
                // 丸をドラッグする
                onPanStart: (details) {
                  circle.offsetX = details.localPosition.dx - circle.left;
                  circle.offsetY = details.localPosition.dy - circle.top;
                },
                onPanUpdate: (details) {
                  setState(() {
                    circle.top = details.localPosition.dy - circle.offsetY;
                    circle.left = details.localPosition.dx - circle.offsetX;
                  });
                },
                onTap: () {
                  _showTextDialog(context, circle); // 丸をクリックしてテキストダイアログを表示
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: Center(
                    child: Text(
                      circle.text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
          // 右下の「+」ボタン
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: _addCircle,
              child: Icon(Icons.add),
              backgroundColor: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}

// 丸のデータを保持するクラス
class CircleData {
  double left;
  double top;
  String text;
  double offsetX = 0;
  double offsetY = 0;

  CircleData({
    required this.left,
    required this.top,
    required this.text,
  });
}
