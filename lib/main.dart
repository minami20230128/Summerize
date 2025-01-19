import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BookSummaryApp(),
    );
  }
}

class BookSummaryApp extends StatefulWidget {
  @override
  _BookSummaryAppState createState() => _BookSummaryAppState();
}

class _BookSummaryAppState extends State<BookSummaryApp> {
  final List<String> _bookTitles = [];

  void _addBookTitle(String title) {
    setState(() {
      _bookTitles.add(title);
    });
  }

  void _showAddBookDialog() {
    final TextEditingController _titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("書籍のタイトルを入力"),
          content: TextField(
            controller: _titleController,
            decoration: InputDecoration(hintText: "例: Flutter入門"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("キャンセル"),
            ),
            TextButton(
              onPressed: () {
                final title = _titleController.text.trim();
                if (title.isNotEmpty) {
                  _addBookTitle(title);
                }
                Navigator.of(context).pop();
              },
              child: Text("追加"),
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
        title: Text("書籍要約アプリ"),
      ),
      body: ListView.builder(
        itemCount: _bookTitles.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(_bookTitles[index]),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        BookDetailScreen(title: _bookTitles[index]),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBookDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}

class BookDetailScreen extends StatefulWidget {
  final String title;

  const BookDetailScreen({Key? key, required this.title}) : super(key: key);

  @override
  _BookDetailScreenState createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final List<Map<String, String>> _chapters = [];
  final TextEditingController _chapterTitleController = TextEditingController();
  final TextEditingController _chapterContentController =
      TextEditingController();

  void _addChapter(String title, String content) {
    setState(() {
      _chapters.add({"title": title, "content": content});
    });
    _chapterTitleController.clear();
    _chapterContentController.clear();
  }

  void _showAddChapterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("章の追加"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _chapterTitleController,
                decoration: InputDecoration(hintText: "章のタイトル"),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _chapterContentController,
                decoration: InputDecoration(hintText: "章の内容"),
                maxLines: 5,
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
              onPressed: () {
                final title = _chapterTitleController.text.trim();
                final content = _chapterContentController.text.trim();
                if (title.isNotEmpty && content.isNotEmpty) {
                  _addChapter(title, content);
                }
                Navigator.of(context).pop();
              },
              child: Text("追加"),
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
        title: Text("書籍: ${widget.title}"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _chapters.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(_chapters[index]["title"] ?? ""),
                    subtitle: Text(_chapters[index]["content"] ?? ""),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _showAddChapterDialog,
              child: Text("章を追加"),
            ),
          ),
        ],
      ),
    );
  }
}
