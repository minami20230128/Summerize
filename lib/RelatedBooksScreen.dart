import 'package:flutter/material.dart';

class RelatedBooksScreen extends StatefulWidget {
  @override
  _RelatedBooksScreenState createState() => _RelatedBooksScreenState();
}

class _RelatedBooksScreenState extends State<RelatedBooksScreen> {
  // A list to hold related book data
  List<Map<String, String>> relatedBooks = [];

  final TextEditingController _bookNameController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

  // Show dialog to add a related book
  void _showAddRelatedBookDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("関連書籍を追加"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _bookNameController,
                decoration: InputDecoration(hintText: "書籍名"),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _urlController,
                decoration: InputDecoration(hintText: "関連URL"),
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
                final bookName = _bookNameController.text.trim();
                final url = _urlController.text.trim();

                if (bookName.isNotEmpty && url.isNotEmpty) {
                  _addRelatedBook(bookName, url);
                }
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Add the related book to the list
  void _addRelatedBook(String bookName, String url) {
    setState(() {
      relatedBooks.add({"bookName": bookName, "url": url});
    });

    // Clear the text fields
    _bookNameController.clear();
    _urlController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("関連書籍"),
      ),
      body: ListView.builder(
        itemCount: relatedBooks.length,
        itemBuilder: (context, index) {
          final book = relatedBooks[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(book["bookName"]!),
              subtitle: Text(book["url"]!),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRelatedBookDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
