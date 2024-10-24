// import 'dart:async';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'databasehelper.dart';  // Import the DatabaseHelper

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Aquarium',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
//         useMaterial3: true,
//       ),
//       home: const MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key});

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
//   final Random _random = Random();
//   List<Fish> _fishList = [];
//   double _speed = 500;
//   Color _selectedColor = Colors.blue;
//   int _fishCount = 5;
//   static const int _maxFishCount = 10;

//   List<Color> fishColors = [
//     Colors.blue,
//     Colors.red,
//     Colors.green,
//     Colors.yellow,
//     Colors.orange
//   ];

//   late DatabaseHelper _dbHelper;

//   @override
//   void initState() {
//     super.initState();
//     _dbHelper = DatabaseHelper(); // Initialize DatabaseHelper
//     _loadSettings(); // Load settings from SQLite
//     _initializeFish();
//   }

//   // Load settings from SQLite
//   Future<void> _loadSettings() async {
//     var settings = await _dbHelper.loadSettings();
//     setState(() {
//       if (settings != null) {
//         _fishCount = settings['fishCount'] ?? 5;
//         _speed = settings['speed'] ?? 500;
//         _selectedColor = Color(settings['color'] ?? Colors.blue.value);

//         if (!fishColors.contains(_selectedColor)) {
//           _selectedColor = fishColors[0];
//         }
//       }
//     });
//   }

//   // Save settings to SQLite
//   Future<void> _saveSettings() async {
//     await _dbHelper.saveSettings(_fishList.length, _speed, _selectedColor.value);
//   }

//   void _initializeFish() {
//     for (int i = 0; i < _fishCount; i++) {
//       _fishList.add(Fish(
//         color: _selectedColor,
//         controller: AnimationController(
//           vsync: this,
//           duration: Duration(milliseconds: (_speed * 4).toInt()),
//         ),
//       ));
//     }

//     _fishList.forEach((fish) {
//       fish.initializePosition(_random);
//       fish.startAnimation(_random, _onFishMove);
//     });
//   }

//   void _addFish() {
//     if (_fishList.length < _maxFishCount) {
//       setState(() {
//         Fish newFish = Fish(
//           color: _selectedColor,
//           controller: AnimationController(
//             vsync: this,
//             duration: Duration(milliseconds: (_speed * 4).toInt()),
//           ),
//         );
//         newFish.initializePosition(_random);
//         newFish.startAnimation(_random, _onFishMove);
//         _fishList.add(newFish);
//       });
//       _saveSettings();  // Save settings whenever a fish is added
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Maximum of 10 fish allowed!')),
//       );
//     }
//   }

//   void _removeFish() {
//     if (_fishList.isNotEmpty) {
//       setState(() {
//         _fishList.last.controller.dispose();
//         _fishList.removeLast();
//       });
//       _saveSettings();  // Save settings whenever a fish is removed
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('No fish to remove!')),
//       );
//     }
//   }

//   void _onFishMove(Fish fish) {
//     setState(() {
//       if (fish.x < 0 || fish.x > 270) {
//         fish.dx = -fish.dx;
//       }

//       if (fish.y < 0 || fish.y > 270) {
//         fish.dy = -fish.dy;
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Aquarium'),
//       ),
//       body: Column(
//         children: [
//           Center(
//             child: Container(
//               width: 300,
//               height: 300,
//               decoration: BoxDecoration(
//                 color: Colors.blueAccent[100],
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(
//                   color: Colors.blue,
//                   width: 2,
//                 ),
//               ),
//               child: Stack(
//                 children: _fishList.map((fish) {
//                   return AnimatedBuilder(
//                     animation: fish.controller,
//                     builder: (context, child) {
//                       return Positioned(
//                         left: fish.x,
//                         top: fish.y,
//                         child: fishWidget(fish.color),
//                       );
//                     },
//                   );
//                 }).toList(),
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           Text('Fish Speed: ${_speed.toInt()} ms'),
//           Slider(
//             value: _speed,
//             min: 100,
//             max: 2000,
//             divisions: 19,
//             label: _speed.round().toString(),
//             onChanged: (value) {
//               setState(() {
//                 _speed = value;
//               });
//               _saveSettings();
//             },
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text('Fish Color: '),
//               DropdownButton<Color>(
//                 value: _selectedColor,
//                 icon: const Icon(Icons.arrow_downward),
//                 items: fishColors.map((Color color) {
//                   return DropdownMenuItem<Color>(
//                     value: color,
//                     child: Container(
//                       width: 30,
//                       height: 30,
//                       color: color,
//                     ),
//                   );
//                 }).toList(),
//                 onChanged: (Color? newColor) {
//                   setState(() {
//                     _selectedColor = newColor!;
//                   });
//                   _saveSettings();
//                 },
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: _saveSettings,
//             child: const Text('Save Settings'),
//           ),
//         ],
//       ),
//       floatingActionButton: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           FloatingActionButton(
//             onPressed: _addFish,
//             tooltip: 'Add Fish',
//             child: const Icon(Icons.add),
//           ),
//           const SizedBox(height: 10),
//           FloatingActionButton(
//             onPressed: _removeFish,
//             tooltip: 'Remove Fish',
//             child: const Icon(Icons.remove),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget fishWidget(Color color) {
//     return Container(
//       width: 30,
//       height: 30,
//       decoration: BoxDecoration(
//         color: color,
//         shape: BoxShape.circle,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     for (var fish in _fishList) {
//       fish.controller.dispose();
//     }
//     super.dispose();
//   }
// }

// class Fish {
//   double x = 0;
//   double y = 0;
//   double dx = 1;
//   double dy = 1;
//   final Color color;
//   final AnimationController controller;

//   Fish({required this.color, required this.controller});

//   void initializePosition(Random random) {
//     x = random.nextDouble() * 250;
//     y = random.nextDouble() * 250;
//     dx = random.nextDouble() * 2 - 1;
//     dy = random.nextDouble() * 2 - 1;
//   }

//   void startAnimation(Random random, Function(Fish) onMove) {
//     controller.repeat();
//     controller.addListener(() {
//       x += dx;
//       y += dy;
//       onMove(this);
//     });
//   }
// }

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'databasehelper.dart'; // Import the DatabaseHelper

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Aquarium',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final Random _random = Random();
  List<Fish> _fishList = [];
  double _speed = 500;
  Color _selectedColor = Colors.blue;
  int _fishCount = 5;
  static const int _maxFishCount = 10;

  bool _collisionEffectsEnabled = true; // Toggle for collision effects

  List<Color> fishColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.yellow,
    Colors.orange
  ];

  late DatabaseHelper _dbHelper;

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper(); // Initialize DatabaseHelper
    _loadSettings(); // Load settings from SQLite
    _initializeFish();
  }

  // Load settings from SQLite
  Future<void> _loadSettings() async {
    var settings = await _dbHelper.loadSettings();
    setState(() {
      if (settings != null) {
        _fishCount = settings['fishCount'] ?? 5;
        _speed = settings['speed'] ?? 500;
        _selectedColor = Color(settings['color'] ?? Colors.blue.value);

        if (!fishColors.contains(_selectedColor)) {
          _selectedColor = fishColors[0];
        }
      }
    });
  }

  // Save settings to SQLite
  Future<void> _saveSettings() async {
    await _dbHelper.saveSettings(
        _fishList.length, _speed, _selectedColor.value);
  }

  // Initialize fish with scaling effect
  void _initializeFish() {
    for (int i = 0; i < _fishCount; i++) {
      Fish newFish = Fish(
        color: _selectedColor,
        controller: AnimationController(
          vsync: this,
          duration: Duration(milliseconds: (_speed * 4).toInt()),
        ),
        scaleController: AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 500),
        ),
      );

      _fishList.add(newFish);
      newFish.initializePosition(_random);
      newFish.startAnimation(_random, _onFishMove);

      // Start scaling effect
      newFish.scaleController.forward(from: 0).then((_) {
        newFish.scaleController.reverse();
      });
    }
  }

  // Add a fish with scaling effect
  void _addFish() {
    if (_fishList.length < _maxFishCount) {
      setState(() {
        Fish newFish = Fish(
          color: _selectedColor,
          controller: AnimationController(
            vsync: this,
            duration: Duration(milliseconds: (_speed * 4).toInt()),
          ),
          scaleController: AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 500),
          ),
        );
        newFish.initializePosition(_random);
        newFish.startAnimation(_random, _onFishMove);
        _fishList.add(newFish);

        // Start scaling effect
        newFish.scaleController.forward(from: 0).then((_) {
          newFish.scaleController.reverse();
        });
        _saveSettings(); // Save updated fish count
      });
    }
  }

  // Remove a fish
  void _removeFish() {
    if (_fishList.isNotEmpty) {
      setState(() {
        _fishList.removeLast().controller.dispose();
        _saveSettings(); // Save updated fish count
      });
    }
  }

  Future<void> saveSettings() async {}

  // Collision and movement logic
  void _onFishMove(Fish fish) {
    setState(() {
      if (_collisionEffectsEnabled) {
        // Check for collisions with other fish
        for (var otherFish in _fishList) {
          if (fish != otherFish && _isColliding(fish, otherFish)) {
            _changeFishDirection(fish);
            _changeFishDirection(otherFish);

            // Random color change on collision
            Color randomColor = fishColors[_random.nextInt(fishColors.length)];
            fish.color = randomColor;
            otherFish.color = randomColor;
          }
        }
      }

      // Bounce fish off aquarium walls
      if (fish.xPosition < 0 || fish.xPosition > 270) {
        fish.dx = -fish.dx;
      }
      if (fish.yPosition < 0 || fish.yPosition > 270) {
        fish.dy = -fish.dy;
      }
    });
  }

  // Check if two fish collide
  bool _isColliding(Fish fish1, Fish fish2) {
    double dx = fish1.xPosition - fish2.xPosition;
    double dy = fish1.yPosition - fish2.yPosition;
    double distance = sqrt(dx * dx + dy * dy);
    return distance < 24; // Assuming fish are 24x24 in size
  }

  // Change fish direction randomly
  void _changeFishDirection(Fish fish) {
    fish.dx = _random.nextDouble() * 2 - 1;
    fish.dy = _random.nextDouble() * 2 - 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aquarium'),
      ),
      body: Column(
        children: [
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.blueAccent[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.blue,
                  width: 2,
                ),
              ),
              child: Stack(
                children: _fishList.map((fish) {
                  return AnimatedBuilder(
                    animation: fish.controller,
                    builder: (context, child) {
                      return Positioned(
                        left: fish.xPosition,
                        top: fish.yPosition,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 1.5, end: 1).animate(
                            CurvedAnimation(
                              parent: fish.scaleController,
                              curve: Curves.easeOut,
                            ),
                          ),
                          child: fishWidget(fish.color),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Fish Speed: ${_speed.toInt()} ms'),
          Slider(
            value: _speed,
            min: 100,
            max: 2000,
            divisions: 19,
            label: _speed.round().toString(),
            onChanged: (value) {
              setState(() {
                _speed = value;
                _fishList.forEach((fish) {
                  fish.controller.duration =
                      Duration(milliseconds: (_speed * 4).toInt());
                });
              });
              _saveSettings();
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Fish Color: '),
              DropdownButton<Color>(
                value: _selectedColor,
                icon: const Icon(Icons.arrow_downward),
                items: fishColors.map((Color color) {
                  return DropdownMenuItem<Color>(
                    value: color,
                    child: Container(
                      width: 30,
                      height: 30,
                      color: color,
                    ),
                  );
                }).toList(),
                onChanged: (Color? newColor) {
                  setState(() {
                    _selectedColor = newColor!;
                    _fishList.forEach((fish) {
                      fish.color = _selectedColor;
                    });
                  });
                  _saveSettings();
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Enable Collision Effects'),
              Switch(
                value: _collisionEffectsEnabled,
                onChanged: (value) {
                  setState(() {
                    _collisionEffectsEnabled = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _addFish,
            tooltip: 'Add Fish',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _removeFish,
            tooltip: 'Remove Fish',
            child: const Icon(Icons.remove),
          ),
          FloatingActionButton(
            onPressed: _saveSettings,
            tooltip: 'save',
            child: const Text('save'),
          ),
        ],
      ),
    );
  }

  Widget fishWidget(Color color) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  void dispose() {
    for (var fish in _fishList) {
      fish.controller.dispose();
      fish.scaleController.dispose();
    }
    super.dispose();
  }
}

class Fish {
  late Color color;
  late AnimationController controller;
  late AnimationController scaleController;
  late double xPosition;
  late double yPosition;
  late double dx;
  late double dy;

  Fish({
    required this.color,
    required this.controller,
    required this.scaleController,
  });

  void initializePosition(Random random) {
    xPosition = random.nextDouble() * 270;
    yPosition = random.nextDouble() * 270;
    dx = random.nextDouble() * 2 - 1;
    dy = random.nextDouble() * 2 - 1;
  }

  void startAnimation(Random random, Function(Fish) onMove) {
    controller.repeat();
    controller.addListener(() {
      xPosition += dx;
      yPosition += dy;
      onMove(this);
    });
  }
}
