# Loading Widget Documentation

A comprehensive loading widget system for Flutter applications with multiple display options and customizable messages.

---

## Features

### 1. LoadingWidget (Main Class)

#### Overlay Method
Shows a loading overlay on top of the current screen.

```dart
// Show loading
LoadingWidget.show(context, message: 'Creating account...');

// Hide loading
LoadingWidget.hide();
```

**Use Case:** When you want to block user interaction while a process is running.

---

#### Dialog Method
Shows a loading dialog that can be dismissed.

```dart
// Show loading dialog
LoadingWidget.showDialog(context, message: 'Processing...');

// Hide loading dialog
LoadingWidget.hideDialog(context);
```

**Use Case:** When you want a more prominent loading indicator with backdrop.

---

### 2. LoadingIndicator (Inline Widget)

For use within your existing widgets as a component.

```dart
LoadingIndicator(
  message: 'Loading data...',
  size: 40,
  color: Colors.blue,
)
```

**Parameters:**
- `message` (String?): Optional loading message
- `size` (double): Size of the loading indicator (default: 40)
- `color` (Color?): Color of the loading indicator

**Use Case:** When you need a loading indicator within a specific widget or section.

---

### 3. FullScreenLoading (Full Screen Widget)

For full-screen loading pages.

```dart
FullScreenLoading(message: 'Setting up your account...')
```

**Parameters:**
- `message` (String?): Loading message to display

**Use Case:** When transitioning between major screens or during app initialization.

---

## Usage Examples

### Example 1: SignUp Screen with Loading

```dart
onPressed: () async {
  if (_key.currentState!.validate()) {
    // Show loading
    LoadingWidget.show(context, message: 'Creating account...');
    
    try {
      // Your sign up logic here
      await userService.signUp(email, password);
      
      // Hide loading
      LoadingWidget.hide();
      
      // Navigate to home screen
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      LoadingWidget.hide();
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign up failed: ${e.toString()}')),
      );
    }
  }
}
```

---

### Example 2: API Call with Loading Dialog

```dart
Future<void> fetchData() async {
  LoadingWidget.showDialog(context, message: 'Fetching data...');
  
  try {
    final data = await apiService.getData();
    LoadingWidget.hideDialog(context);
    
    setState(() {
      this.data = data;
    });
  } catch (e) {
    LoadingWidget.hideDialog(context);
    print('Error: $e');
  }
}
```

---

### Example 3: Inline Loading in ListView

```dart
Widget build(BuildContext context) {
  return ListView(
    children: [
      if (isLoading)
        LoadingIndicator(
          message: 'Loading items...',
          size: 50,
        )
      else
        ...itemWidgets,
    ],
  );
}
```

---

### Example 4: Full Screen Loading on App Start

```dart
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.delayed(Duration(seconds: 2));
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return FullScreenLoading(
      message: 'Initializing Coffee Management...',
    );
  }
}
```

---

## Design Features

All loading widgets match your app's design theme:
- ✅ Coffee icon integration
- ✅ Blue gradient colors (#3B82F6)
- ✅ Rounded corners and shadows
- ✅ Google Fonts (Inter) typography
- ✅ Consistent spacing and sizing

---

## Best Practices

### 1. Always Hide Loading
```dart
try {
  LoadingWidget.show(context);
  await someOperation();
} finally {
  LoadingWidget.hide(); // Always hide, even on error
}
```

### 2. Provide Meaningful Messages
```dart
// ✅ Good
LoadingWidget.show(context, message: 'Creating your account...');

// ❌ Avoid
LoadingWidget.show(context, message: 'Loading...');
```

### 3. Use Appropriate Loading Type
- **Overlay**: Short operations (< 3 seconds)
- **Dialog**: Medium operations with user awareness
- **Full Screen**: App initialization, major transitions
- **Inline**: List loading, partial page updates

### 4. Handle Errors Gracefully
```dart
try {
  LoadingWidget.show(context, message: 'Saving...');
  await saveData();
  LoadingWidget.hide();
  showSuccess();
} catch (e) {
  LoadingWidget.hide();
  showError(e);
}
```

---

## Customization

You can customize colors and styles in the `LoadingWidget` class:

```dart
// Change primary color
Color(0xFF3B82F6) → Color(0xFFYourColor)

// Change icon
Icons.coffee_rounded → Icons.your_icon

// Adjust sizes
width: 60 → width: 80
```

---

## Dependencies

Required packages:
```yaml
dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^latest_version
```

---

## Notes

- The overlay method uses `OverlayEntry` for better performance
- Dialog method uses `showGeneralDialog` for more control
- All loading states are dismissible programmatically
- Loading widgets are null-safe and support Flutter 3.0+

---

## Support

For issues or questions, please refer to the project documentation or contact the development team.