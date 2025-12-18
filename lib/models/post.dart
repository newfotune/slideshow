import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final Content content;
  final DateTime createdAt;

  Post({required this.id, required this.content, required this.createdAt});

  factory Post.fromJson(Map<String, dynamic> json, String id) {
    return Post(
      id: id,
      content: Content.fromJson(json['content'] as Map<String, dynamic>),
      createdAt: (json['created_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content.toJson(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class Content {
  final String conceptTheme;
  final List<Slide> slides;

  Content({required this.conceptTheme, required this.slides});

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      conceptTheme: json['concept_theme'] as String,
      slides: (json['slides'] as List<dynamic>)
          .map((slide) => Slide.fromJson(slide as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conceptTheme': conceptTheme,
      'slides': slides.map((slide) => slide.toJson()).toList(),
    };
  }
}

class Slide {
  final int slideNumber;
  final String overlayText;
  final String imageUrl;
  final String imagePrompt;

  Slide({
    required this.slideNumber,
    required this.overlayText,
    required this.imageUrl,
    required this.imagePrompt,
  });

  factory Slide.fromJson(Map<String, dynamic> json) {
    return Slide(
      slideNumber: json['slide_number'] as int,
      overlayText: json['overlay_text'] as String,
      imageUrl: json['image_url'] as String,
      imagePrompt: json['image_prompt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slideNumber': slideNumber,
      'overlayText': overlayText,
      'imageUrl': imageUrl,
      'imagePrompt': imagePrompt,
    };
  }
}
