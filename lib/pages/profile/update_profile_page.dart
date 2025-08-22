import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../models/country.dart';
import '../../models/language.dart';
import '../../providers/auth_provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_constants.dart';
import '../../services/api_service.dart';
import '../../widgets/loading_widget.dart';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessEmailController = TextEditingController();
  final _businessDescriptionController = TextEditingController();

  bool _isLoading = false;
  List<Country> _countries = [];
  List<Language> _languages = [];
  Country? _selectedCountry;
  Language? _selectedLanguage;
  String _completePhoneNumber = '';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _businessNameController.dispose();
    _businessEmailController.dispose();
    _businessDescriptionController.dispose();
    super.dispose();
  }

  void _initializeData() async {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _emailController.text = user.email;
      _addressController.text = user.address ?? '';
      _cityController.text = user.city ?? '';
      _businessNameController.text = user.businessName ?? '';
      _businessEmailController.text = user.businessEmail ?? '';
      _businessDescriptionController.text = user.businessDescription ?? '';
      _completePhoneNumber = user.phone ?? '';
      _selectedCountry = user.country;
      _selectedLanguage = user.language;
    }

    await _loadCountriesAndLanguages();
  }

  Future<void> _loadCountriesAndLanguages() async {
    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      final countriesFuture = apiService.getCountries();
      final languagesFuture = apiService.getLanguages();

      final results = await Future.wait([countriesFuture, languagesFuture]);

      setState(() {
        _countries = results[0] as List<Country>;
        _languages = results[1] as List<Language>;
      });
    } catch (e) {
      _showErrorMessage('Erreur lors du chargement des données: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Modifier le profil', style: AppTextStyles.appBarTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.go('/profile');
          },
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: const Text(
              'Sauvegarder',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body:
          _isLoading
              ? const LoadingWidget()
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileImageSection(),
                      const SizedBox(height: 24),
                      _buildPersonalInfoSection(),
                      const SizedBox(height: 24),
                      _buildAddressSection(),
                      const SizedBox(height: 24),
                      _buildBusinessInfoSection(),
                      const SizedBox(height: 24),
                      _buildLocationSection(),
                      const SizedBox(height: 32),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildProfileImageSection() {
    final user = context.watch<AuthProvider>().user;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    child:
                        user != null
                            ? Text(
                              '${user.firstName[0]}${user.lastName[0]}',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            )
                            : const Icon(Icons.person, size: 50),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: _changeProfileImage,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${user?.firstName ?? ''} ${user?.lastName ?? ''}',
                style: const TextStyle(
                  fontFamily: 'AmazonEmberDisplay',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                user?.email ?? '',
                style: TextStyle(
                  fontFamily: 'AmazonEmberDisplay',
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return _buildSection('Informations personnelles', [
      Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _firstNameController,
              decoration: _inputDecoration('Prénom', Icons.person),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le prénom est requis';
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: _lastNameController,
              decoration: _inputDecoration('Nom', Icons.person_outline),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le nom est requis';
                }
                return null;
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _emailController,
        decoration: _inputDecoration('Email', Icons.email),
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'L\'email est requis';
          }
          if (!RegExp(r'^[\w\-\.\+]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return 'Format d\'email invalide';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      IntlPhoneField(
        decoration: InputDecoration(
          labelText: 'Téléphone',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          labelStyle: const TextStyle(
            fontFamily: 'AmazonEmberDisplay',
            color: Color(0xFF5f5f5f),
          ),
        ),
        initialCountryCode: 'GA', // Gabon par défaut
        initialValue:
            _completePhoneNumber.isNotEmpty ? _completePhoneNumber : null,
        onChanged: (phone) {
          _completePhoneNumber = phone.completeNumber;
        },
        validator: (phone) {
          // Téléphone optionnel
          return null;
        },
      ),
    ]);
  }

  Widget _buildAddressSection() {
    return _buildSection('Adresse', [
      TextFormField(
        controller: _addressController,
        decoration: _inputDecoration('Adresse', Icons.location_on),
        maxLines: 2,
        validator: (value) {
          // Adresse optionnelle
          return null;
        },
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _cityController,
        decoration: _inputDecoration('Ville', Icons.location_city),
        validator: (value) {
          // Ville optionnelle
          return null;
        },
      ),
    ]);
  }

  Widget _buildBusinessInfoSection() {
    final user = context.watch<AuthProvider>().user;

    // N'afficher cette section que pour les comptes business
    if (user?.isMerchant != true) {
      return const SizedBox.shrink();
    }

    return _buildSection('Informations Business', [
      TextFormField(
        controller: _businessNameController,
        decoration: _inputDecoration('Nom de l\'entreprise', Icons.business),
        validator: (value) {
          // Obligatoire pour les comptes business
          if (user?.isMerchant == true && (value == null || value.isEmpty)) {
            return 'Le nom de l\'entreprise est requis';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _businessEmailController,
        decoration: _inputDecoration(
          'Email professionnel',
          Icons.alternate_email,
        ),
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value != null && value.isNotEmpty) {
            if (!RegExp(
              r'^[\w\-\.\+]+@([\w-]+\.)+[\w-]{2,4}$',
            ).hasMatch(value)) {
              return 'Format d\'email invalide';
            }
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _businessDescriptionController,
        decoration: _inputDecoration(
          'Description de l\'entreprise',
          Icons.description,
        ),
        maxLines: 3,
        validator: (value) {
          // Description optionnelle
          return null;
        },
      ),
    ]);
  }

  Widget _buildLocationSection() {
    return _buildSection('Localisation et préférences', [
      DropdownButtonFormField<Country>(
        value: _selectedCountry,
        decoration: _inputDecoration('Pays', Icons.flag),
        isExpanded: true,
        items:
            _countries.map((country) {
              return DropdownMenuItem<Country>(
                value: country,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (country.flag != null) ...[
                      Image.network(
                        country.flag!,
                        width: 24,
                        height: 18,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                const Icon(Icons.flag, size: 18),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        country.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        onChanged: (country) {
          setState(() => _selectedCountry = country);
        },
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<Language>(
        value: _selectedLanguage,
        decoration: _inputDecoration('Langue', Icons.language),
        items:
            _languages.map((language) {
              return DropdownMenuItem<Language>(
                value: language,
                child: Text(language.name),
              );
            }).toList(),
        onChanged: (language) {
          setState(() => _selectedLanguage = language);
        },
      ),
    ]);
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'AmazonEmberDisplay',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
                _isLoading
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : const Text(
                      'Sauvegarder les modifications',
                      style: TextStyle(
                        fontFamily: 'AmazonEmberDisplay',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: _isLoading ? null : () {
              context.go('/profile');
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Annuler',
              style: TextStyle(
                fontFamily: 'AmazonEmberDisplay',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      filled: true,
      fillColor: Colors.grey[50],
      labelStyle: const TextStyle(
        fontFamily: 'AmazonEmberDisplay',
        color: Color(0xFF5f5f5f), // Couleur #5f5f5f pour les labels
      ),
      hintStyle: const TextStyle(
        color: Color(0xFF5f5f5f), // Couleur #5f5f5f pour le texte saisi
      ),
    );
  }

  void _changeProfileImage() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Prendre une photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _showInfoMessage('Fonctionnalité à venir !');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choisir depuis la galerie'),
                  onTap: () {
                    Navigator.pop(context);
                    _showInfoMessage('Fonctionnalité à venir !');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Supprimer la photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _showInfoMessage('Fonctionnalité à venir !');
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Prepare update data
      final updateData = {
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'email': _emailController.text,
        'phone': _completePhoneNumber.isEmpty ? null : _completePhoneNumber,
        'address':
            _addressController.text.isEmpty ? null : _addressController.text,
        'city': _cityController.text.isEmpty ? null : _cityController.text,
        'business_name':
            _businessNameController.text.isEmpty
                ? null
                : _businessNameController.text,
        'business_email':
            _businessEmailController.text.isEmpty
                ? null
                : _businessEmailController.text,
        'business_description':
            _businessDescriptionController.text.isEmpty
                ? null
                : _businessDescriptionController.text,
        'country_id': _selectedCountry?.id,
        'language_id': _selectedLanguage?.id,
      };

      // Update profile via AuthProvider
      await context.read<AuthProvider>().updateProfile(updateData);

      if (mounted) {
        _showSuccessMessage('Profil mis à jour avec succès !');
        // Attendre un peu avant de fermer pour laisser le temps au message de s'afficher
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            context.go('/profile');
          }
        });
      }
    } catch (e) {
      _showErrorMessage('Erreur lors de la mise à jour: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: AppConstants.primaryColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showInfoMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
