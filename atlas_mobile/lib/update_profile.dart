import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import 'colors/colors.dart';
import 'controllers/user_controller.dart';

const tProfile = "Profile";
const tProfileImage = "assets/images/profile_image.png";
const tProfileHeading = "Profile Heading";
const tProfileSubHeading = "Profile Subheading";
const tDefaultSize = 16.0;

const tEditProfile = "Edit Profile";
const tFormHeight = 100.0;

class UpdateProfileScreen extends StatefulWidget {
  UpdateProfileScreen({Key? key}) : super(key: key);

  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final UserController _userController = UserController();
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String newName = ''; // Variable to store the new name
  String phoneNumber = ''; // Variable to store the phone number

  @override
  void initState() {
    super.initState();
    _loadNameFromSharedPreferences();
  }

  void _loadNameFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedName = prefs.getString('name');

    setState(() {
      newName = storedName ?? ''; // Assign the retrieved name to the newName variable
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (newName.isNotEmpty) {
        final isSuccess = await _userController.updateUser(newName);
        print(newName);
        if (isSuccess) {
          // Show a success message or perform any other actions
          _showSnackBar("Name changed successfully");
        } else {
          // Show an error message or perform any other actions
        }
      } else {
        _showSnackBar("error");
      }
    }
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(LineAwesomeIcons.angle_left),
        ),
        title: Text(tEditProfile, style: Theme.of(context).textTheme.headline6),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(tDefaultSize),
          child: Column(
            children: [
              // -- IMAGE with ICON
              Stack(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: const Image(image: AssetImage(tProfileImage)),
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
                        color: AppColors.primaryColor,
                      ),
                      child: const Icon(
                        LineAwesomeIcons.camera,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),

              // -- Form Fields
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: newName,
                      decoration: const InputDecoration(
                        labelText: "Full Name",
                        prefixIcon: Icon(LineAwesomeIcons.user),
                      ),
                      onSaved: (value) {
                        newName = value ?? ''; // Update the newName variable with the saved value
                      },
                    ),
                    const SizedBox(height: tFormHeight - 80),
                    IntlPhoneField(
                      decoration: const InputDecoration(
                        labelText: "Phone Number",
                        prefixIcon: Icon(LineAwesomeIcons.mobile_phone),
                      ),
                      onChanged: (phone) {
                        phoneNumber = phone.completeNumber ?? ''; // Update the phoneNumber variable with the entered phone number
                      },
                    ),
                    
                   
                    const SizedBox(height: tFormHeight),

                    // -- Form Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          side: BorderSide.none,
                          shape: const StadiumBorder(),
                        ),
                        child: const Text(tEditProfile, style: TextStyle(color: AppColors.backgroundColor)),
                      ),
                    ),
                    const SizedBox(height: tFormHeight),

                    // -- Created Date and Delete Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: "Joined ",
                            style: TextStyle(fontSize: 12),
                            children: [
                              TextSpan(
                                text: "JoinedAt",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Add your code here to handle profile deletion
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent.withOpacity(0.1),
                            elevation: 0,
                            foregroundColor: Colors.red,
                            shape: const StadiumBorder(),
                            side: BorderSide.none,
                          ),
                          child: const Text("Delete"),
                        ),
                      ],
                    ),
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
