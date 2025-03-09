import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:summarize_app/model/Book.dart';
import 'package:summarize_app/model/RelatedBook.dart';

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

  // 関連書籍をAPIに追加するメソッド
  static Future<int?> addRelatedBook(RelatedBook relatedBook) async {

    // API呼び出し（POSTリクエスト）
    final response = await http.post(
      Uri.parse("$baseUrl/related-books"),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'bookId': relatedBook.bookId, // bookIdを一緒に送る
        'title': relatedBook.title,
        'url': relatedBook.url,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      final data = jsonDecode(response.body);
          return data["id"]; // 保存された chapterId を返す
    }
    return null;
  }

  static Future<List<RelatedBook>> fetchRelatedBooks(int bookId) async {
    final response = await http.get(Uri.parse("$baseUrl/related-books/by-book-id/${bookId}"));

        if (response.statusCode == 200) {
            List<dynamic> data = jsonDecode(response.body);
            print('Response body: ${response.body}');
            return data.map((json) => RelatedBook.fromJson(json)).toList();
        } else {
            throw Exception("Failed to load books");
        }
  }
}