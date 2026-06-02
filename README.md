# 🌟 Creator Hub

Creator Hub is a premium, full-stack social and marketplace application built with Flutter. Designed with a focus on modern UI/UX principles, it features real-time chat, a dynamic social feed with interactive media, and a seamlessly integrated digital marketplace.

## ✨ Premium Features

* **Secure Authentication:** Complete email/password authentication flow with session persistence and animated routing.
* **Dynamic Social Feed:** Instagram-style edge-to-edge media rendering, double-tap to like animations, inline "read more" text expansion, and full CRUD operations (Create, Read, Update, Delete) for post authors.
* **Real-Time Chat Engine:** Instant messaging using Firestore WebSockets (`.snapshots()`), featuring smooth scrolling, tailored UI bubbles, and precise timestamps.
* **Integrated Marketplace:** A responsive 2-column masonry grid for product listings, complete with a custom Stripe-style mock checkout flow and animated success dialogs.
* **Cloud Media Pipeline:** Direct REST API integration with Cloudinary for fast, secure, and optimized multi-part image uploads.
* **Bespoke UI/UX:** Custom animated splash screens, reusable premium text fields, modal bottom sheets, and native responsive iconography.

## 🛠️ Tech Stack

* **Frontend:** Flutter & Dart
* **Backend & Database:** Google Firebase (Cloud Firestore)
* **Authentication:** Firebase Auth
* **Media Storage:** Cloudinary REST API
* **State Management:** Provider
* **Architecture:** Feature-First Modular Design

## 📂 Project Structure

The codebase follows a clean, highly scalable feature-based architecture:

```text
lib/
 ├── core/               # Shared utilities, validators, and constants (AppColors, CustomTextField)
 ├── features/
 │    ├── auth/          # Splash screen, Login, Signup, AuthProvider
 │    ├── chat/          # Real-time chat list, Chat room, ChatProvider
 │    ├── feed/          # Social feed, Post models, FeedProvider
 │    └── products/      # Marketplace grid, Mock checkout, ProductProvider
 ├── main.dart           # App entry point & Provider initialization
 └── navigation_menu.dart# Persistent bottom navigation logic