import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/views/home_view.dart';

class GenericErrorScaffold extends StatelessWidget {
  const GenericErrorScaffold({Key? key}) : super(key: key);

  String mainButtonText(BuildContext context) {
    String currRoute = ModalRoute.of(context)?.settings.name ?? '';

    return currRoute == HomeView.routeName ? 'Reload' : 'Go back home';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('An error happened!', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pushReplacementNamed(HomeView.routeName),
              icon: const Icon(Icons.home),
              label: Text(mainButtonText(context)),
            ),
          ],
        ),
      ),
    );
  }
}
