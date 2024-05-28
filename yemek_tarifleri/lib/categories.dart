import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'meals.dart';

class CategoriesScreen extends StatelessWidget {
  Future<List<dynamic>> fetchCategories() async {
    final response = await http.get(Uri.parse(
        'https://www.themealdb.com/api/json/v1/1/categories.php')); //verileri json ile alıyoruz
    //Başarılı işlem dönerse
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['categories'];
    } else {
      throw Exception('Failed to load categories');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yemek Kategorileri'), //Ana Kategoriler
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Veri Yok'));
          } else {
            final categories = snapshot.data!;
            //verileri grid olarak alma
            return GridView.builder(
              //Verileri Grid içerisinde alma
              padding: EdgeInsets.all(10.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return GestureDetector(
                  //Hareketleri algılama, boyulandırmayı categoriye bırakma
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MealsScreen(category: category['strCategory']),
                      ),
                    );
                  },
                  //Kategorileri görsel olarak daha çekici hale getirme
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            // çerçeve köşeleri yuvarlama
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(10.0)),
                            child: Image.network(
                              category['strCategoryThumb'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            category['strCategory'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ), //Text
                        ), //padding
                      ],
                    ), //column
                  ), //card
                ); //GestureDetector
              },
            );
          }
        },
      ),
    );
  }
}
