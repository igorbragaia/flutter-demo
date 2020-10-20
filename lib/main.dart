import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map> pokemonsData;

  Future<Map> fetchPokemonData(String url) async {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      Map body = jsonDecode(response.body);

      String abilities =
          body["abilities"].map((el) => el["ability"]["name"]).join(" | ");
      return {
        "name": body["name"],
        "isFav": false,
        "abilities": abilities,
      };
    } else {
      return null;
    }
  }

  Future<void> getPokemons() async {
    List<Map> _pokemonsData = [];

    String dataUrl, imgUrl;
    for (int id = 1; id < 20; id++) {
      dataUrl = 'https://pokeapi.co/api/v2/pokemon/$id';
      imgUrl = 'https://pokeres.bastionbot.org/images/pokemon/$id.png';

      Map pokemonData = await fetchPokemonData(dataUrl);
      pokemonData["imgUrl"] = imgUrl;

      _pokemonsData.add(pokemonData);
    }
    setState(() {
      pokemonsData = _pokemonsData;
    });
  }

  void onPokemonFavTap(String name) {
    for (int i = 0; i < pokemonsData.length; i++)
      if (pokemonsData[i]['name'] == name)
        setState(() {
          pokemonsData[i]['isFav'] = !pokemonsData[i]['isFav'];
        });
  }

  Widget buildPokemon(
    String name,
    String abilities,
    String imgUrl,
    bool isFav,
  ) {
    return Container(
      margin: EdgeInsets.only(
        left: 8,
        right: 8,
        top: 4,
        bottom: 4,
      ),
      padding: EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: ListTile(
        leading: Image.network(imgUrl),
        title: Text(
          name,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          abilities,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.normal,
          ),
        ),
        trailing: Icon(
          isFav ? Icons.star : Icons.star_border,
          color: Colors.orangeAccent,
          size: 40,
        ),
        onTap: () => onPokemonFavTap(name),
      ),
    );
  }

  Widget buildPokemons() {
    List<Widget> pokemonsWidget = pokemonsData
        .map((el) => buildPokemon(
              el["name"],
              el["abilities"],
              el["imgUrl"],
              el["isFav"],
            ))
        .toList();

    return Container(
      color: Colors.pink.withOpacity(0.2),
      child: ListView(
        children: pokemonsWidget,
      ),
    );
  }

  Widget buildLoading() {
    return Container(
      color: Colors.pink.withOpacity(0.2),
      child: Center(
        child: Loading(
          indicator: BallPulseIndicator(),
          size: 100.0,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  void initState() {
    getPokemons();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: pokemonsData == null ? buildLoading() : buildPokemons(),
      ),
    );
  }
}
