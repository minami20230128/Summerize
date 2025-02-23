import 'package:flutter/material.dart';

class CharacterGraphScreen extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text("人物相関図"),
			),
			body: PersonGraph(),
		);
	}
}

class PersonNode {
	String name;
	Offset position;

	PersonNode({required this.name, required this.position});
}

class Relationship {
	final PersonNode from;
	final PersonNode to;
	String relation;

	Relationship({required this.from, required this.to, required this.relation});
}

class GraphPainter extends CustomPainter {
	final List<PersonNode> nodes;
	final List<Relationship> relationships;

	GraphPainter({required this.nodes, required this.relationships});

	@override
	void paint(Canvas canvas, Size size) {
		final paint = Paint()
			..color = Colors.black
			..strokeWidth = 2;

		for (var relationship in relationships) {
			canvas.drawLine(relationship.from.position, relationship.to.position, paint);
		}
	}

	@override
	bool shouldRepaint(covariant CustomPainter oldDelegate) {
		return true;
	}
}

class NodeWidget extends StatelessWidget {
	final PersonNode node;

	NodeWidget({required this.node});

	@override
	Widget build(BuildContext context) {
		return GestureDetector(
			onTap: () {
			// Nodeがタップされたときの動作
			},
			child: Container(
				padding: EdgeInsets.all(10),
				decoration: BoxDecoration(
					shape: BoxShape.circle,
					color: Colors.blue,
				),
				child: Text(node.name, style: TextStyle(color: Colors.white)),
			),
		);
	}
}

class PersonGraph extends StatefulWidget {
	@override
	_PersonGraphState createState() => _PersonGraphState();
}

class _PersonGraphState extends State<PersonGraph> {
	List<PersonNode> nodes = [];
	List<Relationship> relationships = [];
	PersonNode? selectedNode;
	Relationship? selectedRelationship;

	@override
	Widget build(BuildContext context) {
		return GestureDetector(
			onPanUpdate: (details) {
				if (selectedNode != null) {
					setState(() {
						selectedNode!.position += details.localPosition;
					});
				}
			},
			onTap: () {
				setState(() {
					selectedNode = null;
					selectedRelationship = null;
				});
			},
			child: CustomPaint(
				size: Size(double.infinity, double.infinity),
				painter: GraphPainter(nodes: nodes, relationships: relationships),
				child: Stack(
					children: [
						...nodes.map((node) => Positioned(
							left: node.position.dx,
							top: node.position.dy,
							child: GestureDetector(
								onPanUpdate: (details) {
									setState(() {
										node.position += details.localPosition;
									});
								},
								child: NodeWidget(node: node),
							),
						)),
						if (selectedNode != null) _buildNameInputDialog(),
						if (selectedRelationship != null) _buildRelationshipInputDialog(),
						_buildAddPersonButton(),  // 「+」ボタンを追加
					],
				),
			),
		);
	}

	Widget _buildAddPersonButton() {
	return Positioned(
		right: 16,
		bottom: 16,
		child: FloatingActionButton(
		onPressed: _addPerson,
		child: Icon(Icons.add),
		),
	);
	}

	void _addPerson() async {
	// 新しい人物の名前を入力してもらうダイアログを表示
	final newName = await _showDialog('人物の追加', '');
	if (newName != null && newName.isNotEmpty) {
		setState(() {
			final newNode = PersonNode(
				name: newName,
				position: Offset(100.0, 100.0), // 初期位置を設定（適切な位置に調整可能）
			);
			nodes.add(newNode);

			for(PersonNode node in nodes)
			{
				print(node.name);
			}
		});
	}
	}

	Widget _buildNameInputDialog() {
		return Positioned(
			left: selectedNode!.position.dx + 20,
			top: selectedNode!.position.dy - 40,
			child: Material(
				color: Colors.transparent,
				child: InkWell(
					onTap: () async {
						final newName = await _showDialog(
							'名前の変更',
							selectedNode!.name,
						);
						if (newName != null && newName.isNotEmpty) {
							setState(() {
								selectedNode!.name = newName;
							});
						}
					},
					child: Container(
					padding: EdgeInsets.all(8.0),
					color: Colors.blue.withOpacity(0.5),
					child: Text(selectedNode!.name),
					),
				),
			),
		);
	}

	Widget _buildRelationshipInputDialog() {
		return Positioned(
			left: (selectedRelationship!.from.position.dx + selectedRelationship!.to.position.dx) / 2,
			top: (selectedRelationship!.from.position.dy + selectedRelationship!.to.position.dy) / 2,
			child: Material(
				color: Colors.transparent,
				child: InkWell(
					onTap: () async {
						final newRelation = await _showDialog(
							'関係の変更',
							selectedRelationship!.relation,
						);
						if (newRelation != null && newRelation.isNotEmpty) {
							setState(() {
								selectedRelationship!.relation = newRelation;
							});
						}
					},
					child: Container(
						padding: EdgeInsets.all(8.0),
						color: Colors.green.withOpacity(0.5),
						child: Text(selectedRelationship!.relation),
					),
				),
			),
		);
	}

	Future<String?> _showDialog(String title, String initialValue) async {
		String inputValue = initialValue;
		return showDialog<String>(
			context: context,
			builder: (context) {
				return AlertDialog(
					title: Text(title),
					content: TextField(
						autofocus: true,
						decoration: InputDecoration(hintText: "入力してください"),
						onChanged: (value) {
							inputValue = value;
						},
						controller: TextEditingController()..text = inputValue,
					),
					actions: [
						TextButton(
							onPressed: () => Navigator.of(context).pop(inputValue),
							child: Text("OK"),
						),
					],
				);
			},
		);
	}
}
