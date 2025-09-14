import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:io';
import '../services/gemini_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  void _select(int i, {bool closeDrawer = true}) {
    setState(() => _index = i);
    if (closeDrawer) Navigator.of(context).maybePop();
  }

  void _logout() {
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    if (isWide) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('DocuLearn'),
          actions: [
            IconButton(
              tooltip: 'Logout',
              onPressed: _logout,
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: Row(
          children: [
            _SideRail(selectedIndex: _index, onSelected: (i) => _select(i, closeDrawer: false)),
            const VerticalDivider(width: 1),
            Expanded(
              child: _Content(index: _index, onGoSummarizePage: _goToSummarizerIfAvailable),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('DocuLearn'),
          actions: [
            IconButton(
              tooltip: 'Logout',
              onPressed: _logout,
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        drawer: _SideDrawer(
          selectedIndex: _index,
          onSelected: (i) => _select(i, closeDrawer: true),
          onLogout: _logout,
        ),
        body: _Content(index: _index, onGoSummarizePage: _goToSummarizerIfAvailable),
      );
    }
  }

  void _goToSummarizerIfAvailable() {
    Navigator.of(context).pushNamed('/summarize');
  }
}


class _SideDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onLogout;

  const _SideDrawer({
    required this.selectedIndex,
    required this.onSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [scheme.primary, scheme.primaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'DocuLearn',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ),
            _DrawerTile(
              icon: Icons.dashboard_outlined,
              label: 'Dashboard',
              selected: selectedIndex == 0,
              onTap: () => onSelected(0),
            ),
            _DrawerTile(
              icon: Icons.description_outlined,
              label: 'Summarize PDF',
              selected: selectedIndex == 1,
              onTap: () => onSelected(1),
            ),
            _DrawerTile(
              icon: Icons.style_outlined,
              label: 'Flashcards',
              selected: selectedIndex == 2,
              onTap: () => onSelected(2),
            ),
            _DrawerTile(
              icon: Icons.quiz_outlined,
              label: 'Quizzes',
              selected: selectedIndex == 3,
              onTap: () => onSelected(3),
            ),
            _DrawerTile(
              icon: Icons.settings_outlined,
              label: 'Settings',
              selected: selectedIndex == 4,
              onTap: () => onSelected(4),
            ),
            const Spacer(),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: onLogout,
            ),
          ],
        ),
      ),
    );
  }
}


class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: selected ? scheme.primary : null),
      title: Text(
        label,
        style: TextStyle(
          color: selected ? scheme.primary : null,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
      selected: selected,
      onTap: onTap,
    );
  }
}


class _SideRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _SideRail({required this.selectedIndex, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelected,
      labelType: NavigationRailLabelType.all,
      leading: const Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Icon(Icons.menu_book_outlined, size: 28),
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: Text('Dashboard'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.description_outlined),
          selectedIcon: Icon(Icons.description),
          label: Text('Summarize PDF'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.style_outlined),
          selectedIcon: Icon(Icons.style),
          label: Text('Flashcards'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.quiz_outlined),
          selectedIcon: Icon(Icons.quiz),
          label: Text('Quizzes'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: Text('Settings'),
        ),
      ],
    );
  }
}


class _Content extends StatelessWidget {
  final int index;
  final VoidCallback onGoSummarizePage;

  const _Content({
    required this.index,
    required this.onGoSummarizePage,
  });

  @override
  Widget build(BuildContext context) {
    switch (index) {
      case 0:
        return const _DashboardContent();
      case 1:
        return _SummarizeContent(onGoSummarizePage: onGoSummarizePage);
      case 2:
        return const _FlashcardsContent();
      case 3:
        return const _QuizzesContent();
      case 4:
        return const _SettingsContent();
      default:
        return const SizedBox.shrink();
    }
  }
}


class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Welcome to DocuLearn",
          style: Theme.of(context).textTheme.headlineMedium),
    );
  }
}


class _SummarizeContent extends StatelessWidget {
  final VoidCallback onGoSummarizePage;
  const _SummarizeContent({required this.onGoSummarizePage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.description_outlined,
                    size: 48, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 12),
                Text('Summarize a PDF',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  'Upload a PDF and get an executive summary.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onGoSummarizePage,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open Summarizer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _FlashcardsContent extends StatefulWidget {
  const _FlashcardsContent();

  @override
  State<_FlashcardsContent> createState() => _FlashcardsContentState();
}

class _FlashcardsContentState extends State<_FlashcardsContent> {
  final _gemini = GeminiService();
  PlatformFile? _picked;
  List<String> _flashcards = [];
  String? _error;
  bool _busy = false;
  int _currentIndex = 0;
  int _flashcardCount = 10;

  Future<void> _pickPdf() async {
    setState(() {
      _error = null;
      _flashcards = [];
      _picked = null;
      _currentIndex = 0;
    });

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (!mounted) return;
    if (result != null && result.files.isNotEmpty) {
      setState(() => _picked = result.files.single);
    }
  }

  Future<void> _generateFlashcards() async {
    if (_picked == null) return;
    setState(() {
      _error = null;
      _flashcards = [];
      _busy = true;
      _currentIndex = 0;
    });

    try {
      final bytes = File(_picked!.path!).readAsBytesSync();
      final pdf = PdfDocument(inputBytes: bytes);

      String text = '';
      for (int i = 0; i < (pdf.pages.count > 3 ? 3 : pdf.pages.count); i++) {
        final pageText =
            PdfTextExtractor(pdf).extractText(startPageIndex: i, endPageIndex: i);
        text += "$pageText\n";
      }
      pdf.dispose();

      if (text.length > 3000) text = text.substring(0, 3000);

      final response = await _gemini.generateSummary(
        "Extract exactly $_flashcardCount concise, important points from this document. "
        "Each should be a short standalone statement, one per line.\n\n$text",
      );

      setState(() {
        _flashcards = response
            .split("\n")
            .where((line) => line.trim().isNotEmpty)
            .take(_flashcardCount)
            .toList();
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _busy = false);
    }
  }

  void _nextCard() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _flashcards.length;
    });
  }

  void _prevCard() {
    setState(() {
      _currentIndex =
          (_currentIndex - 1 + _flashcards.length) % _flashcards.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_flashcards.isEmpty && !_busy && _picked == null) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.style_outlined,
                      size: 48, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 12),
                  Text('Generate Flashcards',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    'Upload a PDF and extract 10–25 key points as flashcards.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _pickPdf,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload PDF'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_busy) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text("Error: $_error", style: const TextStyle(color: Colors.red)),
      );
    }

    if (_picked != null && _flashcards.isEmpty) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Selected: ${_picked!.name}"),
                  const SizedBox(height: 16),
                  DropdownButton<int>(
                    value: _flashcardCount,
                    items: const [
                      DropdownMenuItem(value: 10, child: Text("10 flashcards")),
                      DropdownMenuItem(value: 15, child: Text("15 flashcards")),
                      DropdownMenuItem(value: 20, child: Text("20 flashcards")),
                      DropdownMenuItem(value: 25, child: Text("25 flashcards")),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _flashcardCount = v);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _generateFlashcards,
                    icon: const Icon(Icons.flash_on_outlined),
                    label: const Text("Generate Flashcards"),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_flashcards.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              margin: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Container(
                padding: const EdgeInsets.all(24),
                width: double.infinity,
                height: 250,
                alignment: Alignment.center,
                child: Text(
                  _flashcards[_currentIndex],
                  style: const TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _prevCard,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Prev"),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: _nextCard,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text("Next"),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "${_currentIndex + 1} / ${_flashcards.length}",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}


class _QuizzesContent extends StatelessWidget {
  const _QuizzesContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Quizzes coming soon...",
          style: Theme.of(context).textTheme.headlineSmall),
    );
  }
}


class _SettingsContent extends StatelessWidget {
  const _SettingsContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Text('Settings',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: const Text('DocuLearn • VirtuHack Demo'),
          ),
        ],
      ),
    );
  }
}
