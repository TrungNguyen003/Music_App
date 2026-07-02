import 'package:flutter/material.dart';
import '../auth/login_page.dart';
import '../../data/user_manager.dart';

class AccountTab extends StatefulWidget {
  const AccountTab({super.key});

  @override
  State<AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {

  Future<void> _navigateToLogin() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );

    if (result is String) {
      setState(() {
        UserManager.loggedInEmail = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: UserManager.loggedInEmail == null
            ? ElevatedButton(
                onPressed: _navigateToLogin,
                child: const Text('Đăng nhập'),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Đã đăng nhập: ${UserManager.loggedInEmail}'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => setState(() => UserManager.loggedInEmail = null),
                    child: const Text('Đăng xuất'),
                  ),
                ],
              ),
      ),
    );
  }
}
