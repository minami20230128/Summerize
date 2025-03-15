import 'package:flutter/material.dart';
import 'package:summarize_app/services/APIService.dart';
import 'package:summarize_app/model/Book.dart';
import 'package:summarize_app/screens/CharacterGraphScreen.dart';
import 'package:summarize_app/screens/RelatedBooksScreen.dart';

class BookDetailScreen extends StatefulWidget {
  Book book;

  BookDetailScreen({Key? key, required this.book}) : super(key: key);

  @override
  _BookDetailScreenState createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final TextEditingController _chapterTitleController = TextEditingController();
  final TextEditingController _chapterContentController = TextEditingController();
  final TextEditingController _chapterInsightController = TextEditingController(); // insight用

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

  void _addChapter(String title, String content, String insight) async {
    print("Adding chapter to book ID: ${widget.book.id}");
    final newChapter = Chapter(chapterTitle: title, content: content, insight: insight, bookId: widget.book.id!);

    // APIを呼んでデータベースに登録
    newChapter.id = await ApiService.addChapter(newChapter);
    setState(() {
      widget.book.addChapter(newChapter);
    });
    _chapterTitleController.clear();
    _chapterContentController.clear();
    _chapterInsightController.clear(); // insightもクリア
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
              SizedBox(height: 8),
              TextField(
                controller: _chapterInsightController, // insight用のTextField
                decoration: InputDecoration(hintText: "気づき・感想（空欄可）"),
                maxLines: 3,
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
                final insight = _chapterInsightController.text.trim();
                if (title.isNotEmpty && content.isNotEmpty) {
                  _addChapter(title, content, insight); // insightを渡す
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

  // 編集ダイアログを表示
  void _showEditChapterDialog(Chapter chapter) {
    _chapterTitleController.text = chapter.chapterTitle;
    _chapterContentController.text = chapter.content;
    _chapterInsightController.text = chapter.insight ?? ''; // insightの初期値を設定

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
              SizedBox(height: 8),
              TextField(
                controller: _chapterInsightController, // 新しいTextField
                decoration: InputDecoration(hintText: "気づき・感想（空欄可）"),
                maxLines: 3,
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
                final insight = _chapterInsightController.text.trim();
                if (title.isNotEmpty && content.isNotEmpty) {
                  _updateChapter(chapter, title, content, insight); // insightを渡す
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
  void _updateChapter(Chapter chapter, String title, String content, String insight) async {
    print("Updating chapter ID: ${chapter.id}");
    chapter.chapterTitle = title;
    chapter.content = content;
    chapter.insight = insight; // insightを更新

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
  void _navigateToRelatedBooks(int bookId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RelatedBooksScreen(bookId: bookId)), // 画面遷移先を適宜指定
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
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chapter.chapterTitle, // chapter.titleを表示
                            style: TextStyle(
                              fontSize: 16, // フォントサイズを16に設定
                              fontWeight: FontWeight.bold, // 太字に設定
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '章の要約',
                            style: TextStyle(
                              fontSize: 12, // 「章の要約」のフォントサイズ
                              fontWeight: FontWeight.bold, // 太字に設定
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            chapter.content,
                            style: TextStyle(fontSize: 14), // 章内容のフォントサイズ
                          ),
                          SizedBox(height: 8),
                          Text(
                            '気づき・感想',
                            style: TextStyle(
                              fontSize: 12, // 「気づき・感想」のフォントサイズ
                              fontWeight: FontWeight.bold, // 太字に設定
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            chapter.insight ?? '', // `chapter.insight` の内容を表示
                            style: TextStyle(fontSize: 14), // フォントサイズ14
                          ),
                        ],
                      ),
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
                  onPressed: () => _navigateToRelatedBooks(widget.book.id!), // 新しいボタンのアクション
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
