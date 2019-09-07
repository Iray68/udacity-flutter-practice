import 'package:flutter/material.dart';
import 'dart:convert';
import 'category.dart';
import 'unit.dart';
import 'category_tile.dart';
import 'backdrop.dart';
import 'unit_converter.dart';
import 'api.dart';

final _backgroundColor = Colors.green[100];

class CategoryRoute extends StatefulWidget {
  const CategoryRoute();

  @override
  _CategoryRouteState createState() {
    return _CategoryRouteState();
  }
}

class _CategoryRouteState extends State<CategoryRoute> {

  final _categoryList = <Category>[];
  Category _currentCategory;

  static const _categoryNames = <String>[
    'Length',
    'Area',
    'Volume',
    'Mass',
    'Time',
    'Digital Storage',
    'Energy',
    'Currency',
  ];

  static const _baseColors = <ColorSwatch>[
    ColorSwatch(0xFF6AB7A8, {
      'highlight': Color(0xFF6AB7A8),
      'splash': Color(0xFF0ABC9B),
    }),
    ColorSwatch(0xFFFFD28E, {
      'highlight': Color(0xFFFFD28E),
      'splash': Color(0xFFFFA41C),
    }),
    ColorSwatch(0xFFFFB7DE, {
      'highlight': Color(0xFFFFB7DE),
      'splash': Color(0xFFF94CBF),
    }),
    ColorSwatch(0xFF8899A8, {
      'highlight': Color(0xFF8899A8),
      'splash': Color(0xFFA9CAE8),
    }),
    ColorSwatch(0xFFEAD37E, {
      'highlight': Color(0xFFEAD37E),
      'splash': Color(0xFFFFE070),
    }),
    ColorSwatch(0xFF81A56F, {
      'highlight': Color(0xFF81A56F),
      'splash': Color(0xFF7CC159),
    }),
    ColorSwatch(0xFFD7C0E2, {
      'highlight': Color(0xFFD7C0E2),
      'splash': Color(0xFFCA90E5),
    }),
    ColorSwatch(0xFFCE9A9A, {
      'highlight': Color(0xFFCE9A9A),
      'splash': Color(0xFFF94D56),
      'error': Color(0xFF912D2D),
    }),
  ];

  Future<void> _retrieveFromLocal() async {
    final json = DefaultAssetBundle.of(context)
        .loadString('assests/data/regular_units.json');

    final decoder = JsonDecoder();
    final data = decoder.convert(await json);

    var categoryIndex = 0;

    for (var key in data.keys) {
      if (data is! Map) {
        throw('Data is not a Map');
      }

      List<Unit> units = data[key].map<Unit>((units) => Unit.fromJson(units)).toList();

      var category = Category(
          key,
          _baseColors[categoryIndex],
          Icons.cake,
          units
      );

      setState(() {
        _categoryList.add(category);

        if (categoryIndex == 0) _currentCategory = category;
      });

      categoryIndex++;
    }
  }

  Future<void> _retrieveApiCategory() async {
    final api = Api();
    final router = api.router;
    final jsonUnits = await api.getUnits(router['route']);
    final units = <Unit>[];

    if (jsonUnits != null) {
      for (var unit in jsonUnits) {
        units.add(Unit.fromJson(unit));
      }
    }

    setState(() {
      _categoryList.add(Category(
        router['name'],
        _baseColors.last,
        Icons.cake,
        units,
      ));
    });
  }

  List<Unit> _retrieveUnitList(String categoryName) {

    return List.generate(10, (int i) {
      i += 1;
      return Unit(
        name: '$categoryName Unit $i',
        conversion: i.toDouble(),
      );
    });
  }

  AppBar _createAppBar(String title) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(fontSize: 30.0, color: Colors.black),
        textAlign: TextAlign.center,
      ),
      elevation: 0.0,
      backgroundColor: _currentCategory.color,
    );
  }

  void _onMenuTap(Category category) {
    setState(() {
      _currentCategory = category;
    });
  }

  Widget _buildMenu(Orientation orientation) {
    if (orientation == Orientation.portrait) {
      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        itemCount: _categoryList.length,
        itemBuilder: (BuildContext context, int index) =>
            CategoryTile(
                category: _categoryList[index],
                onTap: _onMenuTap,
            ),
      );
    } else {
      return GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 3,
        children: _categoryList.map((Category category) {
          return  CategoryTile(
              category: category,
              onTap: _onMenuTap
          );
        }).toList(),
      );
    }

  }

  @override
  Future<void> didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();

    if (_categoryList.isEmpty) {
      await _retrieveFromLocal();
      await _retrieveApiCategory();
    }
  }

  @override
  Widget build(BuildContext context) {

    if (_categoryList.isEmpty) {
      return Center(
        child: Container(
          height: 180.0,
          width: 180.0,
          child: CircularProgressIndicator(),
        ),
      );
    }

    final listView = Container(
      padding: EdgeInsets.only(bottom: 48.0),
      child: _buildMenu(MediaQuery.of(context).orientation)
    );

    return Backdrop(
        currentCategory: _currentCategory == null ? _categoryList[0] : _currentCategory,
        frontPanel: UnitConverter(category: _currentCategory),
        backPanel: listView,
        frontTitle: Text('Unit Converter'),
        backTitle: Text('Select a Category')
    );
  }
}
