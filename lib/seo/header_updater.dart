import 'dart:html' as html;
import 'dart:convert'; // ✅ for jsonEncode

class HeadUpdater {
  static void update({
    String? title,
    String? description,
    String? keywords,
    String? robots,
    String? canonicalUrl,
    String? imageUrl,
    String? schemaType,
  }) {
    final head = html.document.head;
    if (head == null) return;

    // 🏷️ Title
    if (title != null && title.isNotEmpty) {
      html.document.title = title;
    }

    // 🧠 Meta tags
    if (description != null && description.isNotEmpty) {
      _updateMeta('description', description);
    }
    if (keywords != null && keywords.isNotEmpty) {
      _updateMeta('keywords', keywords);
    }
    if (robots != null && robots.isNotEmpty) {
      _updateMeta('robots', robots);
    }

    // 🔗 Canonical
    if (canonicalUrl != null && canonicalUrl.isNotEmpty) {
      _updateLink('canonical', canonicalUrl);
    }

    // 🖼️ Open Graph (OG) tags
    if (title != null) _updateProperty('og:title', title);
    if (description != null) _updateProperty('og:description', description);
    _updateProperty('og:url', canonicalUrl ?? html.window.location.href);
    if (imageUrl != null && imageUrl.isNotEmpty) {
      _updateProperty('og:image', imageUrl);
    }

    // 🐦 Twitter tags
    if (title != null) _updateMeta('twitter:title', title);
    if (description != null) _updateMeta('twitter:description', description);
    if (imageUrl != null && imageUrl.isNotEmpty) {
      _updateMeta('twitter:image', imageUrl);
    }

    // 📘 JSON-LD Structured Data
    if (schemaType != null && schemaType.isNotEmpty) {
      _updateStructuredData(
        schemaType: schemaType,
        title: title,
        description: description,
        canonicalUrl: canonicalUrl,
        imageUrl: imageUrl,
      );
    }

    print("✅ SEO tags updated for: $title");
  }

  // --- Helpers ---
  static void _updateMeta(String name, String content) {
    final el = html.document.querySelector('meta[name="$name"]');
    if (el != null) {
      el.setAttribute('content', content);
    } else {
      final meta =
          html.MetaElement()
            ..name = name
            ..content = content;
      html.document.head!.append(meta);
    }
  }

  static void _updateProperty(String property, String content) {
    final el = html.document.querySelector('meta[property="$property"]');
    if (el != null) {
      el.setAttribute('content', content);
    } else {
      final meta =
          html.MetaElement()
            ..setAttribute('property', property)
            ..content = content;
      html.document.head!.append(meta);
    }
  }

  static void _updateLink(String rel, String href) {
    final el = html.document.querySelector('link[rel="$rel"]');
    if (el != null) {
      el.setAttribute('href', href);
    } else {
      final link =
          html.LinkElement()
            ..rel = rel
            ..href = href;
      html.document.head!.append(link);
    }
  }

  static void _updateStructuredData({
    required String schemaType,
    String? title,
    String? description,
    String? canonicalUrl,
    String? imageUrl,
  }) {
    final existing = html.document.querySelector(
      'script[type="application/ld+json"]',
    );

    final data = {
      "@context": "https://schema.org",
      "@type": schemaType,
      "name": title,
      "description": description,
      "url": canonicalUrl ?? html.window.location.href,
      "image": imageUrl,
    };

    final json = jsonEncode(data); // ✅ use dart:convert

    if (existing != null) {
      existing.text = json;
    } else {
      final script =
          html.ScriptElement()
            ..type = "application/ld+json"
            ..text = json;
      html.document.head!.append(script);
    }
  }
}
