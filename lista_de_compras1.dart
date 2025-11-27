
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

// DATA_MODEL
class ShoppingItem {
  String name;
  bool isChecked;

  ShoppingItem({required this.name, this.isChecked = false});
}

class ShoppingList extends ChangeNotifier {
  final List<ShoppingItem> _items = [];

  List<ShoppingItem> get items => List.unmodifiable(_items);

  void addItem(String name) {
    if (name.trim().isNotEmpty) {
      _items.add(ShoppingItem(name: name));
      notifyListeners();
    }
  }

  void removeItem(ShoppingItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void toggleItemChecked(ShoppingItem item) {
    final int index = _items.indexOf(item);
    if (index != -1) {
      _items[index].isChecked = !_items[index].isChecked;
      notifyListeners();
    }
  }

  void clearList() {
    _items.clear();
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ShoppingList>(
      create: (BuildContext context) => ShoppingList(),
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          title: 'Shopping Lista App',
          debugShowCheckedModeBanner: false,
          home: const ShoppingListScreen(),
        );
      },
    );
  }
}

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final TextEditingController _itemController = TextEditingController();

  @override
  void dispose() {
    _itemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ShoppingList shoppingList = context.watch<ShoppingList>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Natália Frazão Shopping Lista'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://i.imgur.com/CPjLzuk.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _itemController,
                      decoration: InputDecoration(
                        hintText: 'Adicionar novo item',
                        filled: true,
                        fillColor: Colors.white.withAlpha((255 * 0.8).round()),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      ),
                      onSubmitted: (String value) {
                        if (value.isNotEmpty) {
                          shoppingList.addItem(value);
                          _itemController.clear();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: () {
                      if (_itemController.text.isNotEmpty) {
                        shoppingList.addItem(_itemController.text);
                        _itemController.clear();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text('Adicionar'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: shoppingList.items.isEmpty
                  ? Center(
                      child: Text(
                        'Lista Vazia!',
                        style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                      ),
                    )
                  : ListView.builder(
                      itemCount: shoppingList.items.length,
                      itemBuilder: (BuildContext context, int index) {
                        final ShoppingItem item = shoppingList.items[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          color: Colors.white.withAlpha((255 * 0.9).round()),
                          child: ListTile(
                            title: Text(
                              item.name,
                              style: TextStyle(
                                decoration: item.isChecked ? TextDecoration.lineThrough : null,
                                color: item.isChecked ? Colors.grey : Colors.black,
                              ),
                            ),
                            leading: Checkbox(
                              value: item.isChecked,
                              onChanged: (bool? newValue) {
                                shoppingList.toggleItemChecked(item);
                              },
                              activeColor: Colors.blue.shade700,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                shoppingList.removeItem(item);
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<ShoppingList>().clearList();
        },
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        tooltip: 'Limpar itens',
        child: const Icon(Icons.delete_forever),
      ),
    );
  }
}