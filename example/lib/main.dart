import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:find_dropdown/find_dropdown.dart';

import 'user_model.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var countriesKey = GlobalKey<FindDropdownState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("FindDropdown Example")),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: <Widget>[
            FindDropdown(
              items: [
                "Brasil",
                "Itália",
                "Estados Unidos",
                "Canadá"
              ],
              label: "País",
              onChanged: (item) {
                print(item);
                countriesKey.currentState?.setSelectedItem(<String>[]);
              },
              selectedItem: "Brasil",
              showSearchBox: false,
              labelStyle: TextStyle(color: Colors.redAccent),
              backgroundColor: Colors.redAccent,
              titleStyle: TextStyle(color: Colors.greenAccent),
              validate: (String? item) {
                if (item == null)
                  return "Required field";
                else if (item == "Brasil")
                  return "Invalid item";
                else
                  return null;
              },
            ),
            FindDropdown<String>.multiSelect(
              key: countriesKey,
              items: [
                "Brasil",
                "Itália",
                "Estados Unidos",
                "Canadá"
              ],
              label: "Países",
              selectedItems: [
                "Brasil"
              ],
              onChanged: (selectedItems) => print("countries: $selectedItems"),
              showSearchBox: false,
              labelStyle: TextStyle(color: Colors.redAccent),
              titleStyle: TextStyle(color: Colors.greenAccent),
              dropdownItemBuilder: (context, item, isSelected) {
                return ListTile(
                  title: Text(item.toString()),
                  trailing: isSelected ? Icon(Icons.check) : null,
                  selected: isSelected,
                );
              },
              okButtonBuilder: (context, onPressed) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: FloatingActionButton(child: Icon(Icons.check), onPressed: onPressed, mini: true),
                );
              },
              validate: (List<String>? items) {
                print("VALIDATION: $items");
                String? response;
                if (items == null || items.isEmpty) {
                  response = "Required field";
                } else if (items.contains("Brasil")) {
                  response = "'Brasil' não pode ser selecionado.";
                }
                print(response);
                return response;
              },
            ),
            FindDropdown<UserModel>(
              label: "Nome",
              onFind: (String filter) => getData(filter),
              searchBoxDecoration: InputDecoration(hintText: "Search", border: OutlineInputBorder()),
              onChanged: (UserModel? data) => print(data),
            ),
            FindDropdown<UserModel>(
              label: "Personagem",
              onFind: (String filter) => getData(filter),
              onChanged: (UserModel? data) => print(data),
              dropdownBuilder: (BuildContext context, UserModel? item) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                  ),
                  child: (item?.avatar == null)
                      ? ListTile(leading: CircleAvatar(), title: Text("No item selected"))
                      : ListTile(
                          leading: CircleAvatar(backgroundImage: NetworkImage(item!.avatar)),
                          title: Text(item.name),
                          subtitle: Text(item.createdAt.toString()),
                        ),
                );
              },
              dropdownItemBuilder: (BuildContext context, UserModel item, bool isSelected) {
                return Container(
                  decoration: !isSelected
                      ? null
                      : BoxDecoration(
                          border: Border.all(color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.white,
                        ),
                  child: ListTile(
                    selected: isSelected,
                    title: Text(item.name),
                    subtitle: Text(item.createdAt.toString()),
                    leading: CircleAvatar(backgroundImage: NetworkImage(item.avatar)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<List<UserModel>> getData(filter) async {
    var response = await Dio().get(
      "http://5d85ccfb1e61af001471bf60.mockapi.io/user",
      queryParameters: {
        "filter": filter
      },
    );

    var models = UserModel.fromJsonList(response.data);
    return models;
  }
}
