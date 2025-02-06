import 'package:postgres/postgres.dart';

class DatabaseHelper {
  final PostgreSQLConnection _connection;

  DatabaseHelper()
      : _connection = PostgreSQLConnection(
          'summarize-chapter.calmwawsw61k.us-east-1.rds.amazonaws.com', // RDSのエンドポイント
          5432,               // ポート番号 (PostgreSQLのデフォルト)
          'postgres',    // データベース名
          username: 'postgres',
          password: 'postgres',
        );

  Future<void> connect() async {
    if (_connection.isClosed) {
      await _connection.open();
      print('Database connected.');
    }
  }

  Future<void> disconnect() async {
    if (!_connection.isClosed) {
      await _connection.close();
      print('Database disconnected.');
    }
  }

  Future<int> insertBook(String title) async {
    final result = await _connection.query(
      'INSERT INTO book (title) VALUES (@title) RETURNING book_id;',
      substitutionValues: {'title': title},
    );
    return result.first[0]; // 挿入された書籍のIDを返す
  }

  Future<void> insertChapter(int bookId, String chapterTitle, String content) async {
    await _connection.query(
      'INSERT INTO chapter (book_id, chapter_title, content) VALUES (@bookId, @chapterTitle, @content);',
      substitutionValues: {
        'bookId': bookId,
        'chapterTitle': chapterTitle,
        'content': content,
      },
    );
  }
}
