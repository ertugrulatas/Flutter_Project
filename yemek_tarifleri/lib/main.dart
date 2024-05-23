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
      title: 'Yemek Tarifleri',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CategoriesScreen(),
    );
  }
}

class CategoriesScreen extends StatelessWidget {
  Future<List<dynamic>> fetchCategories() async {
    final response = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/categories.php'));

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
        title: Text('Yemek Kategorileri'),
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
            return ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return ListTile(
                  title: Text(category['strCategory']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MealsScreen(category: category['strCategory']),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

class MealsScreen extends StatelessWidget {
  final String category;

  MealsScreen({required this.category});

  Future<List<dynamic>> fetchMeals() async {
    final response = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/filter.php?c=$category'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['meals'];
    } else {
      throw Exception('Failed to load meals');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$category Tarifleri'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchMeals(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Veri Yok'));
          } else {
            final meals = snapshot.data!;
            return ListView.builder(
              itemCount: meals.length,
              itemBuilder: (context, index) {
                final meal = meals[index];
                return ListTile(
                  title: Text(meal['strMeal']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MealDetailScreen(mealId: meal['idMeal']),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

class MealDetailScreen extends StatelessWidget {
  final String mealId;

  MealDetailScreen({required this.mealId});

  Future<Map<String, dynamic>> fetchMealDetail() async {
    final response = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/lookup.php?i=$mealId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['meals'][0];
    } else {
      throw Exception('Failed to load meal detail');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yemek Detayı'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchMealDetail(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Veri Yok'));
          } else {
            final meal = snapshot.data!;
            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal['strMeal'],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(meal['strInstructions']),
                  SizedBox(height: 16),
                  meal['strMealThumb'] != null
                      ? Image.network(meal['strMealThumb'])
                      : Container(),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}