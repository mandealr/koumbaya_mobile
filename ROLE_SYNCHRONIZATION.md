# Synchronisation des Rôles - Mobile & Backend

## Date: 10 Octobre 2025

## Architecture des Rôles

### UserType (Types d'utilisateurs)
1. **Administrateur** (user_type_id = 1) - **NON autorisé dans l'app mobile**
2. **Client** (user_type_id = 2) - **Autorisé dans l'app mobile**
3. **Marchand** (user_type_id = 2) - **Autorisé dans l'app mobile**

### Rôles par UserType

#### 🔴 ADMINISTRATEUR (user_type_id = 1) - BLOQUÉ SUR MOBILE
- **Super Admin** - Accès total au système
- **Admin** - Administration générale
- **Agent** - Support et modération

❌ Ces rôles NE PEUVENT PAS se connecter à l'application mobile

#### ✅ CLIENT (user_type_id = 2) - AUTORISÉ SUR MOBILE
- **Particulier** - Client standard (achat uniquement)
- **Business Individual** - Marchand particulier (achat + vente)
- **Business Enterprise** - Marchand entreprise (achat + vente)

✅ Ces rôles PEUVENT utiliser l'application mobile

---

## Modifications Effectuées

### 1. Modèle Role (`lib/models/role.dart`)

```dart
// Nouveaux getters pour identifier les rôles
bool get isCustomer => name == 'Particulier';
bool get isMerchant => name == 'Business Individual' || name == 'Business Enterprise';
bool get isBusinessIndividual => name == 'Business Individual';
bool get isBusinessEnterprise => name == 'Business Enterprise';
bool get isManager => name == 'Agent' || name == 'Admin' || name == 'Super Admin';
bool get isAdmin => name == 'Admin' || name == 'Super Admin';
bool get isSuperAdmin => name == 'Super Admin';

// Vérification d'autorisation mobile
bool get isAllowedInMobileApp => isCustomer || isMerchant;
```

### 2. Modèle User (`lib/models/user.dart`)

```dart
// Rôles clients (autorisés dans l'app mobile)
bool get isCustomer => hasRole('Particulier');
bool get isMerchant => hasRole('Business Individual') || hasRole('Business Enterprise');
bool get isBusinessIndividual => hasRole('Business Individual');
bool get isBusinessEnterprise => hasRole('Business Enterprise');

// Rôles admin (NON autorisés dans l'app mobile)
bool get isManager => hasRole('Agent') || hasRole('Admin') || hasRole('Super Admin');
bool get isAdmin => hasRole('Admin') || hasRole('Super Admin');
bool get isSuperAdmin => hasRole('Super Admin');

// Vérification d'autorisation mobile
bool get isAllowedInMobileApp {
  return (isCustomer || isMerchant) && !isManager;
}
```

### 3. AuthProvider (`lib/providers/auth_provider.dart`)

#### A. Vérification au Login

```dart
// Dans login() et loginWithIdentifier()
if (!response.user!.isAllowedInMobileApp) {
  _setError('Cette application est réservée aux clients. Veuillez utiliser l\'interface web pour les comptes administrateurs.');
  return false;
}
```

#### B. Vérification au Démarrage (Auto-logout)

```dart
// Dans _checkAuthStatus()
if (!user.isAllowedInMobileApp) {
  await SecureTokenStorage.removeToken();
  _user = null;
  _status = AuthStatus.unauthenticated;
  _setError('Cette application est réservée aux clients.');
  return;
}
```

---

## Comportement de l'Application

### Scénario 1: Login d'un Admin
1. L'utilisateur entre ses identifiants
2. L'API authentifie l'utilisateur
3. L'app détecte un rôle admin (`isAllowedInMobileApp = false`)
4. ❌ **Login refusé** avec message: "Cette application est réservée aux clients"
5. Le token n'est PAS sauvegardé

### Scénario 2: Login d'un Client/Marchand
1. L'utilisateur entre ses identifiants
2. L'API authentifie l'utilisateur
3. L'app détecte un rôle client (`isAllowedInMobileApp = true`)
4. ✅ **Login accepté**
5. Le token est sauvegardé
6. L'utilisateur accède à l'application

### Scénario 3: Admin ayant déjà un token
1. L'app démarre
2. Un token existe en local
3. L'app charge le profil utilisateur via `/me`
4. Détection d'un rôle admin
5. 🚫 **Auto-déconnexion** avec message
6. Le token est supprimé
7. Redirection vers l'écran de login

---

## Ordre de Priorité des Rôles

Lorsqu'un utilisateur a plusieurs rôles, le `primaryRole` suit cet ordre:

1. Super Admin (le plus élevé)
2. Admin
3. Agent
4. Business Enterprise
5. Business Individual
6. Particulier (le plus bas)

---

## Impact sur l'API Backend

L'application mobile envoie les headers suivants:
```
X-Platform: mobile
X-App-Version: 1.0.0
User-Agent: KoumbayaFlutter/1.0.0
```

Le backend DOIT retourner les rôles dans le format suivant:

```json
{
  "user": {
    "id": 123,
    "email": "user@example.com",
    "roles": [
      {
        "id": 1,
        "name": "Particulier",
        "description": "Client standard",
        "active": true,
        "mutable": false,
        "user_type_id": 2
      }
    ],
    "user_type_id": 2
  }
}
```

---

## Tests Requis

### ✅ Tests Fonctionnels

1. **Login avec compte Particulier** ✅
   - Doit fonctionner
   - Token sauvegardé
   - Accès aux fonctionnalités client

2. **Login avec compte Business Individual** ✅
   - Doit fonctionner
   - Token sauvegardé
   - Accès aux fonctionnalités vendeur

3. **Login avec compte Business Enterprise** ✅
   - Doit fonctionner
   - Token sauvegardé
   - Accès aux fonctionnalités vendeur

4. **Login avec compte Admin** ❌
   - Doit être refusé
   - Message d'erreur affiché
   - Pas de token sauvegardé

5. **Login avec compte Agent** ❌
   - Doit être refusé
   - Message d'erreur affiché
   - Pas de token sauvegardé

6. **Login avec compte Super Admin** ❌
   - Doit être refusé
   - Message d'erreur affiché
   - Pas de token sauvegardé

7. **Démarrage app avec token admin** 🚫
   - Auto-déconnexion
   - Token supprimé
   - Redirection login

---

## Migration des Utilisateurs Existants

Si un utilisateur avait l'ancien rôle "Business", il doit être migré vers:
- **Business Individual** - Si vendeur particulier
- **Business Enterprise** - Si vendeur entreprise

Cette migration est gérée côté backend via les seeders.

---

## Notes Importantes

1. **L'app mobile est STRICTEMENT réservée aux clients**
2. **Les admins DOIVENT utiliser l'interface web**
3. **La vérification se fait à 3 niveaux**: Login, Login with identifier, Démarrage app
4. **Le user_type_id est la source de vérité**: 1 = Admin (bloqué), 2 = Client (autorisé)
5. **Les rôles sont cumulatifs**: Un utilisateur peut avoir plusieurs rôles, mais UN SEUL rôle admin suffit à bloquer l'accès mobile

---

## Compatibilité

- ✅ Flutter SDK 3.7.2+
- ✅ Android API 21+
- ✅ iOS 12+
- ✅ Web (avec restrictions)
- ✅ Backend Laravel 12

---

## Auteur

Synchronisation effectuée le 10 Octobre 2025
Architecture: UserType → Role → Privilege
