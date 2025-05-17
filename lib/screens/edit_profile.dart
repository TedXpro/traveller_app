// File: edit_profile_page.dart
// Description: This page allows users to view and edit their profile information
// and change their password, including uploading a profile picture using multipart form data.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traveller_app/models/change_credentials.dart';
import 'package:traveller_app/models/user.dart';
import 'package:traveller_app/models/user_profile.dart'; // Still used for data structure, but not directly sent as JSON body
import 'package:traveller_app/providers/user_provider.dart';
import 'package:traveller_app/services/user_api_services.dart'; // Assuming UserService is here
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'dart:io'; // Import for File
import 'package:http/http.dart' as http; // Import http for MultipartRequest
import 'package:traveller_app/constants/api_constants.dart'; // Assuming baseUrl is here

class EditProfilePage extends StatefulWidget {
  final User user;

  const EditProfilePage({super.key, required this.user});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNumberController;

  bool _showPasswordFields = false;
  late TextEditingController _oldPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  bool _isSaving = false;
  bool _isChangingPassword = false;
  File? _selectedImage; // Variable to hold the selected image file
  bool _isPickingImage = false; // Loading state for image picking

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneNumberController = TextEditingController(
      text: widget.user.phoneNumber,
    );

    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _phoneNumberError;
  String? _passwordError;

  // Helper to build text fields
  Widget _buildTextField(
    TextEditingController controller,
    String labelText, {
    TextInputType keyboardType = TextInputType.text,
    String? errorText,
    bool obscureText = false,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          errorText: errorText,
        ),
      ),
    );
  }

  // Method to pick an image from the gallery or camera
  Future<void> _pickImage() async {
    if (_isPickingImage) return; // Prevent multiple pick attempts

    if (mounted) {
      setState(() {
        _isPickingImage = true; // Set loading state for image picking
      });
    }

    final ImagePicker picker = ImagePicker();
    try {
      // Show a dialog to choose between gallery and camera
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: Text(
                    AppLocalizations.of(context)!.gallery,
                  ), // Localize
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: Text(AppLocalizations.of(context)!.camera), // Localize
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
              ],
            ),
          );
        },
      );

      if (source == null) {
        // User cancelled the picker
        if (mounted) {
          setState(() {
            _isPickingImage = false; // Clear loading state
          });
        }
        return;
      }

      final XFile? pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        if (mounted) {
          setState(() {
            _selectedImage = File(pickedFile.path); // Store the selected file
            _isPickingImage = false; // Clear loading state
          });
          // Optionally show a success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.imageSelected,
              ), // Localize
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // User didn't pick an image
        if (mounted) {
          setState(() {
            _isPickingImage = false; // Clear loading state
          });
        }
        print('No image selected.');
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        setState(() {
          _isPickingImage = false; // Clear loading state on error
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.failedToPickImage(e.toString()),
            ), // Localize
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _saveChanges() async {
    setState(() {
      _phoneNumberError = null;
    });

    if (_phoneNumberController.text.isEmpty) {
      setState(() {
        _phoneNumberError =
            AppLocalizations.of(context)!.pleaseEnterPhoneNumber;
      });
      return;
    }

    if (_isSaving) return;

    if (mounted) {
      setState(() {
        _isSaving = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.savingChanges),
          duration: const Duration(seconds: 10),
        ),
      );
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final jwtToken = userProvider.jwtToken;

    if (jwtToken == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.loginRequiredForSavingProfile,
            ),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isSaving = false;
        });
      }
      // TODO: Redirect to login if token is missing
      return;
    }

    // --- START: Construct and Send Multipart Request ---
    final uri = Uri.parse('$baseUrl/user/edit'); // Your backend endpoint
    final request = http.MultipartRequest('PUT', uri); // Use PUT method

    // Add JWT token to headers for authentication
    request.headers['Authorization'] = 'Bearer $jwtToken';

    // Add text fields as form fields
    request.fields['id'] = widget.user.id!; // User ID is required by backend
    request.fields['first_name'] = _firstNameController.text.trim();
    request.fields['last_name'] = _lastNameController.text.trim();
    // Add phone number if your backend expects it here
    request.fields['phone_number'] = _phoneNumberController.text.trim();

    // Add favourite agencies if your backend expects them here as an array
    // You might need to adjust how you get and send this data based on your UI
    // Example if favouriteAgencies is a List<String> in your User model:
    // for (var agencyId in widget.user.favouriteAgencies ?? []) {
    //    request.fields['favourite_agencies[]'] = agencyId; // Use [] for array
    // }

    // Add the profile photo file if selected
    if (_selectedImage != null) {
      try {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_photo', // This key must match the backend's FormFile key (ctx.FormFile("profile_photo"))
            _selectedImage!.path,
          ),
        );
      } catch (e) {
        print('Error adding image file to request: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(
                  context,
                )!.failedToUploadImageParam('Error preparing image for upload.'),
              ), // Localize
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isSaving = false; // Clear saving state
          });
        }
        return; // Stop the save process if file preparation fails
      }
    }

    // Send the request
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Edit Profile API Response Status: ${response.statusCode}');
      print('Edit Profile API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Assuming backend returns a success message or updated user data on 200
        // Refetch user data to update the UI with the new profile photo URL and other changes
        final userService = UserService(); // Instantiate UserService if needed
        final fetchedUser = await userService.getUserData(
          widget.user.id.toString(),
          jwtToken,
        );

        if (mounted) {
          if (fetchedUser != null) {
            await Provider.of<UserProvider>(
              context,
              listen: false,
            ).setUserDataAndToken(fetchedUser, jwtToken);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.profileUpdatedSuccessfully,
                ),
                backgroundColor: Colors.green,
              ),
            );
            // Clear the selected image after successful save
            setState(() {
              _selectedImage = null;
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.paymentError(
                    'Profile updated successfully, but failed to refetch data.',
                  ),
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } else {
        // Handle non-200 status codes (e.g., validation errors from backend)
        String errorMessage = AppLocalizations.of(
          context,
        )!.failedToUpdateProfile('Unknown error'); // Default error

        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          if (errorData.containsKey('error')) {
            errorMessage = AppLocalizations.of(context)!.failedToUpdateProfile(
              errorData['error'],
            ); // Use backend error message
          }
        } catch (e) {
          print('Failed to parse error response body: $e');
          // Keep default error message if parsing fails
        }

        if (mounted) {
          // setState(() {
          //   _phoneNumberError = errorMessage; // You might need more specific error handling based on backend response
          // });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      print('Error sending multipart request: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.failedToUpdateProfile(e.toString()),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).hideCurrentSnackBar(); // Hide loading snackbar
        setState(() {
          _isSaving = false;
        });
      }
    }
    // --- END: Construct and Send Multipart Request ---
  }

  void _changePassword() async {
    setState(() {
      _passwordError = null;
    });

    if (_newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _oldPasswordController.text.isEmpty) {
      setState(() {
        _passwordError =
            AppLocalizations.of(context)!.pleaseFillAllPasswordFields;
      });
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _passwordError = AppLocalizations.of(context)!.passwordsDoNotMatch;
      });
      return;
    }

    if (_isChangingPassword) return;

    if (mounted) {
      setState(() {
        _isChangingPassword = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.changingPassword),
          duration: const Duration(seconds: 10),
        ),
      );
    }

    final changeCredential = ChangeCredential(
      email: widget.user.email,
      oldPassword: _oldPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    final userService = UserService();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final jwtToken = userProvider.jwtToken;

    if (jwtToken == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.loginRequiredForPasswordChange,
            ),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isChangingPassword = false;
        });
      }
      // TODO: Redirect to login if token is missing
      return;
    }

    final errorMessage = await userService.changeUserCredential(
      changeCredential,
      jwtToken,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      setState(() {
        _isChangingPassword = false;
      });
    }

    if (errorMessage == null) {
      // Refetch user data after password change (optional, but good practice)
      final fetchedUser = await userService.getUserData(
        widget.user.id.toString(),
        jwtToken,
      );

      if (mounted) {
        if (fetchedUser != null) {
          await Provider.of<UserProvider>(
            context,
            listen: false,
          ).setUserDataAndToken(fetchedUser, jwtToken);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.passwordChangedSuccessfully,
              ),
              backgroundColor: Colors.green,
            ),
          );

          _oldPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
          setState(() {
            _showPasswordFields = false;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.paymentError(
                  'Password changed successfully, but failed to refetch user data.',
                ),
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _passwordError = errorMessage;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              )!.failedToChangePassword(errorMessage),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editProfile)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Profile Picture Area
            GestureDetector(
              onTap:
                  _isPickingImage
                      ? null
                      : _pickImage, // Disable tap while picking
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    // Display selected image or existing profile photo
                    backgroundImage:
                        _selectedImage != null
                            ? FileImage(_selectedImage!)
                                as ImageProvider<Object>?
                            : (widget.user.profilePhoto != null &&
                                    widget.user.profilePhoto!.isNotEmpty
                                ? NetworkImage(widget.user.profilePhoto!)
                                : null), // Use NetworkImage for existing URL
                    child:
                        _selectedImage == null &&
                                (widget.user.profilePhoto == null ||
                                    widget.user.profilePhoto!.isEmpty)
                            ? Icon(
                              Icons.person,
                              size: 70,
                              color: theme.colorScheme.onSurfaceVariant,
                            ) // Default icon if no photo
                            : null, // No default icon if there's a photo
                  ),
                  // Show a loading indicator while picking image
                  if (_isPickingImage)
                    CircularProgressIndicator(color: theme.colorScheme.primary),
                  // Add an edit icon
                  if (!_isPickingImage) // Hide edit icon while picking
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: theme.colorScheme.primary,
                        child: Icon(
                          Icons.edit,
                          size: 20,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildTextField(_firstNameController, l10n.firstName),
            _buildTextField(_lastNameController, l10n.lastName),
            _buildTextField(
              _emailController,
              l10n.email,
              keyboardType: TextInputType.emailAddress,
              enabled: false, // Email is usually not editable
            ),
            _buildTextField(
              _phoneNumberController,
              l10n.phoneNumber,
              keyboardType: TextInputType.phone,
              errorText: _phoneNumberError,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showPasswordFields = !_showPasswordFields;
                  if (!_showPasswordFields) {
                    _oldPasswordController.clear();
                    _newPasswordController.clear();
                    _confirmPasswordController.clear();
                    _passwordError = null;
                  }
                });
              },
              child: Text(
                _showPasswordFields
                    ? l10n
                        .hidePasswordChange // Localize
                    : l10n.changePassword, // Localize
              ),
            ),
            if (_showPasswordFields) ...[
              const SizedBox(height: 10),
              _buildTextField(
                _oldPasswordController,
                l10n.oldPassword, // Localize
                obscureText: true,
              ),
              _buildTextField(
                _newPasswordController,
                l10n.newPassword, // Localize
                obscureText: true,
              ),
              _buildTextField(
                _confirmPasswordController,
                l10n.confirmNewPassword, // Localize
                obscureText: true,
                errorText: _passwordError,
              ),
              const SizedBox(height: 20),
              _isChangingPassword
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: _changePassword,
                    child: Text(l10n.changePassword), // Localize
                  ),
            ],
            const SizedBox(height: 40),
            _isSaving
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    textStyle: theme.textTheme.titleMedium,
                  ),
                  child: Text(l10n.saveChanges), // Localize
                ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
