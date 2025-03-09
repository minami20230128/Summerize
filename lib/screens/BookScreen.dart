import 'package:flutter/material.dart';
import 'package:summarize_app/model/Book.dart';
import 'package:summarize_app/screens/BookDetailScreen.dart';
import 'package:summarize_app/services/APIService.dart';

class BookScreen extends StatefulWidget {
  @override
  _BookScreenState createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
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

  // 書籍を編集
  void _editBook(Book book) {
    print("Editing book: ${book.title}");
    // 編集処理、例えばダイアログでタイトル変更など
    _showEditBookDialog(book);
  }

  // 書籍を消去
  Future<void> _deleteBook(Book book) async {
    print("Deleting book: ${book.title}");
    // 消去処理、APIを呼んで削除など
    await ApiService.deleteBook(book.id!);
    setState(() {
      _bookshelf.deleteBook(book);
    });
  }

  // 書籍編集ダイアログ
  void _showEditBookDialog(Book book) {
    final TextEditingController _titleController = TextEditingController(text: book.title);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("書籍のタイトルを編集"),
          content: TextField(
            controller: _titleController,
            decoration: InputDecoration(hintText: "新しいタイトル"),
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
                final newTitle = _titleController.text.trim();
                if (newTitle.isNotEmpty) {
                  ApiService.updateBookTitle(book.id!, newTitle);
                  setState(() {
                    book.title = newTitle;  // タイトルを更新
                  });
                }
                Navigator.of(context).pop();
              },
              child: Text("保存"),
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
              trailing: PopupMenuButton<String>(
                icon: Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'edit') {
                    _editBook(book);  // 編集
                  } else if (value == 'delete') {
                    _deleteBook(book);  // 消去
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('編集'),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('消去'),
                    ),
                  ];
                },
              ),
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

  // 書籍を追加するダイアログ
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

  // 書籍を追加するメソッド
  void _addBook(String title) async {
    final newBook = Book(title: title);

    // APIを呼び出してデータベースに登録
    newBook.id = await ApiService.addBook(newBook);
    setState(() {
      _bookshelf.addBook(newBook);
    });
  }
}
