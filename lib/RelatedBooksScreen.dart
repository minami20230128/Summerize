import 'package:flutter/material.dart';
import 'package:summarize_app/APIService.dart';
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

  @override
  void initState() {
      super.initState();
      _fetchRelatedBooks(); // 画面表示時に最新の章を取得
  }

  void _fetchRelatedBooks() async {
    List<RelatedBook> books = await ApiService.fetchRelatedBooks(widget.bookId);
    setState(() {
      relatedBooks = books;
      print("relatedBooks size: ${relatedBooks.length}");
    });
  }

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
                  final relatedBook = RelatedBook(title: bookName, url: url, bookId: widget.bookId);
                  relatedBook.id = await ApiService.addRelatedBook(relatedBook);

                  setState(() {
                    this.relatedBooks.add(relatedBook);
                  });

                  // 入力欄をクリア
                  _bookNameController.clear();
                  _urlController.clear();
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
