### **Master Prompt for AI Coding Editor**

**Project Overview:**
Create a Flutter mobile application that acts as a client for an AI-powered automated content generator. The app's purpose is to view generated social media "slideshows" (images + text overlays), trigger new generations via an API, and download assets to the local device.

**Tech Stack:**

  * **Flutter:** Latest stable version.
  * **State Management:** `flutter_riverpod` or simple `Provider` (keep it lightweight).
  * **Backend/Data:** `cloud_firestore` (for reading posts), `http` (for triggering generation).
  * **Media:** `cached_network_image` (for viewing), `gal` or `image_gallery_saver` (for saving to camera roll), `carousel_slider` (for the detail view).
  * **Utils:** `flutter/services.dart` (for clipboard).

**Data Model (JSON Structure):**
Create a Dart model named `Post` that matches this structure (based on the backend Go structs):

```dart
// The backend stores this in Firestore collection "posts"
class Post {
  final String id;
  final Content content;
  final DateTime createdAt;
  // ... constructor & factory .fromJson
}

class Content {
  final String conceptTheme;
  final List<Slide> slides;
  // ... constructor & factory .fromJson
}

class Slide {
  final int slideNumber;
  final String overlayText; // This text is crucial for the UI
  final String imageUrl;    // The remote URL to display
  final String ImagePrompt;
  // ... constructor & factory .fromJson
}
```

**Screen 1: The Feed (Home Screen)**

  * **Layout:** A `Scaffold` with a `StreamBuilder` listening to the Firestore collection `posts`.
  * **Grid:** Display items in a **2-column Masonry or Grid**.
  * **Card Item:**
      * Show the **first image** (`slides[0].imageUrl`) as the thumbnail.
      * Overlay the `conceptTheme` text at the bottom of the card with a semi-transparent black background for readability.
      * **Tap Interaction:** Navigate to `PostDetailScreen`.
  * **Floating Action Button (FAB):**
      * **Icon:** A "Magic Wand" or "Add" icon.
      * **Action:** Make an HTTP POST request to `http://localhost:8081/v1/post`.
      * **Logic:**
          * Show a `SnackBar` saying "Generating new concept..." immediately upon press.
          * Do *not* wait for the generation to finish (fire and forget).
          * *Note:* Ensure the URL handles Android Emulator loopback (`10.0.2.2`) vs iOS (`localhost`).

**Screen 2: Post Detail Screen**

  * **Layout:** A specialized view to help the user review and extract content.
  * **Components:**
      * **Top 70% (Carousel):** Use a `CarouselSlider` to swipe through the `slides` images.
      * **Bottom 30% (Text Card):** A prominent Card displaying the `overlayText` of the *currently selected* slide.
          * **Action:** Tapping this card copies the text to the Clipboard and shows a "Copied\!" toast.
      * **Top Bar Actions:**
          * **"Save All":** A button that iterates through all `slides` URLs, downloads the images, and saves them to the device's Gallery/Camera Roll. Show a progress indicator during this process.
          * **"Info":** A small icon that shows a Dialog with the raw `imagePrompt` metadata (for debugging).

**Styling:**

  * Use a Dark Mode theme (background `Color(0xFF121212)`) to make the images pop.
  * Use `GoogleFonts.inter` or `roboto` for a clean, modern look.

**Implementation Steps:**

1.  Setup `firebase_core` and the Firestore stream.
2.  Implement the Data Models.
3.  Build the `HomeFeedScreen` with the Grid and FAB.
4.  Build the `PostDetailScreen` with the Carousel/Text sync logic.
5.  Implement the `downloadAllImages` function using the `gal` package (ensure permissions are handled in `Info.plist`/`AndroidManifest.xml` instructions).