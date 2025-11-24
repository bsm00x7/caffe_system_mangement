# ☕ Café Management System

> A modern Flutter mobile application for streamlined café operations with admin panel and employer interface.

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase)](https://supabase.com)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/yourusername/cafe-management)
[![License](https://img.shields.io/badge/license-Proprietary-red.svg)](LICENSE)

---

## 📋 Overview

The Café Management System is a comprehensive mobile solution designed to eliminate manual management inefficiencies. It provides separate interfaces for administrators and employers, enabling real-time inventory tracking, purchase management, and business analytics.

**Problem Solved:** Manual café operations lead to stock discrepancies, time waste, and limited insights.

**Solution:** Modern mobile app with cloud sync, real-time updates, and actionable analytics.

---

## ✨ Features

### 👨‍💼 For Administrators

- 📊 **Real-time Dashboard** - Sales statistics, charts, and KPIs
- 👥 **User Management** - Create/edit/delete employers with role-based access
- 📦 **Inventory Control** - Full CRUD operations for products
- 📸 **Image Upload** - Camera and gallery integration for product photos
- 🔍 **Search & Filter** - Quick access to users and items
- 💰 **Sales Tracking** - Monitor purchases and revenue
- 🔔 **Low Stock Alerts** - Automatic notifications
- 📈 **Analytics Charts** - Visual data representation

### 👨‍💻 For Employers

- 🛒 **Shopping Cart** - Modern e-commerce experience
- 📱 **Product Catalog** - Browse items with images and prices
- 💳 **Quick Checkout** - One-tap purchase submission
- 📊 **Stock Visibility** - Real-time availability status
- 📝 **Purchase History** - Track your orders

---

## 🚀 Quick Start

### Prerequisites

- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- Supabase account
- Android Studio or VS Code

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/cafe-management.git
cd cafe-management

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Supabase Setup

1. Create a project at [supabase.com](https://supabase.com)
2. Copy your Project URL and Anon Key
3. Update `lib/main.dart`:

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_PROJECT_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

4. Run database scripts from `docs/supabase_integration.md`
5. Create initial admin user

### First Run

**Default Admin Credentials:**
- Email: `admin@cafe.com`
- Password: `admin123`

> ⚠️ **Security**: Change default credentials immediately after first login

---

## 📱 Usage

### Admin Workflow

1. **Login** with admin credentials
2. **Add Products** via Add Stock tab with photos
3. **Create Users** for employers
4. **Monitor** dashboard for insights
5. **Manage** inventory and users

### Employer Workflow

1. **Login** with provided credentials
2. **Browse** product catalog
3. **Add items** to cart
4. **Review** cart summary
5. **Submit** purchase order

---

## 🛠️ Tech Stack

### Frontend
- **Framework**: Flutter 3.x
- **Language**: Dart 3.x
- **State Management**: Provider
- **Navigation**: GoRouter
- **UI**: Material Design 3

### Backend
- **Database**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth
- **Storage**: Supabase Storage
- **Real-time**: Supabase Realtime

### Key Libraries
- `cached_network_image` - Image caching
- `shimmer` - Loading states
- `fl_chart` - Data visualization
- `image_picker` - Photo selection
- `intl` - Internationalization

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── theme/               # Theme configuration
│   ├── widgets/             # Reusable components
│   ├── screens/             # App screens
│   │   ├── home/           # Dashboard
│   │   ├── employer/       # Employer interface
│   │   ├── user_screen/    # User management
│   │   ├── stock/          # Inventory management
│   │   ├── login/          # Authentication
│   │   └── ButtomNav/      # Navigation
│   ├── router/             # Route configuration
│   └── utils/              # Utilities & helpers
├── model/                  # Data models
├── data/
│   └── db/                 # Database operations
└── main.dart               # App entry point
```

---

## 🎨 Screenshots

> Add your app screenshots here

---

## 📖 Documentation

- **[User Guide](docs/README.md)** - Complete usage instructions
- **[Supabase Setup](docs/supabase_integration.md)** - Database configuration
- **[Image Upload](docs/IMAGE_UPLOAD_GUIDE.md)** - Photo management guide
- **[Implementation Details](docs/walkthrough.md)** - Technical overview

---

## 🔒 Security

- Row Level Security (RLS) on all tables
- Role-based access control
- Secure authentication via Supabase
- Environment variables for sensitive data
- Input validation and sanitization

---

## 🚧 Roadmap

### Version 1.1 (Coming Soon)
- [ ] Push notifications
- [ ] PDF report export
- [ ] Multi-language support
- [ ] Offline mode
- [ ] Profile image upload

### Version 2.0 (Future)
- [ ] Advanced analytics
- [ ] QR code integration
- [ ] Payment gateway
- [ ] Customer management
- [ ] Inventory forecasting

---

## 🤝 Contributing

This is a proprietary project. For contributions or suggestions, please contact the development team.

---

## 📝 Changelog

### Version 1.0.0 (November 24, 2025)

**Initial Release**

- ✅ Complete admin dashboard with analytics
- ✅ User management system
- ✅ Inventory tracking
- ✅ Image upload for products
- ✅ Shopping cart for employers
- ✅ Real-time data synchronization
- ✅ Modern Material Design 3 UI
- ✅ Performance optimizations

---

## 👥 Team

- **Development**: Your Development Team
- **Design**: Material Design 3
- **Backend**: Supabase Platform

---

## 📄 License

This project is proprietary software. All rights reserved.

---

## 🐛 Bug Reports

Found a bug? Please report it with:
- Steps to reproduce
- Expected behavior
- Actual behavior
- Screenshots (if applicable)
- Device/OS information

---

## 💬 Support

For support and questions:
- Check the [User Guide](docs/README.md)
- Review [Documentation](docs/)
- Contact your system administrator

---

## 🙏 Acknowledgments

- Flutter Team for the amazing framework
- Supabase for the backend platform
- Material Design for UI guidelines
- All contributors and testers

---

**Made with ❤️ and ☕**

---

**Version**: 1.0.0  
**Status**: Production Ready ✅  
**Last Updated**: November 24, 2025