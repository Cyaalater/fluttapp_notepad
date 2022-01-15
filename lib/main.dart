import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MaterialApp(
      debugShowCheckedModeBanner: false, title: 'rabin', home: Home()));
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> data = ["Hello", "World"];
  List<String> titles = ['1', '2'];
  final _controller = TextEditingController();

  @override
  void _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      titles = prefs.getStringList('titles') ?? [];
      data = (prefs.getStringList('data') ?? []);
    });
  }

  void _saveData(List<String> inpData) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      data.add(inpData[1]);
      titles.add(inpData[0]);
    });
    prefs.setStringList('data', data);
    prefs.setStringList('titles', titles);
  }

  void _removeData(String inpData) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      titles.removeAt(data.indexOf(inpData));
      data.remove(inpData);
    });
    prefs.setStringList('data', data);
  }

  Widget build(BuildContext context) {
    _loadData();
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.blue[500],
          title: const Text('Notepad'),
          centerTitle: true),
      body: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  children: data.map((val) {
                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 8,
                            child: ExpansionTile(
                              backgroundColor: Colors.grey[200],
                              title: Text('${titles[data.indexOf(val)]}',
                                  style: TextStyle(fontSize: 20)),
                              children: [ListTile(title: Text(val))],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: ElevatedButton(
                                onPressed: () {
                                  _removeData(val);
                                },
                                child: Icon(Icons.close)),
                          )
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ])),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            _awaitReturnValueFromCreateNote(context);
          },
          child: Icon(Icons.add)),
    );
  }

  void _awaitReturnValueFromCreateNote(BuildContext context) async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => const CreateNote()));
    if (result != null) {
      _saveData([result[0], result[1]]);
    }
  }
}

class CreateNote extends StatefulWidget {
  const CreateNote({Key? key}) : super(key: key);

  @override
  _CreateNoteState createState() => _CreateNoteState();
}

class _CreateNoteState extends State<CreateNote> {
  final _formkey = GlobalKey<FormState>();
  final _titleForm = TextEditingController();
  final _bodyForm = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Creating a note')),
        body: Form(
            key: _formkey,
            child: Column(
              children: [
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter some text";
                    } else {
                      return null;
                    }
                  },
                  decoration: const InputDecoration(hintText: 'Note title'),
                  controller: _titleForm,
                ),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter some text";
                    } else {
                      return null;
                    }
                  },
                  decoration:
                      const InputDecoration(hintText: 'Body of the note'),
                  maxLines: 4,
                  controller: _bodyForm,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: () {
                        if (_formkey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Note added!')));
                          Navigator.pop(
                              context, [_titleForm.text, _bodyForm.text]);
                        }
                      },
                      child: Icon(Icons.add)),
                )
              ],
            )));
  }
}
