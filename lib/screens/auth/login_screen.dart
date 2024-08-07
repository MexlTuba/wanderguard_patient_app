import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:go_router/go_router.dart';
import 'package:wanderguard_patient_app/controllers/auth_controller.dart';
import 'package:wanderguard_patient_app/controllers/patient_data_controller.dart';
import 'package:wanderguard_patient_app/main.dart';
import 'package:wanderguard_patient_app/routing/router.dart';
import 'package:wanderguard_patient_app/services/zegocloud_service.dart';
import 'package:wanderguard_patient_app/utils/colors.dart';
import 'package:wanderguard_patient_app/utils/size_config.dart';
import 'package:wanderguard_patient_app/widgets/dialogs/waiting_dialog.dart';
import 'package:wanderguard_patient_app/screens/home_screen.dart'; // Import your ZegoServiceHelper

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String route = "/login";
  static const String name = "Login Screen";

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late GlobalKey<FormState> formKey;
  late TextEditingController username, password;
  late FocusNode usernameFn, passwordFn;

  bool obfuscate = true;

  @override
  void initState() {
    super.initState();
    formKey = GlobalKey<FormState>();
    username = TextEditingController();
    password = TextEditingController();
    usernameFn = FocusNode();
    passwordFn = FocusNode();
  }

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    usernameFn.dispose();
    passwordFn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.secondaryColor,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: CustomColors.secondaryColor,
        surfaceTintColor: CustomColors.secondaryColor,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(
                            'lib/assets/icons/wanderguard-logo-small.svg'),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        Text('Sign In',
                            style: TextStyle(
                                fontSize: 3 * SizeConfig.textMultiplier,
                                color: CustomColors.primaryColor,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: decoration.copyWith(
                                labelText: "Username",
                                labelStyle:
                                    const TextStyle(color: Colors.black87)),
                            focusNode: usernameFn,
                            controller: username,
                            onEditingComplete: () {
                              passwordFn.requestFocus();
                            },
                            validator: MultiValidator([
                              RequiredValidator(
                                  errorText: 'Please enter your username'),
                              MinLengthValidator(2,
                                  errorText: "Minimum 2 characters required"),
                              MaxLengthValidator(50,
                                  errorText: "Maximum 50 characters allowed"),
                            ]).call,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: obfuscate,
                            decoration: decoration.copyWith(
                                labelText: "Password",
                                labelStyle:
                                    const TextStyle(color: Colors.black87),
                                suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        obfuscate = !obfuscate;
                                      });
                                    },
                                    icon: Icon(
                                      obfuscate
                                          ? CupertinoIcons.eye_slash
                                          : CupertinoIcons.eye,
                                      color: Colors.grey.shade500,
                                    ))),
                            focusNode: passwordFn,
                            controller: password,
                            onEditingComplete: () {
                              passwordFn.unfocus();
                            },
                            validator: MultiValidator([
                              RequiredValidator(
                                  errorText: "Password is required"),
                              MinLengthValidator(6,
                                  errorText: "Minimum 6 characters required"),
                              MaxLengthValidator(50,
                                  errorText: "Maximum 50 characters allowed"),
                            ]).call,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                  style: const ButtonStyle(
                                    overlayColor: WidgetStateColor.transparent,
                                    splashFactory: NoSplash.splashFactory,
                                  ),
                                  onPressed: () {},
                                  child: Text('Forgot Password',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: CustomColors.primaryColor)))
                            ],
                          ),
                          const SizedBox(height: 20),
                          MaterialButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textColor: CustomColors.secondaryColor,
                            color: CustomColors.primaryColor,
                            minWidth: double.infinity,
                            height: 55,
                            onPressed: () {
                              onSubmit();
                            },
                            child: const Text(
                              'Sign In',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: 40),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Divider(color: Colors.grey.shade400),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Text('Or continue with',
                                      style: TextStyle(
                                          fontSize: 13, color: Colors.black87)),
                                ),
                                Expanded(
                                  child: Divider(color: Colors.grey.shade400),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade400,
                                          width: 1),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Image.asset(
                                    'lib/assets/icons/google-icon.webp',
                                    width: 50,
                                    height: 50,
                                  ),
                                ),
                                onTap: () {
                                  print('Continue with google');
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onSubmit() async {
    if (formKey.currentState?.validate() ?? false) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WaitingDialog(prompt: 'Logging in...');
        },
      );

      try {
        await AuthController.instance.login(
          username.text.trim(),
          password.text.trim(),
        );

        final patient =
            PatientDataController.instance.patientModelNotifier.value;
        if (patient != null) {
          ZegoServiceHelper zegoServiceHelper = ZegoServiceHelper(
            patientAcctId: patient.patientAcctId,
            patientName: '${patient.firstName} ${patient.lastName}',
            navigatorKey: GlobalRouter.navigatorKey,
          );
          zegoServiceHelper.initialize();

          if (mounted) {
            Navigator.of(context).pop(); // Close the WaitingDialog
            context.go(HomeScreen.route);
          }
        } else {
          throw Exception('Patient data not found');
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop(); // Close the WaitingDialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: $e')),
          );
        }
      }
    }
  }

  final OutlineInputBorder _baseBorder = OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey.shade400),
    borderRadius: const BorderRadius.all(Radius.circular(8)),
  );

  InputDecoration get decoration => InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: true,
      fillColor: Colors.white,
      errorMaxLines: 3,
      disabledBorder: _baseBorder,
      enabledBorder: _baseBorder.copyWith(
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
      ),
      focusedBorder: _baseBorder.copyWith(
        borderSide: BorderSide(color: Colors.deepPurpleAccent, width: 1),
      ),
      errorBorder: _baseBorder.copyWith(
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ));
}
