import 'package:flutter/foundation.dart';
import '../models/country.dart';
import '../models/language.dart';
import '../services/api_service.dart';

class AppProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Country> _countries = [];
  List<Language> _languages = [];
  Country? _selectedCountry;
  Language? _selectedLanguage;
  
  bool _isCountriesLoading = false;
  bool _isLanguagesLoading = false;
  String? _errorMessage;

  // Getters
  List<Country> get countries => _countries;
  List<Language> get languages => _languages;
  Country? get selectedCountry => _selectedCountry;
  Language? get selectedLanguage => _selectedLanguage;
  
  bool get isCountriesLoading => _isCountriesLoading;
  bool get isLanguagesLoading => _isLanguagesLoading;
  String? get errorMessage => _errorMessage;

  AppProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.wait([
      loadCountries(),
      loadLanguages(),
    ]);
    
    // Charger la langue par défaut après avoir chargé toutes les langues
    await loadDefaultLanguage();
  }

  // Countries Methods
  Future<void> loadCountries() async {
    try {
      _setCountriesLoading(true);
      _clearError();

      _countries = await _apiService.getCountries();
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setCountriesLoading(false);
    }
  }

  void selectCountry(Country? country) {
    _selectedCountry = country;
    notifyListeners();
  }

  // Languages Methods
  Future<void> loadLanguages() async {
    try {
      _setLanguagesLoading(true);
      _clearError();

      _languages = await _apiService.getLanguages();
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLanguagesLoading(false);
    }
  }

  Future<void> loadDefaultLanguage() async {
    // Si on a déjà des langues chargées, essayer de trouver le français par défaut
    if (_languages.isNotEmpty) {
      // Chercher d'abord le français dans la liste
      Language? frenchLang;
      try {
        frenchLang = _languages.firstWhere((lang) => 
          lang.code.toLowerCase() == 'fr' || 
          lang.name.toLowerCase().contains('français'));
      } catch (e) {
        // Si pas de français trouvé, prendre la première langue
        frenchLang = _languages.first;
      }
      
      _selectedLanguage = frenchLang;
      notifyListeners();
      debugPrint('Langue par défaut sélectionnée localement: ${frenchLang.name}');
      return;
    }

    // Si pas de langues chargées, essayer d'initialiser les langues par défaut sur le serveur
    try {
      debugPrint('Tentative d\'initialisation des langues par défaut...');
      await _apiService.initializeLanguages();
      
      // Recharger les langues après initialisation
      await loadLanguages();
      
      // Maintenant essayer de sélectionner la langue par défaut
      if (_languages.isNotEmpty) {
        Language? frenchLang;
        try {
          frenchLang = _languages.firstWhere((lang) => 
            lang.code.toLowerCase() == 'fr' || 
            lang.name.toLowerCase().contains('français'));
        } catch (e) {
          frenchLang = _languages.first;
        }
        
        _selectedLanguage = frenchLang;
        notifyListeners();
        debugPrint('Langue par défaut sélectionnée après initialisation: ${frenchLang.name}');
        return;
      }
    } catch (initError) {
      debugPrint('Erreur lors de l\'initialisation des langues: $initError');
    }

    // Fallback: essayer l'API directement si l'initialisation échoue
    try {
      final defaultLanguage = await _apiService.getDefaultLanguage();
      _selectedLanguage = defaultLanguage;
      notifyListeners();
      debugPrint('Langue par défaut chargée depuis API: ${defaultLanguage.name}');
    } catch (e) {
      debugPrint('Erreur lors du chargement de la langue par défaut: $e');
      // En cas d'erreur totale, créer une langue par défaut en dur
      _selectedLanguage = Language(
        id: -1,
        name: 'Français',
        code: 'fr',
        nativeName: 'Français',
        isActive: true,
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      notifyListeners();
      debugPrint('Langue par défaut créée en dur: Français');
    }
  }

  void selectLanguage(Language? language) {
    _selectedLanguage = language;
    notifyListeners();
  }

  // Utility Methods
  Country? getCountryById(int id) {
    try {
      return _countries.firstWhere((country) => country.id == id);
    } catch (e) {
      return null;
    }
  }

  Language? getLanguageById(int id) {
    try {
      return _languages.firstWhere((language) => language.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Country> searchCountries(String query) {
    if (query.isEmpty) return _countries;
    
    return _countries.where((country) {
      return country.name.toLowerCase().contains(query.toLowerCase()) ||
             country.isoCode2.toLowerCase().contains(query.toLowerCase()) ||
             country.isoCode3.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  void _setCountriesLoading(bool loading) {
    _isCountriesLoading = loading;
    notifyListeners();
  }

  void _setLanguagesLoading(bool loading) {
    _isLanguagesLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _getErrorMessage(dynamic error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Une erreur inattendue s\'est produite';
  }
}