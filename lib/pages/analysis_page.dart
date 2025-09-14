import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnalysisPage extends StatelessWidget {
  final String algorithmName;

  const AnalysisPage({
    Key? key,
    required this.algorithmName,
  }) : super(key: key);

  // Algorithm analysis data
  final Map<String, Map<String, String>> analysisData = const {
    "Bubble Sort": {
      "best": "O(n)",
      "worst": "O(n²)",
      "avg": "O(n²)",
      "space": "O(1)",
      "desc": "Bubble Sort repeatedly compares adjacent elements and swaps them if they are in wrong order. Simple but inefficient for large datasets."
    },
    "Insertion Sort": {
      "best": "O(n)",
      "worst": "O(n²)",
      "avg": "O(n²)",
      "space": "O(1)",
      "desc": "Insertion Sort builds the sorted array one item at a time by inserting each element into its correct position. Efficient for small datasets."
    },
    "Quick Sort": {
      "best": "O(n log n)",
      "worst": "O(n²)",
      "avg": "O(n log n)",
      "space": "O(log n)",
      "desc": "Quick Sort uses divide-and-conquer approach with a pivot element to partition the array. Generally faster than other O(n²) algorithms."
    },
    "Linear Search": {
      "best": "O(1)",
      "worst": "O(n)",
      "avg": "O(n)",
      "space": "O(1)",
      "desc": "Linear Search checks each element sequentially until the target is found. Simple but slow for large datasets."
    },
    "Binary Search": {
      "best": "O(1)",
      "worst": "O(log n)",
      "avg": "O(log n)",
      "space": "O(1)",
      "desc": "Binary Search repeatedly divides the search space in half. Requires sorted array but very efficient for large datasets."
    },
  };

  // Convert complexity notation to numeric value for chart
  int _complexityToValue(String complexity) {
    if (complexity.contains('O(1)')) return 1;
    if (complexity.contains('O(log n)')) return 2;
    if (complexity.contains('O(n)') && !complexity.contains('²')) return 3;
    if (complexity.contains('O(n log n)')) return 4;
    if (complexity.contains('O(n²)')) return 5;
    return 3; // Default
  }

  // Get color for complexity level
  Color _getComplexityColor(String complexity) {
    final value = _complexityToValue(complexity);
    switch (value) {
      case 1:
        return Colors.green[600]!; // O(1) - Excellent
      case 2:
        return Colors.lightGreen[600]!; // O(log n) - Very Good
      case 3:
        return Colors.yellow[700]!; // O(n) - Good
      case 4:
        return Colors.orange[600]!; // O(n log n) - Fair
      case 5:
        return Colors.red[600]!; // O(n²) - Poor
      default:
        return Colors.grey[600]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentAlgorithm = analysisData[algorithmName];
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Algorithm Analysis',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Header with algorithm name
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [Colors.blue[600]!, Colors.blue[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getAlgorithmIcon(algorithmName),
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          algorithmName,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (currentAlgorithm != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      currentAlgorithm['desc']!,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          if (currentAlgorithm != null) ...[
            // Time Complexity Section
            _buildComplexityCard(
              'Time Complexity',
              Icons.access_time,
              [
                _ComplexityItem('Best Case', currentAlgorithm['best']!),
                _ComplexityItem('Average Case', currentAlgorithm['avg']!),
                _ComplexityItem('Worst Case', currentAlgorithm['worst']!),
              ],
            ),

            const SizedBox(height: 16),

            // Space Complexity Section
            _buildComplexityCard(
              'Space Complexity',
              Icons.storage,
              [
                _ComplexityItem('Space Usage', currentAlgorithm['space']!),
              ],
            ),

            const SizedBox(height: 20),

            // Comparison Chart
            _buildComparisonChart(currentAlgorithm),

            const SizedBox(height: 20),

            // Performance Guide
            _buildPerformanceGuide(),

            const SizedBox(height: 20),

            // All Algorithms Comparison
            _buildAllAlgorithmsComparison(),
          ] else ...[
            // Algorithm not found
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.orange[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Algorithm Not Found',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Analysis data for "$algorithmName" is not available.',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildComplexityCard(String title, IconData icon, List<_ComplexityItem> items) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue[600], size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.label,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getComplexityColor(item.value),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      item.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonChart(Map<String, String> currentAlgorithm) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, color: Colors.blue[600], size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Complexity Comparison',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildCustomBarChart([
              _ChartData('Best', currentAlgorithm['best']!),
              _ChartData('Average', currentAlgorithm['avg']!),
              _ChartData('Worst', currentAlgorithm['worst']!),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomBarChart(List<_ChartData> data) {
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }
    final maxValue = data.map((e) => _complexityToValue(e.value)).reduce(math.max);
    
    return Column(
      children: data.map((item) {
        final value = _complexityToValue(item.value);
        final percentage = maxValue > 0 ? value / maxValue : 0.0;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    item.value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: percentage,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getComplexityColor(item.value),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPerformanceGuide() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.amber[600], size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Performance Guide',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildGuideItem(Colors.green[600]!, 'O(1) - Constant', 'Excellent performance, independent of input size'),
            _buildGuideItem(Colors.lightGreen[600]!, 'O(log n) - Logarithmic', 'Very good performance, scales well'),
            _buildGuideItem(Colors.yellow[700]!, 'O(n) - Linear', 'Good performance, scales linearly'),
            _buildGuideItem(Colors.orange[600]!, 'O(n log n) - Log Linear', 'Fair performance, common in efficient sorts'),
            _buildGuideItem(Colors.red[600]!, 'O(n²) - Quadratic', 'Poor performance, avoid for large datasets'),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideItem(Color color, String complexity, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87, fontSize: 14),
                children: [
                  TextSpan(
                    text: complexity,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ' - '),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllAlgorithmsComparison() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.compare_arrows, color: Colors.purple[600], size: 24),
                const SizedBox(width: 12),
                const Text(
                  'All Algorithms Comparison',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
                columns: const [
                  DataColumn(label: Text('Algorithm', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Best', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Average', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Worst', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Space', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: analysisData.entries.map((entry) {
                  final isCurrentAlgorithm = entry.key == algorithmName;
                  return DataRow(
                    color: MaterialStateProperty.all(
                      isCurrentAlgorithm ? Colors.blue[50] : null,
                    ),
                    cells: [
                      DataCell(
                        Text(
                          entry.key,
                          style: TextStyle(
                            fontWeight: isCurrentAlgorithm ? FontWeight.bold : FontWeight.normal,
                            color: isCurrentAlgorithm ? Colors.blue[800] : null,
                          ),
                        ),
                      ),
                      DataCell(Text(entry.value['best']!)),
                      DataCell(Text(entry.value['avg']!)),
                      DataCell(Text(entry.value['worst']!)),
                      DataCell(Text(entry.value['space']!)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAlgorithmIcon(String algorithmName) {
    switch (algorithmName) {
      case 'Bubble Sort':
        return Icons.bubble_chart;
      case 'Insertion Sort':
        return Icons.insert_chart;
      case 'Quick Sort':
        return Icons.flash_on;
      case 'Linear Search':
        return Icons.search;
      case 'Binary Search':
        return Icons.account_tree;
      default:
        return Icons.code; // Fixed: Used a valid icon
    }
  }
}

class _ComplexityItem {
  final String label;
  final String value;

  _ComplexityItem(this.label, this.value);
}

class _ChartData {
  final String label;
  final String value;

  _ChartData(this.label, this.value);
}