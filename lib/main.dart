import 'package:flutter/material.dart';
import 'package:myapp/database_helper.dart'; // Your DB helper
import 'package:google_fonts/google_fonts.dart';
import 'bmi_history_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI Calculator',
      theme: ThemeData(
        primaryColor: Colors.teal,
        textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme),
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.tealAccent),
      ),
      home: const MyHomePage(title: 'BMI Calculator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
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
  bool _isMetric = true;

  double _heightInMeters = 0.0;
  double _weightInKilograms = 0.0;
  double _bmiResult = 0.0;
  String _bmiCategory = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        title: const Text('BMI Calculator', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            child: const Text('History', style: TextStyle(color: Colors.white)),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const BmiHistoryScreen()));
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your name';
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your age';
                    if (int.tryParse(value) == null || int.parse(value) <= 0) return 'Please enter a valid age';
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                  items: ['Male', 'Female', 'Other'].map((gender) {
                    return DropdownMenuItem(value: gender, child: Text(gender));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedGender = val);
                    }
                  },
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Height (${_isMetric ? 'cm' : 'inches'})',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Enter height';
                          if (double.tryParse(value) == null || double.parse(value) <= 0) {
                            return 'Enter valid height';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    ToggleButtons(
                      isSelected: [_isMetric, !_isMetric],
                      onPressed: (index) {
                        setState(() {
                          _isMetric = index == 0;
                        });
                      },
                      children: const [Text('cm/kg'), Text('inches/lbs')],
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Weight (${_isMetric ? 'kg' : 'lbs'})',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Enter weight';
                    if (double.tryParse(value) == null || double.parse(value) <= 0) {
                      return 'Enter valid weight';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final double height = double.parse(_heightController.text);
                      final double weight = double.parse(_weightController.text);

                      _heightInMeters = _isMetric ? height / 100 : height * 0.0254;
                      _weightInKilograms = _isMetric ? weight : weight * 0.453592;

                      if (_heightInMeters > 0) {
                        _bmiResult = _weightInKilograms / (_heightInMeters * _heightInMeters);

                        if (_bmiResult < 18.5) {
                          _bmiCategory = 'Underweight';
                        } else if (_bmiResult < 25) {
                          _bmiCategory = 'Normal';
                        } else if (_bmiResult < 30) {
                          _bmiCategory = 'Overweight';
                        } else {
                          _bmiCategory = 'Obese';
                        }

                        final bmiRecord = {
                          'name': _nameController.text,
                          'age': int.parse(_ageController.text),
                          'gender': _selectedGender,
                          'height': height,
                          'weight': weight,
                          'bmi': _bmiResult,
                          'date': DateTime.now().toIso8601String(),
                        };

                        DatabaseHelper().insertBmiRecord(bmiRecord);

                        setState(() {});
                      }
                    }
                  },
                  child: const Text(
    'Calculate BMI',
    style: TextStyle(color: Colors.white), // 👈 Change text color here
  ),
                ),
                const SizedBox(height: 24.0),
                if (_bmiResult > 0)
                  Card(
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    margin: const EdgeInsets.symmetric(vertical: 16.0),
                    color: _getCategoryColor(_bmiCategory),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Your BMI:',
                            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            _bmiResult.toStringAsFixed(2),
                            style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Category: $_bmiCategory',
                            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
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
