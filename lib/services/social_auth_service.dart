import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter/foundation.dart';

class SocialAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Sign in with Google
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Return the tokens
      return {
        'provider': 'google',
        'id_token': googleAuth.idToken,
        'access_token': googleAuth.accessToken,
        'email': googleUser.email,
        'name': googleUser.displayName,
        'photo': googleUser.photoUrl,
      };
    } catch (error) {
      debugPrint('Error signing in with Google: $error');
      rethrow;
    }
  }

  /// Sign in with Facebook
  Future<Map<String, dynamic>?> signInWithFacebook() async {
    try {
      // Trigger the Facebook login flow
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        // Get the access token
        final AccessToken accessToken = result.accessToken!;

        // Get user data
        final userData = await FacebookAuth.instance.getUserData(
          fields: 'id,name,email,picture.width(200)',
        );

        return {
          'provider': 'facebook',
          'access_token': accessToken.token,
          'email': userData['email'],
          'name': userData['name'],
          'photo': userData['picture']?['data']?['url'],
        };
      } else if (result.status == LoginStatus.cancelled) {
        // User canceled the sign-in
        return null;
      } else {
        throw Exception('Facebook login failed: ${result.message}');
      }
    } catch (error) {
      debugPrint('Error signing in with Facebook: $error');
      rethrow;
    }
  }

  /// Sign out from Google
  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (error) {
      debugPrint('Error signing out from Google: $error');
    }
  }

  /// Sign out from Facebook
  Future<void> signOutFacebook() async {
    try {
      await FacebookAuth.instance.logOut();
    } catch (error) {
      debugPrint('Error signing out from Facebook: $error');
    }
  }

  /// Sign out from all social providers
  Future<void> signOutAll() async {
    await Future.wait([
      signOutGoogle(),
      signOutFacebook(),
    ]);
  }
}
