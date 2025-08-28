import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/exam_provider.dart';
import '../../widgets/exam_card.dart';

class ExamPage extends StatefulWidget {
  const ExamPage({super.key});

  @override
  State<ExamPage> createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> {
  @override
  void initState() {
    super.initState();
    // Fetches exams when the page is first built, if the list is empty.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ExamProvider>(context, listen: false);
      if (provider.exams.isEmpty) {
        provider.loadExams();
      }
    });
  }

  // A helper function to create a Future for the onRefresh callback.
  Future<void> _refreshExams(BuildContext context) {
    return Provider.of<ExamProvider>(context, listen: false).loadExams();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: SafeArea(
          child: Container(
            color: theme.colorScheme.surface,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Exam Schedule',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<ExamProvider>(
        builder: (context, provider, child) {
          // Show a loading spinner only on the initial load.
          if (provider.isLoading && provider.exams.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // ✨ WRAPPED THE BODY CONTENT WITH REFRESHINDICATOR ✨
          return RefreshIndicator(
            onRefresh: () => _refreshExams(context),
            child: _buildContent(provider), // Use a helper for cleaner code
          );
        },
      ),
    );
  }

  /// Builds the main content based on the provider's state.
  Widget _buildContent(ExamProvider provider) {
    if (provider.errorMessage != null) {
      // Wrap the error message in a scrollable view to enable pull-to-refresh.
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Could not load exams.\nError: ${provider.errorMessage}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    if (provider.exams.isEmpty) {
      // Also wrap the "empty" message in a scrollable view.
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_busy_outlined, size: 60, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No exams scheduled.', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
    
    // The main list of exams is already scrollable.
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: provider.exams.length,
      itemBuilder: (context, index) {
        final exam = provider.exams[index];
        return ExamCard(exam: exam);
      },
    );
  }
}