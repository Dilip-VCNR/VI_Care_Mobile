import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:vicare/utils/app_colors.dart';

import '../../main.dart';
import '../../utils/app_buttons.dart';
import '../../utils/app_locale.dart';
import '../../utils/routes.dart';
import '../controller/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isShowPassword = true;
  bool rememberMe = false;
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  AuthController authController = AuthController();

  String? registerAs;
  String? gender;

  int currentStep = 1;

  Color getIndicatorColor(int step) {
    return currentStep >= step ? AppColors.primaryColor : Colors.grey;
  }
  File? _selectedImage;

  void _showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text("Choose Image Source"),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () async {
                Navigator.pop(context);
                final image =
                await ImagePicker().pickImage(source: ImageSource.camera);
                if (image != null) {
                  setState(() {
                    _selectedImage = File(image.path);
                  });
                }
              },
              child: const ListTile(
                leading: Icon(Icons.camera),
                title: Text("Camera"),
              ),
            ),
            SimpleDialogOption(
              onPressed: () async {
                Navigator.pop(context);
                final image =
                await ImagePicker().pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() {
                    _selectedImage = File(image.path);
                  });
                }
              },
              child: const ListTile(
                leading: Icon(Icons.image),
                title: Text("Gallery"),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Non-scrollable part
            Padding(
              padding: const EdgeInsets.only(
                  top: 80, left: 20, right: 20, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, Routes.onBoardingRoute);
                    },
                    child: const Icon(
                      Icons.arrow_back_ios,
                      size: 25,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppLocale.createAccount.getString(context),
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppLocale.pleaseFillToRegister.getString(context),
                    style: const TextStyle(color: AppColors.fontShadeColor),
                  ),
                  const SizedBox(height: 10),
                  StepProgressIndicator(
                    roundedEdges: const Radius.circular(20),
                    size: 7,
                    totalSteps: 3,
                    currentStep: currentStep,
                    selectedColor: AppColors.primaryColor,
                    unselectedColor: Colors.grey,
                  ),
                ],
              ),
            ),

            // Scrollable part
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Column(
                    children: [
                      currentStep == 1
                          ? emailPassword(screenSize!)
                          : const SizedBox.shrink(),
                      currentStep == 2
                          ? otpScreen(screenSize!)
                          : const SizedBox.shrink(),
                      currentStep == 3
                          ? personalDetails(screenSize!)
                          : const SizedBox.shrink(),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            currentStep != 1
                                ? getPrimaryAppButton(
                                    context,
                                    AppLocale.previous.getString(context),
                                    onPressed: () {
                                      setState(() {
                                        currentStep = currentStep - 1;
                                      });
                                    },
                                    buttonColor: Colors.red.shade500,
                                  )
                                : const SizedBox.shrink(),
                            const SizedBox(
                              height: 10,
                            ),
                            currentStep == 1 || currentStep == 2
                                ? getPrimaryAppButton(
                                    context,
                                    AppLocale.next.getString(context),
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        setState(() {
                                          currentStep = currentStep + 1;
                                        });
                                      }
                                    },
                                  )
                                : getPrimaryAppButton(
                                    context,
                                    AppLocale.proceedToSignUp
                                        .getString(context),
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        Navigator.pushNamed(
                                            context, Routes.patientDetailsRoute);
                                      }
                                    },
                                  ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  emailPassword(Size screenSize) {
    return Column(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocale.email.getString(context),
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: emailController,
              validator: (value) {
                if (value!.isEmpty) {
                  return AppLocale.validEmail.getString(context);
                }
                if (authController.isNotValidEmail(value)) {
                  return "Please enter valid email";
                }
                return null;
              },
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                hintText: AppLocale.email.getString(context),
                counterText: "",
                isCollapsed: true,
                errorStyle: const TextStyle(color: Colors.red),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.primaryColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(AppLocale.password.getString(context),
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(
              height: 10,
            ),

            TextFormField(
              controller: passwordController,
              validator: (value) {
                if (value!.isEmpty) {
                  return AppLocale.validPassword.getString(context);
                }
                return null;
              },
              keyboardType: TextInputType.visiblePassword,
              obscureText: isShowPassword,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                hintText: AppLocale.password.getString(context),
                suffixIcon: CupertinoButton(
                  onPressed: () {
                    setState(() {
                      isShowPassword = !isShowPassword;
                    });
                  },
                  child: Icon(
                    isShowPassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                ),
                counterText: "",
                isCollapsed: true,
                errorStyle: const TextStyle(color: Colors.red),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.primaryColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
            ),

            const SizedBox(
              height: 10,
            ),
            Text(AppLocale.registerAs.getString(context),
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(
              height: 10,
            ),
            DropdownButtonFormField<String>(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please select the role";
                }
                return null;
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Colors.grey.shade50,
                  ),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
                focusColor: Colors.transparent,
                errorStyle: TextStyle(color: Colors.red.shade400),
              ),
              dropdownColor: Colors.white,
              value: registerAs,
              hint: Text(AppLocale.role.getString(context)),
              onChanged: (String? value) {
                setState(() {
                  registerAs = value!;
                });
              },
              style: const TextStyle(color: Colors.black),
              items: <String>[
                AppLocale.doctor.getString(context),
                AppLocale.member.getString(context)
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            // SizedBox(height: screenSize.height/7,),
          ],
        ),
      ],
    );
  }

  otpScreen(Size screenSize) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocale.enterOtp.getString(context),
            style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(
          height: 10,
        ),
        TextFormField(
          validator: (value) {
            if (value!.isEmpty) {
              return AppLocale.validOtp.getString(context);
            }
            return null;
          },
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            hintText: AppLocale.otp.getString(context),
            counterText: "",
            isCollapsed: true,
            errorStyle: const TextStyle(color: Colors.red),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.primaryColor),
              borderRadius: BorderRadius.circular(8),
            ),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          ),
        ),
      ],
    );
  }

  personalDetails(Size screenSize) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            _showImageSourceDialog(context);
          },
          child: Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : null,
                ),
                const SizedBox(
                  height: 10,
                ),
                Positioned(
                    bottom: 4,
                    right: 2,
                    child: CircleAvatar(
                        radius: 15,
                        backgroundColor: AppColors.primaryColor,
                        child: IconButton(
                            onPressed: () {
                              _showImageSourceDialog(context);
                            },
                            icon: const Icon(
                              Icons.edit_outlined,
                              size: 15,
                            ),
                            color: Colors.white))),
              ],
            ),
          ),
        ),
        const SizedBox(height:10),
        Text(AppLocale.firstName.getString(context),
            style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(
          height: 10,
        ),
        TextFormField(
          validator: (value) {
            if (value!.isEmpty) {
              return AppLocale.validFirstName.getString(context);
            }
            if (authController.isNotValidName(value)) {
              return AppLocale.validFirstName.getString(context);
            }
            return null;
          },
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            hintText: AppLocale.firstName.getString(context),
            hintStyle: const TextStyle(fontSize: 15, color: Colors.grey),
            counterText: "",
            isCollapsed: true,
            errorStyle: const TextStyle(color: Colors.red),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.primaryColor),
              borderRadius: BorderRadius.circular(8),
            ),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(AppLocale.lastName.getString(context),
            style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(
          height: 10,
        ),
        TextFormField(
          validator: (value) {
            if (value!.isEmpty) {
              return AppLocale.validLastName.getString(context);
            }
            if (authController.isNotValidName(value)) {
              return AppLocale.validFirstName.getString(context);
            }
            return null;
          },
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            hintText: AppLocale.lastName.getString(context),
            hintStyle: const TextStyle(fontSize: 15, color: Colors.grey),
            counterText: "",
            isCollapsed: true,
            errorStyle: const TextStyle(color: Colors.red),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.primaryColor),
              borderRadius: BorderRadius.circular(8),
            ),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(AppLocale.gender.getString(context),
            style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(
          height: 10,
        ),
        DropdownButtonFormField<String>(
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please select the gender";
            }
            return null;
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(
                color: Color(0xffD3D3D3),
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
            focusColor: Colors.transparent,
            errorStyle: TextStyle(color: Colors.red.shade400),
          ),
          dropdownColor: Colors.white,
          hint: Text(AppLocale.selectGender.getString(context)),
          value: gender,
          onChanged: (String? value) {
            setState(() {
              gender = value!;
            });
          },
          style: const TextStyle(color: Colors.black),
          items: <String>[
            AppLocale.male.getString(context),
            AppLocale.female.getString(context)
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocale.dateOfBirth.getString(context),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1026),
                        lastDate: DateTime.now(),
                      );
                      setState(() {
                        dobController.text =
                            "${picked!.day} / ${picked.month} / ${picked.year}";
                      });
                    },
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter valid Date";
                        }
                        return null;
                      },
                      enabled: false,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 10),
                        errorStyle: const TextStyle(color: Colors.red),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xffD3D3D3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: AppColors.primaryColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        border: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_month),
                          onPressed: () {},
                        ),
                        filled: true,
                        hintText: AppLocale.dateOfBirth.getString(context),
                        fillColor: Colors.white,
                      ),
                      controller: dobController,
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 30,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  rememberMe = !rememberMe;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  border: Border.all(
                    // color: Colors.blue,
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(0.6),
                  child: rememberMe
                      ? const Icon(
                          Icons.check,
                          size: 10,
                        )
                      : Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.transparent,
                            ),
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: screenSize.width / 1.5,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: AppLocale.agreeToLogin.getString(context),
                      style: const TextStyle(
                        color: AppColors.fontShadeColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushNamed(context, Routes.webViewRoute,
                              arguments: {
                                'url': "https://www.google.com",
                                'title': AppLocale.termsAndConditions
                                    .getString(context),
                              });
                        },
                      text: AppLocale.termsAndConditions.getString(context),
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: AppLocale.and.getString(context),
                      style: const TextStyle(
                        color: AppColors.fontShadeColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushNamed(context, Routes.webViewRoute,
                              arguments: {
                                'url': "https://www.google.com",
                                'title':
                                    AppLocale.privacyPolicy.getString(context),
                              });
                        },
                      text: AppLocale.privacyPolicy.getString(context),
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
