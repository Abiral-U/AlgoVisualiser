import 'package:flutter/material.dart';

class VisualizationPage extends StatefulWidget {
  final String algorithmName;

  const VisualizationPage({
    Key? key,
    required this.algorithmName,
  }) : super(key: key);

  @override
  State<VisualizationPage> createState() => _VisualizationPageState();
}

class _VisualizationPageState extends State<VisualizationPage>
    with TickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  
  List<int> _array = [];
  List<int> _originalArray = [];
  bool _isPlaying = false;
  bool _isVisualizationStarted = false;
  
  // Animation control
  int _currentStep = 0;
  int _compareIndex1 = -1;
  int _compareIndex2 = -1;
  bool _isSwapping = false;
  
  // Bubble Sort specific state
  int _bubbleSortI = 0;
  int _bubbleSortJ = 0;
  bool _bubbleSortCompleted = false;

  @override
  void initState() {
    super.initState();
    _inputController.text = "5,3,8,1,9,2,7";
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  // Parse input string to integer array
  List<int> _parseInput(String input) {
    try {
      return input
          .split(',')
          .map((e) => int.parse(e.trim()))
          .where((e) => e >= 0 && e <= 100) // Limit range for visualization
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Start visualization
  void _startVisualization() {
    final parsedArray = _parseInput(_inputController.text);
    if (parsedArray.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid integers (0-100, comma-separated)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _array = List.from(parsedArray);
      _originalArray = List.from(parsedArray);
      _isVisualizationStarted = true;
      _resetVisualizationState();
    });
  }

  // Reset visualization state
  void _resetVisualizationState() {
    _currentStep = 0;
    _compareIndex1 = -1;
    _compareIndex2 = -1;
    _isSwapping = false;
    _bubbleSortI = 0;
    _bubbleSortJ = 0;
    _bubbleSortCompleted = false;
    _isPlaying = false;
  }

  // Reset to original array
  void _reset() {
    setState(() {
      if (_originalArray.isNotEmpty) {
        _array = List.from(_originalArray);
      }
      _resetVisualizationState();
    });
  }

  // Play/Pause toggle
  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    if (_isPlaying) {
      _runVisualization();
    }
  }

  // Run visualization automatically
  Future<void> _runVisualization() async {
    while (_isPlaying && !_bubbleSortCompleted) {
      await _nextStep();
      await Future.delayed(const Duration(milliseconds: 800));
    }
    if (_bubbleSortCompleted) {
      setState(() {
        _isPlaying = false;
      });
    }
  }

  // Execute next step
  Future<void> _nextStep() async {
    if (_bubbleSortCompleted) return;
    setState(() {
      _currentStep++;
    });
    switch (widget.algorithmName) {
      case 'Bubble Sort':
        await _bubbleSortStep();
        break;
      // Add other algorithms here later
      default:
        await _bubbleSortStep();
    }
  }

  // Bubble Sort step-by-step execution
  Future<void> _bubbleSortStep() async {
    if (_bubbleSortCompleted || _array.length <= 1) return;

    // Set comparison indices only if they are valid
    if (_bubbleSortJ + 1 < _array.length - _bubbleSortI) {
      setState(() {
        _compareIndex1 = _bubbleSortJ;
        _compareIndex2 = _bubbleSortJ + 1;
      });
    } else {
        // At the end of a pass, reset comparison indices
        setState(() {
            _compareIndex1 = -1;
            _compareIndex2 = -1;
        });
    }
    
    await Future.delayed(const Duration(milliseconds: 300));

    if (_bubbleSortJ < _array.length - 1 - _bubbleSortI) {
      // Check if swap is needed
      if (_array[_bubbleSortJ] > _array[_bubbleSortJ + 1]) {
        setState(() {
          _isSwapping = true;
        });

        await Future.delayed(const Duration(milliseconds: 300));

        // Perform swap
        setState(() {
          int temp = _array[_bubbleSortJ];
          _array[_bubbleSortJ] = _array[_bubbleSortJ + 1];
          _array[_bubbleSortJ + 1] = temp;
          _isSwapping = false;
        });

        await Future.delayed(const Duration(milliseconds: 300));
      }
      // Move to next comparison
      setState(() {
         _bubbleSortJ++;
      });
    } else {
      // End of a pass
      setState(() {
        _bubbleSortJ = 0;
        _bubbleSortI++;
        if (_bubbleSortI >= _array.length - 1) {
          _bubbleSortCompleted = true;
          _compareIndex1 = -1;
          _compareIndex2 = -1;
        }
      });
    }
  }

  // Get color for array element based on its state
  Color _getElementColor(int index) {
    if (_bubbleSortCompleted) {
      return Colors.green[400]!;
    } else if (index >= _array.length - _bubbleSortI && _bubbleSortI > 0) {
      return Colors.green[300]!;
    } else if (index == _compareIndex1 || index == _compareIndex2) {
      return _isSwapping ? Colors.red[400]! : Colors.orange[400]!;
    } else {
      return Colors.blue[400]!;
    }
  }
  
  String _getStatusText() {
    if (_bubbleSortCompleted) {
      return 'Sorting Complete!';
    }
    if (_compareIndex1 != -1 && _compareIndex2 != -1) {
      return 'Step $_currentStep - Comparing positions $_compareIndex1 and $_compareIndex2';
    }
    return 'Step $_currentStep - Pass completed';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          '${widget.algorithmName} Visualization',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input section
            if (!_isVisualizationStarted) ...[
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Enter Numbers',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _inputController,
                        decoration: InputDecoration(
                          hintText: 'Enter integers separated by commas (e.g., 5,3,8,1)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.input),
                        ),
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _startVisualization,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Start Visualization',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Visualization area
            if (_isVisualizationStarted) ...[
              const SizedBox(height: 16),
              // Status indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _bubbleSortCompleted ? Colors.green[100] : Colors.blue[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _bubbleSortCompleted ? Colors.green[300]! : Colors.blue[300]!,
                  ),
                ),
                child: Text(
                  _getStatusText(),
                  style: TextStyle(
                    color: _bubbleSortCompleted ? Colors.green[800] : Colors.blue[800],
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              
              // Array visualization
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_array.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            width: 60,
                            height: _array[index] * 3.5 + 40, // Adjusted height
                            constraints: const BoxConstraints(
                              minHeight: 50, // Ensure minimum height for text
                            ),
                            decoration: BoxDecoration(
                              color: _getElementColor(index),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${_array[index]}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$index',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              
              // Control buttons
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _bubbleSortCompleted ? null : _togglePlayPause,
                        icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                        label: Text(_isPlaying ? 'Pause' : 'Play'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isPlaying ? Colors.orange[600] : Colors.green[600],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _bubbleSortCompleted || _isPlaying ? null : _nextStep,
                        icon: const Icon(Icons.skip_next),
                        label: const Text('Next'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _reset,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // New input button
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isVisualizationStarted = false;
                    _array.clear();
                    _originalArray.clear();
                    _resetVisualizationState();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Enter New Numbers'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
