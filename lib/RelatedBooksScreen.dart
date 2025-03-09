import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';  // JSON処理のため
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class RelatedBook {
  int? id;
  String title;
  String url;
  int bookId;

  RelatedBook({required this.title, required this.url, required this.bookId});

  RelatedBook.load({
    required this.id,
    required this.title,
    required this.url,
    required this.bookId
  });

  // JSONからインスタンスを生成するためのファクトリメソッド
  factory RelatedBook.fromJson(Map<String, dynamic> json) {
    return RelatedBook.load(
      id: json['id'],
      title: json['title'],
      url: json['url'],
      bookId: json['bookId'],
    );
  }

  // インスタンスをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
      'bookId':bookId
    };
  }
}

class RelatedBooksScreen extends StatefulWidget {
  final int bookId;
  RelatedBooksScreen({required this.bookId});

  @override
  _RelatedBooksScreenState createState() => _RelatedBooksScreenState();
}

class _RelatedBooksScreenState extends State<RelatedBooksScreen> {
  List<RelatedBook> relatedBooks = [];

  final TextEditingController _bookNameController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

  // 関連書籍を追加するダイアログ
  void _showAddRelatedBookDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("関連書籍を追加"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _bookNameController,
                decoration: InputDecoration(hintText: "書籍名"),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _urlController,
                decoration: InputDecoration(hintText: "関連URL"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("キャンセル"),
            ),
            TextButton(
              onPressed: () async {
                final bookName = _bookNameController.text.trim();
                final url = _urlController.text.trim();

                if (bookName.isNotEmpty && url.isNotEmpty) {
                  // APIを呼び出してデータベースに保存
                  await _addRelatedBook(bookName, url);
                }
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // 関連書籍をAPIに追加するメソッド
  Future<void> _addRelatedBook(String bookName, String url) async {
    final relatedBook = RelatedBook(title: bookName, url: url, bookId: widget.bookId);
    
    // APIのURL（バックエンドで設定したURLに合わせてください）
    final apiUrl = 'https://example.com/api/relatedBooks'; 

    // API呼び出し（POSTリクエスト）
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'bookId': widget.bookId, // bookIdを一緒に送る
        'title': relatedBook.title,
        'url': relatedBook.url,
      }),
    );

    if (response.statusCode == 201) {
      // 成功した場合
      final responseJson = jsonDecode(response.body);
      final addedRelatedBook = RelatedBook.fromJson(responseJson);

      setState(() {
        relatedBooks.add(addedRelatedBook);
      });
    } else {
      // エラーハンドリング
      print('Failed to add related book');
    }

    // 入力欄をクリア
    _bookNameController.clear();
    _urlController.clear();
  }

  // URLを開く関数
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("関連書籍"),
      ),
      body: ListView.builder(
        itemCount: relatedBooks.length,
        itemBuilder: (context, index) {
          final book = relatedBooks[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(book.title),
              subtitle: GestureDetector(
                onTap: () => _launchURL(book.url),
                child: Text(
                  book.url,
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRelatedBookDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
