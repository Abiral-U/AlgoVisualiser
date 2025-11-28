import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'pages/algorithm_list.dart';
import 'pages/analysis_page.dart';
import 'pages/binary_search.dart';
import 'pages/linear_search.dart';
import 'pages/quick_sort.dart';
import 'pages/bubble_sort.dart';
import 'pages/insertion_sort.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const AlgorithmVisualizerApp(),
    ),
  );
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  errorBuilder: (context, state) => const ErrorScreen(),
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const AlgorithmListPage();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'visualize/:algorithmName',
          builder: (BuildContext context, GoRouterState state) {
            final String algorithmName = state.pathParameters['algorithmName']!;
            switch (algorithmName) {
              case 'binary_search':
                return const BinarySearchPage(algorithmName: 'Binary Search');
              case 'linear_search':
                return const LinearSearchPage(algorithmName: 'Linear Search');
              case 'quick_sort':
                return const QuickSortPage(algorithmName: 'Quick Sort');
              case 'bubble_sort':
                return const BubbleSortPage(algorithmName: 'Bubble Sort');
              case 'insertion_sort':
                return const InsertionSortPage(algorithmName: 'Insertion Sort');
              default:
                return const ErrorScreen();
            }
          },
        ),
        GoRoute(
          path: 'analysis/:algorithmName',
          builder: (BuildContext context, GoRouterState state) {
            final String algorithmName = state.pathParameters['algorithmName']!;
            return AnalysisPage(algorithmName: algorithmName);
          },
        ),
      ],
    ),
  ],
);

class AlgorithmVisualizerApp extends StatelessWidget {
  const AlgorithmVisualizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primarySeedColor = Colors.deepPurple;

    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primarySeedColor,
        foregroundColor: Colors.white,
      ),
    );

    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.dark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
      ),
    );

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          routerConfig: _router,
          title: 'Algorithm Visualizer',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
        backgroundColor: Theme.of(context).colorScheme.error,
        foregroundColor: Theme.of(context).colorScheme.onError,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              '404 - Page Not Found',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'The page you are looking for does not exist.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go to Homepage'),
            ),
          ],
        ),
      ),
    );
  }
}
