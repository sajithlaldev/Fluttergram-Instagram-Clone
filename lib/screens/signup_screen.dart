import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone_flutter/models/user.dart' as userModel;
import 'package:instagram_clone_flutter/resources/auth_methods.dart';
import 'package:instagram_clone_flutter/responsive/mobile_screen_layout.dart';
import 'package:instagram_clone_flutter/responsive/responsive_layout.dart';
import 'package:instagram_clone_flutter/responsive/web_screen_layout.dart';
import 'package:instagram_clone_flutter/screens/login_screen.dart';
import 'package:instagram_clone_flutter/utils/colors.dart';
import 'package:instagram_clone_flutter/utils/utils.dart';
import 'package:instagram_clone_flutter/widgets/text_field_input.dart';

class SignupScreen extends StatefulWidget {
  final userModel.User? user;
  const SignupScreen({Key? key, this.user}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  bool _isLoading = false;
  Uint8List? _image;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _usernameController.text = widget.user?.username ?? "";
      _bioController.text = widget.user?.bio ?? "";
    }
  }

  PhoneAuthCredential? credential;

  Future<bool?> otpVerfication(String otp) async {
    if (kIsWeb) {
      if (confirmationResult != null) {
        try {
          await confirmationResult!.confirm(otp);
          return true;
        } catch (e) {
          showSnackBar(context, e.toString());
        }
      } else {
        showSnackBar(context, "Please verify phone");
      }
    } else {
      if (verificationId.value != null || credential != null) {
        try {
          // Create a PhoneAuthCredential with the code
          credential ??= PhoneAuthProvider.credential(
            verificationId: verificationId.value!,
            smsCode: otp,
          );

          // Sign the user in (or link) with the credential
          await FirebaseAuth.instance.signInWithCredential(credential!);
          await FirebaseAuth.instance.signOut();
          return true;
        } catch (e) {
          showSnackBar(context, e.toString());
        }
      } else {
        showSnackBar(context, "Please verify phone");
      }
    }
    return null;
  }

  void signUpUser() async {
    // set loading to true
    setState(() {
      _isLoading = true;
    });

    // signup user using our authmethodds

    if (await otpVerfication(_otpController.text.trim()) == true) {
      print("Otp verification success");
      String res = await AuthMethods().signUpUser(
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        username: _usernameController.text.trim(),
        bio: _bioController.text.trim(),
        file: _image,
      );
      // if string returned is sucess, user has been created
      if (res == "success") {
        setState(() {
          _isLoading = false;
        });
        // navigate to the home screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const ResponsiveLayout(
              mobileScreenLayout: MobileScreenLayout(),
              webScreenLayout: WebScreenLayout(),
            ),
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        // show the error
        showSnackBar(context, res);
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void updateUser() async {
    // set loading to true
    setState(() {
      _isLoading = true;
    });

    // signup user using our authmethodds

    String res = await AuthMethods().updateUser(
      username: _usernameController.text.trim(),
      bio: _bioController.text.trim(),
      file: _image,
    );
    // if string returned is sucess, user has been created
    if (res == "success") {
      setState(() {
        _isLoading = false;
      });
      // navigate to the home screen
      Navigator.pop(context);
    } else {
      setState(() {
        _isLoading = false;
      });
      showSnackBar(context, res);
    }
  }

  selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    // set state because we need to display the image we selected on the circle avatar
    setState(() {
      _image = im;
    });
  }

  ValueNotifier<bool> isCodeSent = ValueNotifier(false);
  ConfirmationResult? confirmationResult;
  ValueNotifier<String?> verificationId = ValueNotifier(null);

  verifyPhone(String phone) async {
    var phone = _phoneController.text.trim();
    if (phone.isNotEmpty && phone.length == 10) {
      if (kIsWeb) {
        confirmationResult =
            await FirebaseAuth.instance.signInWithPhoneNumber('+91 $phone');
        isCodeSent.value = true;
      } else {
        setState(() {
          _isLoading = true;
        });
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: '+91 $phone',
          codeSent: (String vid, int? resendToken) async {
            isCodeSent.value = true;
            verificationId.value = vid;
          },
          codeAutoRetrievalTimeout: (String veId) {
            verificationId.value = veId;
          },
          verificationCompleted: (PhoneAuthCredential phoneAuthCredential) {
            verificationId.value = phoneAuthCredential.verificationId;
            credential = phoneAuthCredential;
          },
          verificationFailed: (FirebaseAuthException error) {},
        );
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Enter valid phone number!",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Container(),
                flex: 2,
              ),
              SvgPicture.asset(
                'assets/ic_instagram.svg',
                color: primaryColor,
                height: 32,
              ),
              const SizedBox(
                height: 32,
              ),
              Stack(
                children: [
                  _image != null
                      ? CircleAvatar(
                          radius: 64,
                          backgroundImage: MemoryImage(_image!),
                          backgroundColor: Colors.red,
                        )
                      : CircleAvatar(
                          radius: 64,
                          backgroundImage: NetworkImage(widget.user != null &&
                                  widget.user?.photoUrl != null &&
                                  widget.user!.photoUrl.isNotEmpty
                              ? widget.user!.photoUrl
                              : 'https://bugreader.com/i/avatar.jpg'),
                          backgroundColor: Colors.red,
                        ),
                  Positioned(
                    bottom: -10,
                    left: 80,
                    child: IconButton(
                      onPressed: selectImage,
                      icon: const Icon(Icons.add_a_photo),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 24,
              ),
              TextFieldInput(
                hintText: 'Enter your username',
                textInputType: TextInputType.text,
                textEditingController: _usernameController,
              ),
              const SizedBox(
                height: 24,
              ),
              if (widget.user == null)
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFieldInput(
                        hintText: 'Enter your phone',
                        textInputType: TextInputType.phone,
                        textEditingController: _phoneController,
                        maxLength: 10,
                        suffix: InkWell(
                          onTap: () {
                            verifyPhone(_phoneController.text.trim());
                          },
                          child: ValueListenableBuilder(
                            valueListenable: isCodeSent,
                            builder: (context, bool codeSent, child) {
                              return Text(
                                codeSent ? "Resend" : "Verify",
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    ValueListenableBuilder(
                      valueListenable: isCodeSent,
                      builder: (context, bool codeSent, child) {
                        return codeSent
                            ? Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 15.0),
                                  child: TextFieldInput(
                                    hintText: 'Enter OTP',
                                    textInputType:
                                        const TextInputType.numberWithOptions(),
                                    textEditingController: _otpController,
                                    maxLength: 6,
                                  ),
                                ),
                              )
                            : const SizedBox();
                      },
                    ),
                  ],
                ),
              if (widget.user == null)
                const SizedBox(
                  height: 24,
                ),
              if (widget.user == null)
                TextFieldInput(
                  hintText: 'Enter your email',
                  textInputType: TextInputType.emailAddress,
                  textEditingController: _emailController,
                ),
              if (widget.user == null)
                const SizedBox(
                  height: 24,
                ),
              if (widget.user == null)
                TextFieldInput(
                  hintText: 'Enter your password',
                  textInputType: TextInputType.text,
                  textEditingController: _passwordController,
                  isPass: true,
                ),
              if (widget.user == null)
                const SizedBox(
                  height: 24,
                ),
              TextFieldInput(
                hintText: 'Enter your bio',
                textInputType: TextInputType.text,
                textEditingController: _bioController,
              ),
              const SizedBox(
                height: 24,
              ),
              InkWell(
                child: Container(
                  child: !_isLoading
                      ? Text(
                          widget.user != null ? "Update" : 'Sign up',
                        )
                      : const CircularProgressIndicator(
                          color: primaryColor,
                        ),
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    color: blueColor,
                  ),
                ),
                onTap: FirebaseAuth.instance.currentUser != null
                    ? updateUser
                    : signUpUser,
              ),
              const SizedBox(
                height: 12,
              ),
              Flexible(
                child: Container(),
                flex: 2,
              ),
              if (widget.user == null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: const Text(
                        'Already have an account?',
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      ),
                      child: Container(
                        child: const Text(
                          ' Login.',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
