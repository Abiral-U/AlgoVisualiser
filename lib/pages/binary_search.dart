import 'package:flutter/material.dart';
import 'dart:async';

class BinarySearchPage extends StatefulWidget {
  final String algorithmName;

  const BinarySearchPage({super.key, required this.algorithmName});

  @override
  State<BinarySearchPage> createState() => _BinarySearchPageState();
}

class _BinarySearchPageState extends State<BinarySearchPage> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();

  List<int> _array = [];
  List<int> _originalArray = [];
  int _target = 0;
  bool _isPlaying = false;
  bool _isPaused = false;
  bool _isVisualizationStarted = false;

  // Binary Search specific state
  int _low = -1;
  int _high = -1;
  int _mid = -1;
  int _foundIndex = -1;
  final List<Map<String, int>> _searchHistory = [];
  int _currentStep = 0;
  bool _searchCompleted = false;
  Timer? _visualizationTimer;

  @override
  void initState() {
    super.initState();
    _inputController.text = "1,3,5,7,9,11,13,15,17,19";
    _targetController.text = "7";
  }

  @override
  void dispose() {
    _inputController.dispose();
    _targetController.dispose();
    _visualizationTimer?.cancel();
    super.dispose();
  }

  // Parse input string to integer array
  List<int> _parseInput(String input) {
    try {
      return input
          .split(',')
          .map((e) => int.parse(e.trim()))
          .where((e) => e >= 0 && e <= 100)
          .toList();
    } catch (e) {
      return [];
    }
  }

  void _startVisualization() {
    final parsedArray = _parseInput(_inputController.text);
    final targetValue = int.tryParse(_targetController.text.trim());

    if (parsedArray.isEmpty || targetValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter valid integers (0-100, comma-separated) and a target number',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _array = List.from(parsedArray);
      _originalArray = List.from(parsedArray);
      _array.sort(); // Ensure array is sorted for binary search
      _target = targetValue;
      _isVisualizationStarted = true;
      _resetSearchState();
      _performBinarySearch();
    });
  }

  void _resetSearchState() {
    _isPlaying = false;
    _isPaused = false;
    _currentStep = 0;
    _low = -1;
    _high = -1;
    _mid = -1;
    _foundIndex = -1;
    _searchCompleted = false;
    _searchHistory.clear();
    _visualizationTimer?.cancel();
  }

  void _performBinarySearch() {
    int low = 0;
    int high = _array.length - 1;

    while (low <= high) {
      int mid = (low + (high - low) / 2).floor();
      _searchHistory.add({'low': low, 'high': high, 'mid': mid});

      if (_array[mid] == _target) {
        _foundIndex = mid;
        return;
      } else if (_array[mid] < _target) {
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }
  }

  void _togglePlayPause() {
    if (_searchCompleted) return;

    if (_isPlaying) {
      setState(() {
        _isPlaying = false;
        _isPaused = true;
      });
      _visualizationTimer?.cancel();
    } else {
      setState(() {
        _isPlaying = true;
        _isPaused = false;
      });
      _runVisualization();
    }
  }

  void _runVisualization() {
    if (_searchHistory.isEmpty) {
      setState(() {
        _isPlaying = false;
        _searchCompleted = true;
      });
      return;
    }

    _visualizationTimer = Timer.periodic(const Duration(milliseconds: 1000), (
      timer,
    ) {
      if (!_isPlaying || _currentStep >= _searchHistory.length) {
        timer.cancel();
        setState(() {
          _isPlaying = false;
          _searchCompleted = true;
        });
        return;
      }

      setState(() {
        final step = _searchHistory[_currentStep];
        _low = step['low']!;
        _high = step['high']!;
        _mid = step['mid']!;
        _currentStep++;
      });
    });
  }

  Future<void> _nextStep() async {
    if (_searchCompleted || _currentStep >= _searchHistory.length) return;

    setState(() {
      final step = _searchHistory[_currentStep];
      _low = step['low']!;
      _high = step['high']!;
      _mid = step['mid']!;
      _currentStep++;

      if (_currentStep >= _searchHistory.length) {
        _searchCompleted = true;
        _isPlaying = false;
      }
    });
  }

  void _reset() {
    setState(() {
      if (_originalArray.isNotEmpty) {
        _array = List.from(_originalArray);
        _array.sort();
      }
      _resetSearchState();
      // Regenerate search history for the current target
      if (_array.isNotEmpty) {
        _performBinarySearch();
      }
    });
  }

  // Get color for array element based on its state
  Color _getElementColor(int index) {
    if (_foundIndex != -1 && index == _foundIndex) {
      return Colors.green[400]!; // Found - green
    } else if (index == _mid && _mid != -1) {
      return Colors.orange[400]!; // Mid point - orange
    } else if (index >= _low && index <= _high && _low != -1 && _high != -1) {
      return Colors.blue[300]!; // Search range - light blue
    } else {
      return Colors.grey[300]!; // Out of range - grey
    }
  }

  String _getStatusMessage() {
    if (_foundIndex != -1) {
      return 'Target $_target found at index $_foundIndex!';
    } else if (_searchCompleted) {
      return 'Target $_target not found in the array';
    } else if (_currentStep < _searchHistory.length) {
      return 'Step ${_currentStep + 1} - Searching range: $_low to $_high, checking mid: $_mid';
    } else {
      return 'Ready to search for $_target';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          '${widget.algorithmName} Visualization',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.deepPurple,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Search Configuration',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _inputController,
                        decoration: InputDecoration(
                          hintText: 'Enter sorted numbers (e.g., 1,3,5,7,9)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.list),
                          labelText: 'Sorted Array',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _targetController,
                        decoration: InputDecoration(
                          hintText: 'Enter target number to find',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.search),
                          labelText: 'Target Number',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _startVisualization,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Start Search',
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _foundIndex != -1
                      ? Colors.green[100]
                      : _searchCompleted
                      ? Colors.red[100]
                      : Colors.blue[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _foundIndex != -1
                        ? Colors.green[300]!
                        : _searchCompleted
                        ? Colors.red[300]!
                        : Colors.blue[300]!,
                  ),
                ),
                child: Text(
                  _getStatusMessage(),
                  style: TextStyle(
                    color: _foundIndex != -1
                        ? Colors.green[800]
                        : _searchCompleted
                        ? Colors.red[800]
                        : Colors.blue[800],
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              // Legend
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildLegendItem(Colors.orange[400]!, 'Mid'),
                      _buildLegendItem(Colors.blue[300]!, 'Range'),
                      _buildLegendItem(Colors.green[400]!, 'Found'),
                      _buildLegendItem(Colors.grey[300]!, 'Excluded'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

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
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                            width: 60,
                            height: 80,
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
                              border: Border.all(
                                color: index == _mid && _mid != -1
                                    ? Colors.orange[700]!
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${_array[index]}',
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$index',
                                  style: const TextStyle(
                                    color: Colors.black54,
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
                        onPressed: _searchCompleted ? null : _togglePlayPause,
                        icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                        label: Text(_isPlaying ? 'Pause' : 'Play'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isPlaying
                              ? Colors.orange[600]
                              : Colors.green[600],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _searchCompleted || _isPlaying
                            ? null
                            : _nextStep,
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

              // New search button
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isVisualizationStarted = false;
                    _array.clear();
                    _originalArray.clear();
                    _resetSearchState();
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
                child: const Text('New Search'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
