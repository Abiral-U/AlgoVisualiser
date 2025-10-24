
import 'package:flutter/material.dart';
import 'dart:async';

class InsertionSortPage extends StatefulWidget {
  final String algorithmName;

  const InsertionSortPage({super.key, required this.algorithmName});

  @override
  State<InsertionSortPage> createState() => _InsertionSortPageState();
}

class _InsertionSortPageState extends State<InsertionSortPage> {
  final TextEditingController _inputController = TextEditingController();
  List<int> _array = [];
  bool _isVisualizationStarted = false;
  bool _isPlaying = false;
  bool _isPaused = false;
  bool _sortCompleted = false;
  Timer? _visualizationTimer;

  final List<Map<String, dynamic>> _history = [];
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _inputController.text = "7,2,4,1,5,3";
  }

  @override
  void dispose() {
    _inputController.dispose();
    _visualizationTimer?.cancel();
    super.dispose();
  }

  void _startVisualization() {
    final parsedArray = _parseInput(_inputController.text);
    if (parsedArray.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid, comma-separated integers (0-100).'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _array = parsedArray;
      _isVisualizationStarted = true;
      _resetSortState();
      _generateInsertionSortSteps();
    });
  }

  void _resetSortState() {
    _isPlaying = false;
    _isPaused = false;
    _sortCompleted = false;
    _currentStep = 0;
    _history.clear();
    _visualizationTimer?.cancel();
  }

  void _generateInsertionSortSteps() {
    List<int> arrayCopy = List.from(_array);
    _history.add({
      'array': List.from(arrayCopy),
      'status': 'Initial array',
      'sortedIndices': [0],
    });

    for (int i = 1; i < arrayCopy.length; i++) {
      int key = arrayCopy[i];
      int j = i - 1;

      _history.add({
        'array': List.from(arrayCopy),
        'keyIndex': i,
        'status': 'Selecting $key as the key to insert.',
        'sortedIndices': List<int>.generate(i, (k) => k),
      });

      while (j >= 0 && arrayCopy[j] > key) {
         _history.add({
          'array': List.from(arrayCopy),
          'keyIndex': i,
          'comparingIndex': j,
          'status': 'Comparing key $key with ${arrayCopy[j]}.',
          'sortedIndices': List<int>.generate(i, (k) => k),
        });

        arrayCopy[j + 1] = arrayCopy[j];
         _history.add({
          'array': List.from(arrayCopy),
          'keyIndex': i,
          'comparingIndex': j,
          'status': 'Shifting ${arrayCopy[j+1]} to the right.',
          'sortedIndices': List<int>.generate(i, (k) => k),
        });
        j = j - 1;
      }
      arrayCopy[j + 1] = key;
      _history.add({
        'array': List.from(arrayCopy),
        'keyIndex': j + 1,
        'status': 'Inserted $key at its correct position.',
        'sortedIndices': List<int>.generate(i + 1, (k) => k),
      });
    }

    _history.add({
      'array': List.from(arrayCopy),
      'status': 'Array is sorted!',
      'sortedIndices': List<int>.generate(arrayCopy.length, (k) => k),
    });
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

  void _togglePlayPause() {
    if (_sortCompleted) return;

    if (_isPlaying) {
      _visualizationTimer?.cancel();
    } else {
      _runVisualization();
    }
    setState(() {
      _isPlaying = !_isPlaying;
      _isPaused = !_isPlaying;
    });
  }

  void _runVisualization() {
    _visualizationTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (_currentStep >= _history.length - 1) {
        timer.cancel();
        setState(() {
          _isPlaying = false;
          _sortCompleted = true;
        });
        return;
      }
      _nextStep();
    });
  }

  void _nextStep() {
    if (_currentStep >= _history.length - 1) {
      setState(() => _sortCompleted = true);
      return;
    }
    setState(() => _currentStep++);
  }

  void _reset() {
    setState(() {
      if (_history.isNotEmpty) {
        _array = _history.first['array'];
      }
      _resetSortState();
      _generateInsertionSortSteps();
    });
  }

  Color _getElementColor(int index) {
    final step = _history[_currentStep];
    final int? keyIndex = step['keyIndex'];
    final int? comparingIndex = step['comparingIndex'];
    final List<int>? sortedIndices = step['sortedIndices'];

    if ((sortedIndices != null && sortedIndices.contains(index)) || _sortCompleted) {
      return Colors.green[400]!;
    }
    if (index == keyIndex) return Colors.purple[300]!;
    if (index == comparingIndex) return Colors.orange[400]!;
    
    return Colors.grey[300]!;
  }

  String _getStatusMessage() {
    if (_history.isEmpty) return 'Ready to sort.';
    return _history[_currentStep]['status'];
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (!_isVisualizationStarted) ...[
              _buildInputSection(),
            ] else ...[
              _buildVisualizationSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Sort Configuration',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _inputController,
              decoration: InputDecoration(
                hintText: 'e.g., 7,2,4,1,5,3',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                labelText: 'Array',
                prefixIcon: const Icon(Icons.list),
              ),
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
              child: const Text('Visualize Sort', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualizationSection() {
    final currentArray = _history[_currentStep]['array'];

    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _sortCompleted ? Colors.green[100] : Colors.blue[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _sortCompleted ? Colors.green[300]! : Colors.blue[300]!,
              ),
            ),
            child: Text(
              _getStatusMessage(),
              style: TextStyle(
                color: _sortCompleted ? Colors.green[800] : Colors.blue[800],
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
                  _buildLegendItem(Colors.purple[300]!, 'Key'),
                  _buildLegendItem(Colors.orange[400]!, 'Comparing'),
                  _buildLegendItem(Colors.green[400]!, 'Sorted'),
                   _buildLegendItem(Colors.grey[300]!, 'Default'),
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
                  children: List.generate(currentArray.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
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
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${currentArray[index]}',
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
          _buildControls(),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() {
              _isVisualizationStarted = false;
              _resetSortState();
            }),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('New Sort'),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Card(
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
              onPressed: _sortCompleted ? null : _togglePlayPause,
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
              onPressed: _sortCompleted || _isPlaying ? null : _nextStep,
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
