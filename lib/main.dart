import 'package:flutter/material.dart';
import 'package:myapp/database_helper.dart'; // Import the database helper

import 'bmi_history_screen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI Calculator',
      theme: ThemeData(
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  String _selectedGender = 'Male';
  bool _isMetric = true; // true for metric (cm/kg), false for imperial (inches/lbs)

  double _heightInMeters = 0.0;
  double _weightInKilograms = 0.0;
  double _bmiResult = 0.0;
  String _bmiCategory = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('BMI Calculator'),
        actions: <Widget>[
          TextButton(
            child: const Text('History', style: TextStyle(color: Colors.black)),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => BmiHistoryScreen()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Please enter a valid age';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: <String>['Male', 'Female', 'Other'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedGender = newValue!;
                  });
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _heightController,
                      decoration: InputDecoration(
                          labelText: 'Height (${_isMetric ? 'cm' : 'inches'})'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your height';
                        }
                        if (double.tryParse(value) == null ||
                            double.parse(value) <= 0) {
                          return 'Please enter a valid height';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  ToggleButtons(
                    isSelected: [_isMetric, !_isMetric],
                    onPressed: (index) {
                      setState(() {
                        _isMetric = index == 0;

                      });
                    },
                    children: const <Widget>[
                      Text('cm/kg'),
                      Text('inches/lbs'),
                    ],
                  ),
                ],
              ),
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                    labelText: 'Weight (${_isMetric ? 'kg' : 'lbs'})'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your weight';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Please enter a valid weight';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Process data and calculate BMI
                    final double height = double.parse(_heightController.text);
                    final double weight = double.parse(_weightController.text);

                    if (_isMetric) {
                      _heightInMeters = height / 100.0; // cm to meters
                      _weightInKilograms = weight;
                    } else {
                      _heightInMeters = height * 0.0254; // inches to meters
                      _weightInKilograms = weight * 0.453592; // lbs to kg
                    }

                    // Calculate BMI
                    if (_heightInMeters > 0) {
                      _bmiResult = _weightInKilograms / (_heightInMeters * _heightInMeters);
                      print('Calculated BMI: $_bmiResult');

                      // Determine BMI category
                      if (_bmiResult < 18.5) {
                        _bmiCategory = 'Underweight';
                      } else if (_bmiResult >= 18.5 && _bmiResult < 25) {
                        _bmiCategory = 'Normal';
                      } else if (_bmiResult >= 25 && _bmiResult < 30) {
                        _bmiCategory = 'Overweight';
                      } else {
                        _bmiCategory = 'Obese';
                      }

// Save BMI record to the database
                    final bmiRecord = {
                      'name': _nameController.text,
                      'age': int.parse(_ageController.text),
                      'gender': _selectedGender,
                      'height': height,
                      'weight': weight,
                      'bmi': _bmiResult,
                      'date': DateTime.now().toIso8601String(), // Store current date and time
                    };


                      setState(() {
                        DatabaseHelper().insertBmiRecord(bmiRecord);
                        // Update the UI to show the result
                      });
                    } else {
                      // Handle case where height is zero or negative (should be caught by validation, but as a safeguard)
                    }
                  }
                },
                child: const Text('Calculate BMI'),
              ),
              const SizedBox(height: 24.0),
              if (_bmiResult > 0) // Only show result if BMI is calculated
                Card(
                  color: _getCategoryColor(_bmiCategory),
                  elevation: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your BMI:',
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          _bmiResult.toStringAsFixed(2), // Display BMI with 2 decimal places
                          style: const TextStyle(
                              fontSize: 24.0, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Category: $_bmiCategory',
                          style: const TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _getCategoryColor(String category) {
  switch (category) {
    case 'Underweight':
      return Colors.blue.shade200;
    case 'Normal':
      return Colors.green.shade200;
    case 'Overweight':
      return Colors.orange.shade200;
    case 'Obese':
      return Colors.red.shade200;
    default:
      return Colors.grey.shade200;
  }
}

