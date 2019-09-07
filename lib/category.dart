import 'package:flutter/material.dart';
import 'unit.dart';

class Category {
  final String name;
  final ColorSwatch color;
  final IconData iconLocation;
  final List<Unit> units;

  const Category(
    this.name,
    this.color,
    this.iconLocation,
    this.units
  );
}