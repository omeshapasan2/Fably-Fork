# Fably - Smart Fashion AR Application

Fably is an innovative Flutter-based fashion application that leverages Augmented Reality (AR) to revolutionize the way users visualize and choose clothing. Using advanced 3D body scanning technology, the app creates personalized virtual models for accurate clothing visualization and style recommendations.

## 🎯 Core Features

- **3D Body Scanning & Modeling**
  - Precise body measurements through multi-angle photography
  - Creation of personalized 3D avatar
  - Accurate body type analysis

- **Virtual Try-On**
  - Real-time clothing visualization on 3D model
  - Multiple outfit combinations
  - Accurate fabric draping and physics
  - 360° view of outfits

- **Style Recommendations**
  - Personalized clothing suggestions based on body type
  - Color palette recommendations
  - Outfit combination assistance
  - Couple matching suggestions (upcoming feature)

## Prerequisites

Before running the application, ensure you have the following installed:

- Flutter SDK (version ^3.6.0)
- Dart SDK 
- Android Studio / Xcode (for iOS development)
- Firebase account and project setup
- Camera-enabled device/emulator (min SDK 23 for Android)

## Environment Setup

### 1. Flutter Setup
```bash
# Install Flutter following official documentation
# https://flutter.dev/docs/get-started/install

# Verify installation
flutter doctor
```

### 2. Firebase Configuration
- Create a new Firebase project
- Add Android/iOS apps to your Firebase project
- Download and place configuration files:
  - Android: `google-services.json` in `android/app/`
  - iOS: `GoogleService-Info.plist` in iOS project

## Project Setup

1. Clone and setup the repository:
```bash
# Clone repository
git clone [repository-url]
cd fably

# Install dependencies
flutter pub get
```

2. Configure Firebase:
   - Enable Authentication in Firebase Console
   - Set up Email/Password and Google Sign-in methods

## Required Permissions

### Android
Add to `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

### iOS
Add to `Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access for body scanning and measurements</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app requires access to photo library for saving your fashion choices</string>
```

## Project Structure
```
fably/
├── lib/                              # Main source code directory
│   ├── screens/                      # UI screens and views
│   │   ├── auth/                    # Authentication related screens
│   │   │   ├── auth_widget.dart     # Reusable auth UI components
│   │   │   ├── login.dart          # Login screen implementation
│   │   │   └── register.dart       # Registration screen implementation
│   │   ├── gender/                  # Gender selection feature
│   │   │   └── gender_selection.dart # Gender selection screen
│   │   ├── home/                    # Main app screens
│   │   │   └── home.dart           # Home screen implementation
│   │   └── scanner/                 # Body scanning feature
│   │       ├── camera.dart         # Camera handling and capture
│   │       └── scanner.dart        # Scanning interface and logic
│   ├── utils/                        # Utility functions and helpers
│   │   └── user_preferences.dart    # User preferences management
│   └── main.dart                    # Application entry point
├── assets/                          # Static assets directory
│   └── Gif_fably.gif               # Loading/intro animation
├── fonts/                           # Custom fonts
│   ├── Italiana-Regular.ttf         # Italiana font for headings
│   └── Jura-Regular.ttf            # Jura font for body text
├── android/                         # Android platform code
│   └── app/
│       └── src/
│           └── main/
│               └── AndroidManifest.xml  # Android configuration
├── ios/                             # iOS platform code
├── test/                            # Test files directory
├── pubspec.yaml                     # Project dependencies and config
└── README.md                        # Project documentation
```

## Features

### Core Functionality
- Advanced Body Scanning
  - Multi-angle photo capture
  - Accurate measurements calculation
  - Body type analysis

- Virtual Fitting Room
  - Real-time clothing visualization
  - Fabric simulation
  - Mix and match capabilities

- Style Assistant
  - Body-type based recommendations
  - Occasion-based outfit suggestions
  - Color coordination advice

### Technical Features
- Firebase Authentication (Email & Google Sign-in)
- Local data persistence
- Camera integration
- AR implementation
- Dark theme support

## Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_auth: ^5.3.4
  firebase_core: ^3.9.0
  google_sign_in: ^5.2.1
  camera: ^0.10.5+9
  image_picker: ^1.0.7
  shared_preferences: ^2.0.0
  arcore_flutter_plugin: ^0.1.0  # For Android AR
  arkit_plugin: ^1.0.5  # For iOS AR
  sceneform_flutter: ^0.1.0  # 3D model rendering
```

## Troubleshooting

### Camera and Scanning Issues
- Ensure all camera permissions are granted
- Verify adequate lighting conditions
- Check device compatibility (minimum SDK 23 for Android)
- Ensure sufficient device storage

### AR Implementation Issues
- Verify ARCore/ARKit support on device
- Check camera calibration
- Ensure stable internet connection for model downloads

### Firebase Issues
- Verify configuration files placement
- Check Firebase console settings
- Confirm authentication methods activation

## Development Guidelines

### Code Style
- Follow Flutter's official style guide
- Use meaningful variable and function names
- Comment complex AR and measurement algorithms
- Document API endpoints and models

### Performance Considerations
- Optimize 3D model loading
- Cache frequently used assets
- Implement lazy loading for clothing catalog
- Minimize network requests

## Future Updates
- Couple matching feature
- Social sharing capabilities
- Advanced style recommendations
- Wardrobe organization tools
- Shopping integration

## Contributing
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License
[Add your license information here]

## Contact
Project Link: [repository-url]

## Acknowledgments
- Flutter team for the framework
- ARCore/ARKit for AR capabilities
- Firebase for backend services