import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product List App',
      home: ProductList(),
    );
  }
}

class ProductList extends StatefulWidget {
  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  late Future<List<Data>> futureProducts;

  @override
  void initState() {
    super.initState();
    futureProducts = fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data List'),
      ),
      body: FutureBuilder<List<Data>>(
        future: futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Data> datas = snapshot.data!;
            return CustomProductListView(datas: datas);
          }
        },
      ),
    );
  }
}

class CustomProductListView extends StatelessWidget {
  final List<Data> datas;

  CustomProductListView({required this.datas});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: datas.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.all(8.0),
          child: ListTile(
            leading: CircleAvatar(
              // Use NetworkImage to load the avatar from a URL
              backgroundImage: NetworkImage(datas[index].avatar),
            ),
            title: Text(datas[index].first_name+" "+datas[index].last_name),
            // You can customize the list item further based on your product model
          ),
        );
      },
    );
  }
}

class Data {
  final int id;
  final String email;
  final String first_name;
  final String last_name;
  final String avatar;

  Data({required this.id, required this.email, required this.first_name, required this.last_name, required this.avatar});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json['id'],
      email: json['email'],
      first_name: json['first_name'],
      last_name: json['last_name'],
      avatar: json['avatar'],
    );
  }
}

Future<List<Data>> fetchProducts() async {
  final response =
      await http.get(Uri.parse('https://reqres.in/api/users?pages=2'));

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body)['data'];
    List<Data> products =
        data.map((json) => Data.fromJson(json)).toList();
    return products;
  } else {
    throw Exception('Failed to load products');
  }
}