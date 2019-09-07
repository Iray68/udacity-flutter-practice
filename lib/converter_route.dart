import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'unit.dart';

class ConverterRoute extends StatefulWidget {
  final ColorSwatch color;
  final List<Unit> units;

  const ConverterRoute({
    @required this.color,
    @required this.units,
  }) : assert(color != null), assert(units != null);

  @override
  _ConverterRouteState createState() => _ConverterRouteState();
}

class _ConverterRouteState extends State<ConverterRoute> {
  final EdgeInsets _padding = EdgeInsets.all(16.0);

  Unit _dropDownInput;
  Unit _dropDownOutput;
  List<DropdownMenuItem<String>> units;
  String _inputText;
  String _outputText;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    setState(() {
      _dropDownInput = widget.units[0];
      _dropDownOutput = widget.units[1];
      units = widget.units.map<DropdownMenuItem<String>>((Unit unit) {
        return DropdownMenuItem<String>(
          value: unit.name,
          child: Text(unit.name),
        );
      }).toList();
      _inputText = '';
      _outputText = '';
    });
  }

  bool _formatValidator() {
    if (_inputText.isEmpty) return true;

    RegExp exp = new RegExp('[0-9]+');
    return exp.hasMatch(_inputText);
  }

  String _format(double conversion) {
    var outputNum = conversion.toStringAsPrecision(7);
    if (outputNum.contains('.') && outputNum.endsWith('0')) {
      var i = outputNum.length - 1;
      while (outputNum[i] == '0') {
        i -= 1;
      }
      outputNum = outputNum.substring(0, i + 1);
    }
    if (outputNum.endsWith('.')) {
      return outputNum.substring(0, outputNum.length - 1);
    }
    return outputNum;
  }

  Widget _createTextField() {
    return TextField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          labelText: 'Input',
          errorText: _formatValidator() ? null : 'Invalid Number',
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(0.0)
          )
      ),
      style: Theme.of(context).textTheme.display1,
      onChanged: (value) {
        setState(() {
          _inputText = value;
          _convertOutput();
        });
      },
    );
  }

  void _updateDropDownInput(newValue) {
    setState(() {
      _dropDownInput = _getUnit(newValue);
    });

    if (_inputText.isNotEmpty) {
      _convertOutput();
    }

  }

  void _updateDropDownOutput(newValue) {
    setState(() {
      _dropDownOutput = _getUnit(newValue);
    });

    if (_inputText.isNotEmpty) {
      _convertOutput();
    }

  }

  void _convertOutput() {
    setState(() {
      _outputText = _format(double.parse(_inputText) *
          (_dropDownOutput.conversion / _dropDownInput.conversion));
    });
  }

  Widget _createDropDown(Unit dropDownValue, updateDropDown) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.0)
            )
        ),
        value: dropDownValue.name,
        onChanged: (newValue) => updateDropDown(newValue),
        items: units,
      ),
    );
  }

  Unit _getUnit(String unitName) {
    return widget.units.firstWhere(
          (Unit unit) => unit.name == unitName, orElse: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final input = Padding(
        padding: _padding,
        child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _createTextField(),
                _createDropDown(_dropDownInput, _updateDropDownInput)
              ],
            )
        ),
    );

    final arrows = RotatedBox(
      quarterTurns: 1,
      child: Icon(
        Icons.compare_arrows,
        size: 40.0,
      ),
    );

    final output = Padding(
      padding: _padding,
      child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              InputDecorator(
                child: Text(
                    _outputText,
                    style: Theme.of(context).textTheme.display1
                ),
                decoration: InputDecoration(
                    labelText: 'Output',
                    labelStyle: Theme.of(context).textTheme.display1,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0.0)
                    )
                ),
              ),
              _createDropDown(_dropDownOutput, _updateDropDownOutput)
            ],
          )
      ),
    );

    final wrapper = Column(
      children: <Widget>[
        input,
        arrows,
        output
      ],
    );

    return wrapper;
  }

}