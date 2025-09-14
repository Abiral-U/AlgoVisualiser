import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AlgorithmListPage extends StatelessWidget {
  const AlgorithmListPage({Key? key}) : super(key: key);

  // Algorithm data
  final List<Map<String, String>> algorithms = const [
    {
      "name": "Bubble Sort",
      "desc":
          "Compares adjacent elements and swaps them if they are in wrong order.",
    },
    {
      "name": "Insertion Sort",
      "desc":
          "Builds sorted array one element at a time by inserting elements.",
    },
    {
      "name": "Quick Sort",
      "desc":
          "Divide and conquer algorithm using pivot element to partition array.",
    },
    {
      "name": "Linear Search",
      "desc": "Sequentially checks each element until target is found.",
    },
    {
      "name": "Binary Search",
      "desc": "Search in a sorted array by repeatedly halving search space.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Algorithm Visualizer',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Choose an Algorithm',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: algorithms.length,
                itemBuilder: (context, index) {
                  final algorithm = algorithms[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _getAlgorithmIcon(algorithm['name']!),
                                  color: Colors.blue[600],
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    algorithm['name']!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[800],
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              algorithm['desc']!,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                    height: 1.4,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                onPressed: () => _navigateToVisualization(
                                  context,
                                  algorithm['name']!,
                                ),
                                icon: const Icon(Icons.play_arrow, size: 20),
                                label: const Text(
                                  'Visualize',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[600],
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get appropriate icon for each algorithm
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
        return Icons.code;
    }
  }

  // Navigation method to Visualization Page
  void _navigateToVisualization(BuildContext context, String algorithmName) {
    context.go('/visualize/$algorithmName');
  }
}
