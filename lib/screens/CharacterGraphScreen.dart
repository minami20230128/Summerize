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
  // 選択された丸のインデックスリスト
  List<int> selectedCircleIndexes = [];

  // 丸同士が重ならないか確認する関数
  bool _isPositionAvailable(double left, double top) {
    print("_isPositionAvailable()"); // デバッグ用
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
    print("_addCircle()"); // デバッグ用
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
    print("_showTextDialog()"); // デバッグ用
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

  // 丸がダブルクリックされたときの処理
  void _handleCircleDoubleTap(int index) {
    print("_handleCircleDoubleTap()"); // デバッグ用
    setState(() {
      if (selectedCircleIndexes.contains(index)) {
        // 既に選択されている場合は選択解除
        selectedCircleIndexes.remove(index);
        circles[index].isSelected = false;
      } else {
        // 新たに選択
        selectedCircleIndexes.add(index);
        circles[index].isSelected = true;
      }

      // 選択された丸が2つなら線を引く
      if (selectedCircleIndexes.length == 2) {
        // 丸同士の線を描画
        print("線を引く: ${selectedCircleIndexes[0]} と ${selectedCircleIndexes[1]}");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print("build()"); // デバッグ用
    print("SelectedCircleIndexes.length: ${selectedCircleIndexes.length}");
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
                  print("onPanStart()"); // デバッグ用
                  circle.offsetX = details.localPosition.dx - circle.left;
                  circle.offsetY = details.localPosition.dy - circle.top;
                },
                onPanUpdate: (details) {
                  print("onPanUpdate()"); // デバッグ用
                  setState(() {
                    circle.top = details.localPosition.dy - circle.offsetY;
                    circle.left = details.localPosition.dx - circle.offsetX;
                  });
                },
                onDoubleTap: () {
                  print("onDoubleTap()"); // デバッグ用
                  _handleCircleDoubleTap(circles.indexOf(circle)); // 丸をダブルクリックして選択
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: circle.isSelected ? Colors.blue : Colors.grey, // 選択された丸の色を変更
                    border: Border.all(
                      color: circle.isSelected ? Colors.yellow : Colors.transparent, // 枠の色
                      width: 3,
                    ),
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

          // 2つの丸が選択されている場合のみ線を引く
          if (selectedCircleIndexes.length == 2)
            CustomPaint(
              painter: LinePainter(
                circles[selectedCircleIndexes[0]],
                circles[selectedCircleIndexes[1]],
              ),
            ),

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
  bool isSelected; // 丸が選択されているかどうか
  double offsetX = 0;
  double offsetY = 0;

  CircleData({
    required this.left,
    required this.top,
    required this.text,
    this.isSelected = false,
  });
}

// 丸と丸を結ぶ線を描画するクラス
class LinePainter extends CustomPainter {
  final CircleData circle1;
  final CircleData circle2;

  LinePainter(this.circle1, this.circle2);

  @override
  void paint(Canvas canvas, Size size) {
    print("LinePainter.paint()"); // デバッグ用
    final Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    print("circle1の中心 ${circle1.left + 50}, ${circle1.top + 50}");
    print("circle2の中心 ${circle2.left + 50}, ${circle2.top + 50}");

    // 丸1と丸2の中心を結ぶ線を描画
    canvas.drawLine(
      Offset(circle1.left + 50, circle1.top + 50), // 丸1の中心
      Offset(circle2.left + 50, circle2.top + 50), // 丸2の中心
      paint,
    );

    print("描画完了");
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
