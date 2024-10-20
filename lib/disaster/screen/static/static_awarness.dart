import 'package:disaster_management/disaster/screen/static/questions.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class StaticdataScreen extends StatefulWidget {
  const StaticdataScreen({super.key});

  @override
  _StaticdataScreenState createState() => _StaticdataScreenState();
}

class _StaticdataScreenState extends State<StaticdataScreen> {
  List<QuestionAnswer> filteredFaq = [];
  bool _showAll = false; // Tracks whether all items should be displayed
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredFaq = faq; // Initialize filtered list with all questions
    _searchController.addListener(_filterQuestions);
  }

  void _filterQuestions() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredFaq = faq.where((qa) {
        return qa.question.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    int itemsToShow = _showAll ? filteredFaq.length : 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Static Awareness'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search Questions...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: theme.inputDecorationTheme.fillColor ?? Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Disaster Management Resources',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10.0),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: itemsToShow,
                itemBuilder: (context, index) {
                  return _buildQuestionTile(filteredFaq[index], cardColor);
                },
              ),
              if (filteredFaq.length > 3)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showAll = !_showAll;
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      _showAll ? 'Show Less' : 'Show More',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 10.0),
              Text(
                'Need More Assistance?',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10.0),
              GestureDetector(
                onTap: () {
                  _launchEmail('your.email@example.com');
                },
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.email, color: theme.colorScheme.onPrimary),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Text(
                          'Contact Us',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchEmail(String toEmail) async {
    String emailUrl = 'mailto:$toEmail';
    if (await  canLaunch(emailUrl)) {
      await launch(emailUrl);
    } else {
      throw 'Could not launch $emailUrl';
    }
  }

  Widget _buildQuestionTile(QuestionAnswer questionAnswer, Color cardColor) {
    final theme = Theme.of(context);

    return Card(
      color: cardColor,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        title: Row(
          children: [
            Icon(Icons.question_answer, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                questionAnswer.question,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              questionAnswer.answer,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
