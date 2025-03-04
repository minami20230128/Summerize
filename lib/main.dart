import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'CharacterGraphScreen.dart';
import 'RelatedBooksScreen.dart';

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
        print(chapter.content);
        final response = await http.post(
            Uri.parse("$baseUrl/chapters"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
                "chapterTitle": chapter.chapterTitle,
                "content": chapter.content,
                "bookId": chapter.bookId
            }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
            final data = jsonDecode(response.body);
            return data["id"]; // 保存された chapterId を返す
        }
        return null;
    }

    static Future<List<Book>> fetchBooksWithChapters() async {
        final response = await http.get(Uri.parse("$baseUrl/books/details"));

        if (response.statusCode == 200) {
            List<dynamic> data = jsonDecode(response.body);
            print('Response body: ${response.body}');
            return data.map((json) => Book.fromJson(json)).toList();
        } else {
            throw Exception("Failed to load books");
        }
    }

    // 章を更新
    static Future<bool> updateChapter(Chapter chapter) async {
        final response = await http.put(
            Uri.parse("$baseUrl/chapters/${chapter.id}"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
                "chapterTitle": chapter.chapterTitle,
                "content": chapter.content,
                "book": {
                    "id": chapter.bookId // 必要ならbookのidも送信
                }
            }),
        );

        if (response.statusCode == 200 || response.statusCode == 204) {
            print("Chapter updated successfully");
            return true;
        } else {
            print("Failed to update chapter. Status code: ${response.statusCode}");
            return false;
        }
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
    Book.load({
        required this.id,
        required this.title,
        required this.chapters
    });

	void addChapter(Chapter chapter) {
        chapters.add(chapter);
	}

    factory Book.fromJson(Map<String, dynamic> json) {
    return Book.load(
        id: json["id"],
        title: json["title"],
        chapters: (json["chapters"] as List<dynamic>)
            .map((chapterJson) => Chapter.fromJson(chapterJson))
            .toList(),
        );
    }
}

class Chapter {
    int? id;
	String chapterTitle;
	String content;
    int bookId;

	Chapter({required this.chapterTitle, required this.content, required this.bookId});

    Chapter.load({
        required this.id,
        required this.chapterTitle,
        required this.content,
        required this.bookId,
    });

    factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter.load(
        id: json["id"],
        chapterTitle: json["title"],
        content: json["content"],
        bookId: json["bookId"],
        );
    }
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

class BookDetailScreen extends StatefulWidget {
	Book book;

	BookDetailScreen({Key? key, required this.book}) : super(key: key);

	@override
	_BookDetailScreenState createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
    final TextEditingController _chapterTitleController = TextEditingController();
    final TextEditingController _chapterContentController = TextEditingController();

    @override
    void initState() {
        super.initState();
        _fetchChapters(); // 画面表示時に最新の章を取得
    }

    void _fetchChapters() async {
        // 最新の書籍データを取得
        List<Book> books = await ApiService.fetchBooksWithChapters();
        Book? updatedBook = books.firstWhere((b) => b.id == widget.book.id, orElse: () => widget.book);

        setState(() {
            widget.book = updatedBook;
        });
    }

    void _addChapter(String title, String content) async {
        print("Adding chapter to book ID: ${widget.book.id}");
        final newChapter = Chapter(chapterTitle: title, content: content, bookId: widget.book.id!);

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

    // 章情報を編集するためのダイアログを表示
    void _showEditChapterDialog(Chapter chapter) {
        _chapterTitleController.text = chapter.chapterTitle;
        _chapterContentController.text = chapter.content;

        showDialog(
            context: context,
            builder: (BuildContext context) {
                return AlertDialog(
                    title: Text("章の編集"),
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
                                    _updateChapter(chapter, title, content);
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

    // 章情報を更新する
    void _updateChapter(Chapter chapter, String title, String content) async {
        print("Updating chapter ID: ${chapter.id}");
        chapter.chapterTitle = title;
        chapter.content = content;

        // APIを呼んで更新
        await ApiService.updateChapter(chapter);

        // 更新後に画面を再描画
        setState(() {
            // 更新した章をリストの中で置き換え
            int index = widget.book.chapters.indexWhere((ch) => ch.id == chapter.id);
            if (index != -1) {
                widget.book.chapters[index] = chapter;
            }
        });
    }

    // 人物相関図画面に遷移
    void _navigateToCharacterGraph() {
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CharacterGraphScreen()),
        );
    }

      // 「関連書籍」画面に遷移する関数
    void _navigateToRelatedBooks() {
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RelatedBooksScreen()), // 画面遷移先を適宜指定
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
                              return GestureDetector(
                                  onTap: () {
                                      _showEditChapterDialog(chapter); // 章をタップしたときに編集ダイアログを表示
                                  },
                                  child: Card(
                                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                      child: ListTile(
                                          title: Text(chapter.chapterTitle),
                                          subtitle: Text(chapter.content),
                                      ),
                                  ),
                              );
                          },
                      ),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                          children: [
                              ElevatedButton(
                                  onPressed: _showAddChapterDialog,
                                  child: Text("章を追加"),
                              ),
                              SizedBox(width: 16),
                              ElevatedButton(
                                  onPressed: _navigateToCharacterGraph,
                                  child: Text("人物相関図"),
                              ),
                              SizedBox(width: 16),
                              ElevatedButton(
                                  onPressed: _navigateToRelatedBooks, // 新しいボタンのアクション
                                  child: Text("関連書籍"),
                              ),
                          ],
                      ),
                  ),
              ],
          ),
      );
  }
}