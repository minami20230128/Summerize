import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:summarize_app/APIService.dart';
import 'package:summarize_app/Book.dart';
import 'package:summarize_app/BookDetailScreen.dart';
import 'dart:convert';
import 'CharacterGraphScreen.dart';
import 'RelatedBooksScreen.dart';

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

    @override
    void initState() {
        super.initState();
        _fetchBooks(); // アプリ起動時にDBからデータを取得
    }

    void _fetchBooks() async {
        List<Book> books = await ApiService.fetchBooksWithChapters();
        setState(() {
            _bookshelf.books = books; // 取得した書籍を_bookshelfにセット
        });
        }

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