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