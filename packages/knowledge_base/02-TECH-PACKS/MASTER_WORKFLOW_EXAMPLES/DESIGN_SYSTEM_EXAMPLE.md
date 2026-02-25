# 🎨 DESIGN SYSTEM: TaskFlow Pro

> **Project:** TaskFlow Pro - Enterprise Task Management System
> **Document Type:** Visual Design Standards & Component Library
> **Version:** 2.1.0
> **Last Updated:** February 22, 2026
> **Status:** ✅ Active & Enforced
> **Authority:** UX/UI Designer (Keiko Tanaka) + Lead Architect

---

## 📋 Table of Contents

- [Design Principles](#design-principles)
- [Color Palette](#color-palette)
- [Typography](#typography)
- [Spacing System](#spacing-system)
- [Component Library](#component-library)
- [Icons](#icons)
- [Elevation & Shadows](#elevation--shadows)
- [Motion & Animation](#motion--animation)
- [Responsive Design](#responsive-design)
- [Accessibility](#accessibility)
- [Figma Resources](#figma-resources)
- [Implementation Guide](#implementation-guide)

---

## 🎯 Design Principles

### 1. Clarity Over Cleverness
- **Clear hierarchy** (titles > body > captions)
- **Descriptive labels** ("Create New Task" not "New")
- **Predictable interactions** (standard patterns)

### 2. Consistency is Kindness
- **Reusable components** (don't reinvent buttons)
- **Unified color language** (green = success, red = danger)
- **Consistent spacing** (8px grid)

### 3. Accessible by Default
- **WCAG 2.1 AA minimum** (contrast ratios ≥4.5:1)
- **Keyboard navigation** (tab order, focus states)
- **Screen reader support** (semantic HTML, ARIA labels)

### 4. Performance First
- **Lazy loading** (defer offscreen content)
- **Optimized assets** (SVG icons, WebP images)
- **Minimal animations** (respect prefers-reduced-motion)

---

## 🎨 Color Palette

### Primary Colors (Brand Identity)

#### Primary Blue (Actions & CTAs)
```dart
// lib/core/theme/colors.dart
class AppColors {
  // Primary Blue (main brand color)
  static const Color primaryBlue = Color(0xFF2563EB);       // #2563EB
  static const Color primaryBlueLight = Color(0xFF60A5FA);  // #60A5FA (hover)
  static const Color primaryBlueDark = Color(0xFF1E40AF);   // #1E40AF (pressed)
  static const Color primaryBlueSubtle = Color(0xFFDCEDFE); // #DCEDFE (background)
}
```

**Usage:**
- Primary buttons
- Active navigation items
- Links
- Selection highlights

**Accessibility:**
- ✅ 4.52:1 contrast on white background (WCAG AA)
- ✅ 7.12:1 contrast with light blue text

---

#### Secondary Purple (Accents)
```dart
class AppColors {
  // Secondary Purple (accents, badges)
  static const Color secondaryPurple = Color(0xFF7C3AED);       // #7C3AED
  static const Color secondaryPurpleLight = Color(0xFFA78BFA);  // #A78BFA
  static const Color secondaryPurpleDark = Color(0xFF5B21B6);   // #5B21B6
  static const Color secondaryPurpleSubtle = Color(0xFFF3E8FF); // #F3E8FF
}
```

**Usage:**
- Badges (priority, tags)
- Secondary actions
- Decorative elements

---

### Neutral Colors (UI Foundation)

```dart
class AppColors {
  // Neutral Grays (text, backgrounds, borders)
  static const Color gray900 = Color(0xFF111827); // #111827 (headings)
  static const Color gray800 = Color(0xFF1F2937); // #1F2937 (body text)
  static const Color gray700 = Color(0xFF374151); // #374151 (secondary text)
  static const Color gray600 = Color(0xFF4B5563); // #4B5563 (disabled text)
  static const Color gray500 = Color(0xFF6B7280); // #6B7280 (placeholders)
  static const Color gray400 = Color(0xFF9CA3AF); // #9CA3AF (dividers)
  static const Color gray300 = Color(0xFFD1D5DB); // #D1D5DB (borders)
  static const Color gray200 = Color(0xFFE5E7EB); // #E5E7EB (hover states)
  static const Color gray100 = Color(0xFFF3F4F6); // #F3F4F6 (backgrounds)
  static const Color gray50 = Color(0xFFF9FAFB);  // #F9FAFB (page background)

  static const Color white = Color(0xFFFFFFFF);   // #FFFFFF
  static const Color black = Color(0xFF000000);   // #000000
}
```

**Usage:**
| Color | Usage |
|-------|-------|
| gray900 | H1, H2, primary text |
| gray800 | Body text, labels |
| gray700 | Secondary text, captions |
| gray600 | Disabled text |
| gray500 | Placeholders, hints |
| gray400 | Dividers, separators |
| gray300 | Input borders, card borders |
| gray200 | Hover backgrounds |
| gray100 | Card backgrounds, subtle fills |
| gray50 | Page backgrounds |

---

### Semantic Colors (Status & Feedback)

#### Success Green
```dart
class AppColors {
  // Success (task completed, form submitted)
  static const Color success = Color(0xFF10B981);       // #10B981
  static const Color successLight = Color(0xFF6EE7B7);  // #6EE7B7
  static const Color successDark = Color(0xFF047857);   // #047857
  static const Color successSubtle = Color(0xFFD1FAE5); // #D1FAE5
}
```

**Usage:**
- Success messages ("Task created successfully")
- Checkmarks, completion icons
- Progress indicators (100%)

---

#### Warning Yellow
```dart
class AppColors {
  // Warning (validation warnings, non-critical issues)
  static const Color warning = Color(0xFFF59E0B);       // #F59E0B
  static const Color warningLight = Color(0xFFFBBF24);  // #FBBF24
  static const Color warningDark = Color(0xFFD97706);   // #D97706
  static const Color warningSubtle = Color(0xFFFEF3C7); // #FEF3C7
}
```

**Usage:**
- Warning messages ("Password expiring soon")
- Caution icons
- Overdue tasks

---

#### Error Red
```dart
class AppColors {
  // Error (validation errors, critical issues)
  static const Color error = Color(0xFFEF4444);       // #EF4444
  static const Color errorLight = Color(0xFFF87171);  // #F87171
  static const Color errorDark = Color(0xFFDC2626);   // #DC2626
  static const Color errorSubtle = Color(0xFFFEE2E2); // #FEE2E2
}
```

**Usage:**
- Error messages ("Invalid email")
- Destructive actions (delete button)
- Validation indicators

---

#### Info Blue
```dart
class AppColors {
  // Info (informational messages, tooltips)
  static const Color info = Color(0xFF3B82F6);       // #3B82F6
  static const Color infoLight = Color(0xFF93C5FD);  // #93C5FD
  static const Color infoDark = Color(0xFF1D4ED8);   // #1D4ED8
  static const Color infoSubtle = Color(0xFFDBEAFE); // #DBEAFE
}
```

**Usage:**
- Informational alerts ("New update available")
- Tooltips, help text
- Neutral badges

---

### Color Usage Matrix

| Component | State | Color |
|-----------|-------|-------|
| **Primary Button** | Default | primaryBlue (#2563EB) |
| | Hover | primaryBlueLight (#60A5FA) |
| | Pressed | primaryBlueDark (#1E40AF) |
| | Disabled | gray400 (#9CA3AF) |
| **Input Field** | Default | gray300 border (#D1D5DB) |
| | Focus | primaryBlue border (#2563EB) |
| | Error | error border (#EF4444) |
| | Disabled | gray200 background (#E5E7EB) |
| **Card** | Default | white background, gray300 border |
| | Hover | gray50 background (#F9FAFB) |
| **Alert - Success** | Background | successSubtle (#D1FAE5) |
| | Text | successDark (#047857) |

---

## 🔤 Typography

### Font Families

#### Primary Font: Inter (UI Text)
```dart
// lib/core/theme/typography.dart
class AppTypography {
  // Primary font for UI elements
  static const String fontFamilyPrimary = 'Inter';

  // Import in pubspec.yaml:
  // fonts:
  //   - family: Inter
  //     fonts:
  //       - asset: assets/fonts/Inter-Regular.ttf
  //       - asset: assets/fonts/Inter-Medium.ttf
  //         weight: 500
  //       - asset: assets/fonts/Inter-SemiBold.ttf
  //         weight: 600
  //       - asset: assets/fonts/Inter-Bold.ttf
  //         weight: 700
}
```

**Rationale:** Inter is optimized for screen readability, supports 200+ languages, free & open-source.

---

#### Monospace Font: JetBrains Mono (Code Snippets)
```dart
class AppTypography {
  // Monospace font for code blocks, API keys
  static const String fontFamilyMono = 'JetBrains Mono';
}
```

**Usage:**
- API keys display
- Technical error codes
- JSON previews

---

### Type Scale (Modular Scale: 1.250 - Major Third)

```dart
class AppTypography {
  // Display (Hero text)
  static const TextStyle display = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 48.0,           // 48px
    fontWeight: FontWeight.w700,  // Bold
    height: 1.2,              // 120% line height
    letterSpacing: -0.5,
  );

  // Headings
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 36.0,           // 36px
    fontWeight: FontWeight.w700,  // Bold
    height: 1.25,             // 125%
    letterSpacing: -0.5,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 28.0,           // 28px
    fontWeight: FontWeight.w600,  // SemiBold
    height: 1.3,
    letterSpacing: -0.25,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 22.0,           // 22px
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static const TextStyle h4 = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 18.0,           // 18px
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // Body Text
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 16.0,           // 16px (default)
    fontWeight: FontWeight.w400,  // Regular
    height: 1.5,              // 150% (24px line height)
    letterSpacing: 0.0,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 14.0,           // 14px
    fontWeight: FontWeight.w400,
    height: 1.5,              // 21px line height
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 12.0,           // 12px
    fontWeight: FontWeight.w400,
    height: 1.5,              // 18px line height
  );

  // Labels & Captions
  static const TextStyle label = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 14.0,           // 14px
    fontWeight: FontWeight.w500,  // Medium
    height: 1.4,
    letterSpacing: 0.15,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 12.0,           // 12px
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.gray600, // Subtle color
  );
}
```

### Typography Usage Matrix

| Element | Style | Color | Example |
|---------|-------|-------|---------|
| **Page Title** | h1 (36px Bold) | gray900 | "Dashboard" |
| **Section Heading** | h2 (28px SemiBold) | gray900 | "Recent Tasks" |
| **Card Title** | h3 (22px SemiBold) | gray900 | "Project Alpha" |
| **Modal Title** | h4 (18px SemiBold) | gray900 | "Create New Task" |
| **Body Text** | bodyLarge (16px) | gray800 | "Task description..." |
| **List Item** | bodyMedium (14px) | gray800 | "Task title" |
| **Button Label** | label (14px Medium) | white/primaryBlue | "Save Changes" |
| **Helper Text** | caption (12px) | gray600 | "Max 255 characters" |

---

## 📏 Spacing System (8px Grid)

### Base Unit: 8px
All spacing follows an 8px grid for visual consistency.

```dart
// lib/core/theme/spacing.dart
class AppSpacing {
  // Base unit
  static const double unit = 8.0;

  // Spacing scale (multiples of 8)
  static const double xs = 4.0;      // 0.5x (half unit)
  static const double sm = 8.0;      // 1x
  static const double md = 16.0;     // 2x
  static const double lg = 24.0;     // 3x
  static const double xl = 32.0;     // 4x
  static const double xxl = 48.0;    // 6x
  static const double xxxl = 64.0;   // 8x
}
```

### Layout Spacing Guidelines

| Context | Spacing | Value |
|---------|---------|-------|
| **Between text lines** | built-in | 1.5x font size |
| **Between paragraphs** | sm | 8px |
| **Between related elements** | md | 16px |
| **Between sections** | lg | 24px |
| **Between page sections** | xl | 32px |
| **Page margins** | xxl | 48px (desktop) |
| **Content max-width** | - | 1280px |

### Component Spacing

```dart
// Example: Card with proper spacing
Container(
  padding: EdgeInsets.all(AppSpacing.md), // 16px all sides
  margin: EdgeInsets.only(bottom: AppSpacing.lg), // 24px bottom
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Task Title', style: AppTypography.h3),
      SizedBox(height: AppSpacing.sm), // 8px vertical space
      Text('Description...', style: AppTypography.bodyMedium),
      SizedBox(height: AppSpacing.md), // 16px vertical space
      PrimaryButton(label: 'View Details'),
    ],
  ),
)
```

---

## 🧩 Component Library

### 1. Buttons

#### Primary Button (High Emphasis)
```dart
// lib/shared/widgets/buttons/primary_button.dart
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,  // 24px horizontal
          vertical: AppSpacing.md,    // 16px vertical
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 0,  // Flat design
        // Hover color
        surfaceTintColor: AppColors.primaryBlueLight,
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
              ),
            )
          : Text(label, style: AppTypography.label),
    );
  }
}
```

**States:**
- Default: Blue background (#2563EB)
- Hover: Light blue background (#60A5FA)
- Pressed: Dark blue background (#1E40AF)
- Disabled: Gray background (#9CA3AF), gray text
- Loading: Spinner replaces label

---

#### Secondary Button (Medium Emphasis)
```dart
class SecondaryButton extends StatelessWidget {
  // Similar structure to PrimaryButton

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryBlue,
        side: BorderSide(color: AppColors.primaryBlue, width: 1.5),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: Text(label, style: AppTypography.label),
    );
  }
}
```

**States:**
- Default: White background, blue border
- Hover: Light blue background (#DCEDFE)
- Pressed: Medium blue background (#B5D9FE)

---

#### Tertiary Button (Low Emphasis)
```dart
class TertiaryButton extends StatelessWidget {
  // Text-only button

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryBlue,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      child: Text(label, style: AppTypography.label),
    );
  }
}
```

---

#### Destructive Button (Danger Actions)
```dart
class DestructiveButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.error,  // Red background
        foregroundColor: AppColors.white,
        // Same padding/shape as PrimaryButton
      ),
      child: Text('Delete', style: AppTypography.label),
    );
  }
}
```

**Usage:** Delete actions, account closure, irreversible operations

---

### 2. Input Fields

#### Text Input
```dart
// lib/shared/widgets/inputs/text_input.dart
class TextInput extends StatelessWidget {
  final String label;
  final String? placeholder;
  final String? errorText;
  final TextEditingController? controller;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(label, style: AppTypography.label.copyWith(
          color: AppColors.gray700,
        )),
        SizedBox(height: AppSpacing.xs), // 4px space

        // Input field
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: AppTypography.bodyMedium,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.gray500,
            ),
            errorText: errorText,

            // Border styles
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: AppColors.gray300, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: AppColors.primaryBlue, width: 2.0),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: AppColors.error, width: 2.0),
            ),

            // Padding
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
        ),

        // Helper text
        if (errorText == null)
          Padding(
            padding: EdgeInsets.only(top: AppSpacing.xs),
            child: Text('Optional helper text', style: AppTypography.caption),
          ),
      ],
    );
  }
}
```

**States:**
- Default: Gray border (#D1D5DB)
- Focus: Blue border (#2563EB), 2px width
- Error: Red border (#EF4444), error message below
- Disabled: Gray background (#E5E7EB), gray text

---

### 3. Cards

#### Basic Card
```dart
// lib/shared/widgets/cards/basic_card.dart
class BasicCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.gray300, width: 1.0),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: child,
          ),
        ),
      ),
    );
  }
}
```

**Visual Specs:**
- Background: White (#FFFFFF)
- Border: 1px solid gray300 (#D1D5DB)
- Border radius: 12px
- Shadow: 0px 2px 10px rgba(0,0,0,0.05)
- Padding: 16px

---

### 4. Modals & Dialogs

#### Confirmation Dialog
```dart
// lib/shared/widgets/dialogs/confirmation_dialog.dart
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      title: Text(title, style: AppTypography.h4),
      content: Text(message, style: AppTypography.bodyMedium),
      actions: [
        SecondaryButton(
          label: cancelLabel,
          onPressed: () => Navigator.pop(context),
        ),
        SizedBox(width: AppSpacing.sm),
        PrimaryButton(
          label: confirmLabel,
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
        ),
      ],
      actionsPadding: EdgeInsets.all(AppSpacing.md),
    );
  }
}

// Usage:
showDialog(
  context: context,
  builder: (context) => ConfirmationDialog(
    title: 'Delete Task?',
    message: 'This action cannot be undone.',
    confirmLabel: 'Delete',
    cancelLabel: 'Cancel',
    onConfirm: () => deleteTask(),
  ),
);
```

---

### 5. Alerts & Toasts

#### Success Alert
```dart
// lib/shared/widgets/alerts/success_alert.dart
class SuccessAlert extends StatelessWidget {
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.successSubtle,  // Light green background
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: AppColors.success, width: 1.0),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.success, size: 20),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.successDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

**Variants:**
- Success: Green background, checkmark icon
- Warning: Yellow background, alert icon
- Error: Red background, error icon
- Info: Blue background, info icon

---

## 🖼️ Icons

### Icon Set: Material Icons (Flutter Default)

```dart
// lib/core/theme/icons.dart
class AppIcons {
  // Navigation
  static const IconData home = Icons.home_outlined;
  static const IconData dashboard = Icons.dashboard_outlined;
  static const IconData settings = Icons.settings_outlined;

  // Actions
  static const IconData add = Icons.add;
  static const IconData edit = Icons.edit_outlined;
  static const IconData delete = Icons.delete_outline;
  static const IconData save = Icons.save_outlined;
  static const IconData cancel = Icons.close;

  // Status
  static const IconData success = Icons.check_circle_outline;
  static const IconData error = Icons.error_outline;
  static const IconData warning = Icons.warning_amber_outlined;
  static const IconData info = Icons.info_outline;

  // Tasks
  static const IconData task = Icons.check_box_outlined;
  static const IconData taskCompleted = Icons.check_box;
  static const IconData calendar = Icons.calendar_today_outlined;
  static const IconData clock = Icons.access_time_outlined;
}
```

### Icon Sizes

```dart
class AppIcons {
  // Size scale
  static const double sizeSmall = 16.0;   // Inline icons
  static const double sizeMedium = 20.0;  // Button icons
  static const double sizeLarge = 24.0;   // Navigation icons
  static const double sizeXLarge = 32.0;  // Hero icons
}
```

---

## ☁️ Elevation & Shadows

### Shadow Levels (Material Design Inspired)

```dart
// lib/core/theme/shadows.dart
class AppShadows {
  // Level 0: No shadow (flat)
  static const List<BoxShadow> none = [];

  // Level 1: Subtle shadow (cards at rest)
  static final List<BoxShadow> level1 = [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
  ];

  // Level 2: Medium shadow (cards on hover)
  static final List<BoxShadow> level2 = [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.08),
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];

  // Level 3: Strong shadow (modals, dropdowns)
  static final List<BoxShadow> level3 = [
    BoxShadow(
      color: AppColors.black.withValues(alpha: 0.12),
      blurRadius: 30,
      offset: Offset(0, 8),
    ),
  ];
}
```

### Usage Guidelines

| Component | Elevation | Shadow Level |
|-----------|-----------|--------------|
| **Flat surfaces** | 0dp | none |
| **Cards (default)** | 1dp | level1 |
| **Cards (hover)** | 2dp | level2 |
| **Dropdowns** | 3dp | level3 |
| **Modals** | 3dp | level3 |
| **Tooltips** | 2dp | level2 |

---

## 🎬 Motion & Animation

### Animation Durations

```dart
// lib/core/theme/animations.dart
class AppAnimations {
  // Duration scale
  static const Duration fast = Duration(milliseconds: 150);      // Hover, focus
  static const Duration normal = Duration(milliseconds: 250);    // Transitions
  static const Duration slow = Duration(milliseconds: 400);      // Modal open
  static const Duration verySlow = Duration(milliseconds: 600);  // Page transitions
}
```

### Easing Curves

```dart
class AppAnimations {
  // Flutter built-in curves
  static const Curve easeIn = Curves.easeIn;           // Slow start, fast end
  static const Curve easeOut = Curves.easeOut;         // Fast start, slow end
  static const Curve easeInOut = Curves.easeInOut;     // Smooth both ends
  static const Curve spring = Curves.elasticOut;       // Bouncy
}
```

### Example: Animated Button Hover

```dart
class AnimatedButton extends StatefulWidget {
  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: AppAnimations.fast,  // 150ms
        curve: AppAnimations.easeOut,
        decoration: BoxDecoration(
          color: isHovered ? AppColors.primaryBlueLight : AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text('Hover Me'),
      ),
    );
  }
}
```

---

## 📐 Responsive Design

### Breakpoints

```dart
// lib/core/theme/breakpoints.dart
class AppBreakpoints {
  // Screen size breakpoints
  static const double mobile = 640;      // 0-640px (phones)
  static const double tablet = 1024;     // 641-1024px (tablets)
  static const double desktop = 1280;    // 1025-1280px (laptops)
  static const double wide = 1920;       // 1281+ (desktops)
}
```

### Responsive Helpers

```dart
class Responsive {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < AppBreakpoints.mobile;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= AppBreakpoints.mobile && width < AppBreakpoints.tablet;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= AppBreakpoints.tablet;
  }
}

// Usage:
Widget build(BuildContext context) {
  return Container(
    padding: Responsive.isMobile(context)
        ? EdgeInsets.all(AppSpacing.md)    // 16px on mobile
        : EdgeInsets.all(AppSpacing.xxl),  // 48px on desktop
    child: Text('Responsive Content'),
  );
}
```

---

## ♿ Accessibility

### Color Contrast Compliance

| Color Pair | Contrast Ratio | WCAG Level |
|------------|---------------|------------|
| primaryBlue (#2563EB) on white | 4.52:1 | ✅ AA (normal text) |
| gray900 (#111827) on white | 15.45:1 | ✅ AAA (all text) |
| gray700 (#374151) on white | 9.86:1 | ✅ AAA (all text) |
| error (#EF4444) on white | 4.11:1 | ⚠️ AA (large text only) |

**Action Required:** Error color needs adjusted for small text (use errorDark #DC2626 → 5.12:1).

---

### Focus States

```dart
// All interactive components must have visible focus indicators
FocusableActionDetector(
  child: ElevatedButton(...),
  focusNode: focusNode,
  // Custom focus indicator (2px blue border)
  onFocusChange: (hasFocus) {
    setState(() => isFocused = hasFocus);
  },
);

// Visual indicator
decoration: BoxDecoration(
  border: isFocused
      ? Border.all(color: AppColors.primaryBlue, width: 2.0)
      : null,
);
```

---

### Screen Reader Support

```dart
// Semantic labels for non-text elements
Semantics(
  label: 'Delete task',
  button: true,
  child: IconButton(
    icon: Icon(Icons.delete),
    onPressed: deleteTask,
  ),
);

// Announce dynamic changes
SemanticsService.announce(
  'Task created successfully',
  TextDirection.ltr,
);
```

---

## 🎨 Figma Resources

### Design Files

**Main Figma File:**
🔗 [TaskFlow Pro - Design System](https://figma.com/file/abc123/taskflow-design-system)

**Pages:**
1. **01 Foundations** - Colors, typography, spacing
2. **02 Components** - Button variants, inputs, cards
3. **03 Patterns** - Forms, modals, navigation
4. **04 Templates** - Dashboard, task detail, settings
5. **05 Prototypes** - Interactive user flows

---

### Component Library (Figma)

**Installation:**
```
1. Open Figma
2. File > Enable Libraries
3. Search "TaskFlow Pro Components"
4. Enable for this project
```

**Usage:**
- Drag components from Assets panel
- Maintain component instances (don't detach unless necessary)
- Submit updates via "Publish Changes"

---

## 💻 Implementation Guide

### Theme Configuration (Flutter)

```dart
// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      // Color scheme
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryBlue,
        secondary: AppColors.secondaryPurple,
        error: AppColors.error,
        background: AppColors.gray50,
        surface: AppColors.white,
      ),

      // Typography
      textTheme: TextTheme(
        displayLarge: AppTypography.display,
        headlineLarge: AppTypography.h1,
        headlineMedium: AppTypography.h2,
        headlineSmall: AppTypography.h3,
        titleMedium: AppTypography.h4,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.label,
      ),

      // Component themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.white,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 0,
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: AppColors.gray300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: AppColors.error, width: 2.0),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      ),
    );
  }
}
```

### Integration in App

```dart
// lib/main.dart
void main() {
  runApp(
    MaterialApp(
      title: 'TaskFlow Pro',
      theme: AppTheme.lightTheme(),
      home: DashboardPage(),
    ),
  );
}
```

---

## 📚 References

### Internal Documents
- [ACCESSIBILITY_GUIDE.md](ACCESSIBILITY_GUIDE.md) - WCAG 2.1 compliance
- [UI_WIREFRAMES_FLOW.md](UI_WIREFRAMES_FLOW.md) - User flows
- [RULES.md](../00-ROOT/RULES.md) - UI/UX standards (Section 5.4)

### External Resources
- [Material Design 3](https://m3.material.io/)
- [Inter Font](https://rsms.me/inter/)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Contrast Checker](https://webaim.org/resources/contrastchecker/)

---

**Document Signature:**

```
Approved by:
- Keiko Tanaka (UX/UI Designer) - February 22, 2026
- Sarah Chen (Lead Architect) - February 22, 2026

Next Review Date: May 22, 2026 (Quarterly)
Figma Version: 3.14.2
```

---

*This document is version-controlled and stored in `context/35-UX_UI/DESIGN_SYSTEM.md`. Visual changes require design review before implementation.*
