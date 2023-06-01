import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atlas_mobile/login_page.dart';
import 'package:atlas_mobile/colors/colors.dart';
import 'package:atlas_mobile/update_profile.dart';
class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _username;
  String? _email;
  int? _age;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username');
      _email = prefs.getString('email');
      _age = prefs.getInt('age');
    });
  }
    
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
      title: Text(_username ?? ''),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 10.0),
              Stack(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: const CircleAvatar(
                        backgroundImage: AssetImage('assets/images/profile_image.png'),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: AppColors.primaryColor, // Replace with tPrimaryColor
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _username ??'',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                'Profile Subheading', // Replace with tProfileSubHeading
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),

              /// -- BUTTON
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle edit profile button press
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UpdateProfileScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor, // Replace with tPrimaryColor
                    side: BorderSide.none,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    'Edit Profile', // Replace with tEditProfile
                    style: TextStyle(color: Colors.white), // Replace with tDarkColor
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 10),

              /// -- MENU
              ProfileMenuWidget(title: 'Settings', icon: Icons.settings, onPress: () {}),
              ProfileMenuWidget(title: 'Billing Details', icon: Icons.account_balance_wallet, onPress: () {}),
              ProfileMenuWidget(title: 'User Management', icon: Icons.person, onPress: () {}),
              const Divider(),
              const SizedBox(height: 10),
              ProfileMenuWidget(title: 'Information', icon: Icons.info, onPress: () {}),
              ProfileMenuWidget(
                title: 'Logout',
                icon: Icons.logout,
                textColor: AppColors.primaryColor,
                endIcon: false,
                onPress: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('LOGOUT'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              // Handle logout button press
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              side: BorderSide.none,
                            ),
                            child: const Text('Yes'),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('No'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileMenuWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? textColor;
  final bool endIcon;
  final VoidCallback onPress;

  const ProfileMenuWidget({
    Key? key,
    required this.title,
    required this.icon,
    this.textColor,
    this.endIcon = true,
    required this.onPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPress,
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      leading: Icon(icon),
      trailing: endIcon ? const Icon(Icons.arrow_forward_ios) : null,
    );
  }
}
