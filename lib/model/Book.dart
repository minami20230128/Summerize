class Bookshelf {
  List<Book> books = [];

  void addBook(Book book) {
      books.add(book);
  }

  void deleteBook(Book book) {
    books.remove(book);
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
  String? insight;
  int bookId;

	Chapter({required this.chapterTitle, required this.content, required this.insight, required this.bookId});

  Chapter.load({
      required this.id,
      required this.chapterTitle,
      required this.content,
      required this.insight,
      required this.bookId,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
  return Chapter.load(
      id: json["id"],
      chapterTitle: json["title"],
      content: json["content"],
      insight: json["insight"],
      bookId: json["bookId"],
    );
  }
}