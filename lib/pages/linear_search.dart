
import 'package:flutter/material.dart';
import 'dart:async';

class LinearSearchPage extends StatefulWidget {
  final String algorithmName;

  const LinearSearchPage({super.key, required this.algorithmName});

  @override
  State<LinearSearchPage> createState() => _LinearSearchPageState();
}

class _LinearSearchPageState extends State<LinearSearchPage> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();

  List<int> _array = [];
  int _target = 0;
  bool _isPlaying = false;
  bool _isPaused = false;
  bool _isVisualizationStarted = false;

  int _currentIndex = -1;
  int _foundIndex = -1;
  bool _searchCompleted = false;
  Timer? _visualizationTimer;

  @override
  void initState() {
    super.initState();
    _inputController.text = "19,3,11,7,15,9,1,17,5,13";
    _targetController.text = "7";
  }

  @override
  void dispose() {
    _inputController.dispose();
    _targetController.dispose();
    _visualizationTimer?.cancel();
    super.dispose();
  }

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
      _array = parsedArray;
      _target = targetValue;
      _isVisualizationStarted = true;
      _resetSearchState();
    });
  }

  void _resetSearchState() {
    _isPlaying = false;
    _isPaused = false;
    _currentIndex = -1;
    _foundIndex = -1;
    _searchCompleted = false;
    _visualizationTimer?.cancel();
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
    _visualizationTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (!_isPlaying) {
        timer.cancel();
        return;
      }
      _performStep();
    });
  }

  void _performStep() {
    if (_searchCompleted) return;

    setState(() {
      if (_currentIndex < _array.length - 1) {
        _currentIndex++;
        if (_array[_currentIndex] == _target) {
          _foundIndex = _currentIndex;
          _searchCompleted = true;
          _isPlaying = false;
          _visualizationTimer?.cancel();
        }
      } else {
        _searchCompleted = true;
        _isPlaying = false;
        _visualizationTimer?.cancel();
      }
    });
  }

  Future<void> _nextStep() async {
    if (_isPlaying || _searchCompleted) return;
    _performStep();
  }

  void _reset() {
    setState(() {
      _resetSearchState();
    });
  }

  Color _getElementColor(int index) {
    if (_foundIndex != -1 && index == _foundIndex) {
      return Colors.green[400]!; // Found
    } else if (index == _currentIndex) {
      return Colors.orange[400]!; // Current
    } else if (index < _currentIndex) {
      return Colors.grey[400]!; // Checked
    } else {
      return Colors.blue[300]!; // Unchecked
    }
  }

  String _getStatusMessage() {
    if (_foundIndex != -1) {
      return 'Target $_target found at index $_foundIndex!';
    } else if (_searchCompleted) {
      return 'Target $_target not found in the array.';
    } else if (_currentIndex != -1) {
      return 'Checking index $_currentIndex...';
    } else {
      return 'Ready to search for $_target.';
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
                          hintText: 'Enter numbers (e.g., 19,3,11,7)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.list),
                          labelText: 'Array',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _targetController,
                        decoration: InputDecoration(
                          hintText: 'Enter target number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.search),
                          labelText: 'Target',
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
                          'Visualize Search',
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
            if (_isVisualizationStarted) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      _buildLegendItem(Colors.orange[400]!, 'Checking'),
                      _buildLegendItem(Colors.grey[400]!, 'Checked'),
                      _buildLegendItem(Colors.green[400]!, 'Found'),
                      _buildLegendItem(Colors.blue[300]!, 'Unchecked'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
                                color: index == _currentIndex
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
                        onPressed: _searchCompleted || _isPlaying ? null : _nextStep,
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
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isVisualizationStarted = false;
                    _array.clear();
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
