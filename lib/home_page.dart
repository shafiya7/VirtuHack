import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;


  void _select(int i, {bool closeDrawer = true}) {
    setState(() => _index = i);
    if (closeDrawer) {
     
      Navigator.of(context).maybePop();
    }
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
            _SideRail(
              selectedIndex: _index,
              onSelected: (i) => _select(i, closeDrawer: false),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: _Content(index: _index, onGoSummarizePage: _goToSummarizerIfAvailable)),
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
              icon: Icons.settings_outlined,
              label: 'Settings',
              selected: selectedIndex == 2,
              onTap: () => onSelected(2),
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

  const _SideRail({
    required this.selectedIndex,
    required this.onSelected,
  });

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
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Text(
            'Welcome to DocuLearn',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Choose an option from the side menu to get started.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _InfoCard(
                title: 'Quick Start',
                subtitle: 'Upload a PDF and get an executive summary.',
                icon: Icons.bolt_outlined,
                color: scheme.primaryContainer,
              ),
              _InfoCard(
                title: 'Recent Files',
                subtitle: 'Your latest summarized documents will appear here.',
                icon: Icons.history,
                color: scheme.tertiaryContainer,
              ),
              _InfoCard(
                title: 'Tips',
                subtitle: 'Long PDFs? We chunk and synthesize automatically.',
                icon: Icons.tips_and_updates_outlined,
                color: scheme.secondaryContainer,
              ),
            ],
          ),
        ],
      ),
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
                Text(
                  'Summarize a PDF',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Open the PDF summarizer to upload a document and get an executive summary.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onGoSummarizePage,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open Summarizer'),
                ),
                const SizedBox(height: 6),
                Text(
                  'Note: This navigates to /summarize. Add that route if you haven’t already.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Theme.of(context).hintColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent();

  @override
  Widget build(BuildContext context) {
    bool _dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Text('Settings',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          SwitchListTile(
            value: _dark,
            onChanged: (_) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Theme switching not wired in this demo.'),
              ));
            },
            title: const Text('Dark Mode'),
            subtitle: const Text('(demo toggle)'),
            secondary: const Icon(Icons.dark_mode_outlined),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: const Text('DocuLearn • VirtuHack Demo'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _InfoCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final onColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
            ? Colors.white
            : Colors.black87;

    return SizedBox(
      width: 280,
      child: Card(
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 28, color: onColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: onColor,
                            )),
                    const SizedBox(height: 6),
                    Text(subtitle,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: onColor.withOpacity(.9))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
