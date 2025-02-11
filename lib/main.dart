import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'database_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = "http://localhost:8080/api";

  // 書籍を追加
  static Future<int?> addBook(Book book) async {
    final response = await http.post(
      Uri.parse("$baseUrl/books"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"title": book.title}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Book added successfully");
      final data = jsonDecode(response.body);
      print(data["id"]);
      return data["id"];  // 返された書籍のIDを取得
      } 
    return null;
  }

  // 章を追加
  static Future<int?> addChapter(Chapter chapter) async {
    print(chapter.book_id);
    final response = await http.post(
      Uri.parse("$baseUrl/chapters"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "chapterTitle": chapter.chapterTitle,
        "content": chapter.content,
        "bookId": chapter.book_id
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data["id"]; // 保存された chapterId を返す
    }
    return null;
  }
}


class Bookshelf {
	List<Book> books = [];

	void addBook(Book book) {
		books.add(book);
	}
}

class Book {
  int? id;
	String title;
	List<Chapter> chapters = [];

	Book({required this.title});

	void addChapter(Chapter chapter) {
	  chapters.add(chapter);
	}
}

class Chapter {
  int? id;
	String chapterTitle;
	String content;
  int book_id;

	Chapter({required this.chapterTitle, required this.content, required this.book_id});
}

void main() async {
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
	final Bookshelf _bookshelf = Bookshelf();

	void _addBook(String title) async {
    final newBook = Book(title: title);

    // APIを呼んでデータベースに登録
    newBook.id = await ApiService.addBook(newBook);
    print(newBook.id);
    setState(() {
      _bookshelf.addBook(newBook);
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
					_addBook(title);
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
		itemCount: _bookshelf.books.length,
		itemBuilder: (context, index) {
			final book = _bookshelf.books[index];
			return Card(
			margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
			child: ListTile(
				title: Text(book.title),
				onTap: () {
          print("Navigating to BookDetailScreen with book ID: ${book.id}");
				Navigator.push(
					context,
					MaterialPageRoute(
					builder: (context) => BookDetailScreen(book: book),
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
	final Book book;

	const BookDetailScreen({Key? key, required this.book}) : super(key: key);

	@override
	_BookDetailScreenState createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
	final TextEditingController _chapterTitleController = TextEditingController();
	final TextEditingController _chapterContentController = TextEditingController();

	void _addChapter(String title, String content) async {
    print("Adding chapter to book ID: ${widget.book.id}");
    final newChapter = Chapter(chapterTitle: title, content: content, book_id: widget.book.id!);

    // APIを呼んでデータベースに登録
    newChapter.id = await ApiService.addChapter(newChapter);
		setState(() {
    widget.book.addChapter(newChapter);
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
		title: Text("書籍の詳細: ${widget.book.title}"),
		),
		body: Column(
		children: [
			Expanded(
			child: ListView.builder(
				itemCount: widget.book.chapters.length,
				itemBuilder: (context, index) {
				final chapter = widget.book.chapters[index];
				return Card(
					margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
					child: ListTile(
					title: Text(chapter.chapterTitle),
					subtitle: Text(chapter.content),
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
