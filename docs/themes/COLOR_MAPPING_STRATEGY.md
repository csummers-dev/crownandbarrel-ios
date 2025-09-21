# Color Mapping Strategy
## Crown & Barrel - Theme Implementation Guidelines

### 🎨 **Color Role Mapping**

For each 5-color palette, colors are mapped to specific UI roles based on design principles and accessibility requirements:

#### **Mapping Formula**
1. **Background** (Primary): Lightest/most neutral color for main backgrounds
2. **Secondary Background**: Second lightest for cards, containers
3. **Tertiary Background**: Third color for elevated surfaces
4. **Accent**: Most vibrant/distinctive color for interactive elements
5. **Text Primary**: Highest contrast color for primary text
6. **Text Secondary**: Medium contrast for secondary text
7. **Separator**: Subtle color for dividers and borders
8. **Tab Bar Hairline**: Very subtle color for navigation separators

#### **Color Scheme Classification**
- **Light Themes**: Palettes with light backgrounds and dark text
- **Dark Themes**: Palettes with dark backgrounds and light text
- **Auto-Detection**: Based on background luminance

### 📊 **Palette Analysis & Mapping**

#### **1. Warm Earth Tones** → `warm-earth-tones`
**Classification**: Light Theme
**Colors**: `#8B4513`, `#D2691E`, `#CD853F`, `#F4A460`, `#FFF8DC`
**Mapping**:
- Background: `#FFF8DC` (Cornsilk - lightest)
- Secondary Background: `#F4A460` (Sandy Brown - light warm)
- Tertiary Background: `#CD853F` (Peru - medium warm)
- Accent: `#D2691E` (Chocolate - vibrant warm)
- Text Primary: `#8B4513` (Saddle Brown - darkest for contrast)
- Text Secondary: `rgba(139,69,19,0.7)` (Saddle Brown 70%)
- Separator: `rgba(210,105,30,0.3)` (Chocolate 30%)
- Tab Bar Hairline: `rgba(139,69,19,0.2)` (Saddle Brown 20%)

#### **2. Cool Minimalist** → `cool-minimalist`
**Classification**: Light Theme
**Colors**: `#2C3E50`, `#34495E`, `#7F8C8D`, `#BDC3C7`, `#ECF0F1`
**Mapping**:
- Background: `#ECF0F1` (Clouds - lightest)
- Secondary Background: `#BDC3C7` (Light Gray)
- Tertiary Background: `#7F8C8D` (Gray)
- Accent: `#34495E` (Charcoal - distinctive)
- Text Primary: `#2C3E50` (Dark Slate Gray - darkest)
- Text Secondary: `rgba(44,62,80,0.7)` (Dark Slate Gray 70%)
- Separator: `rgba(52,73,94,0.25)` (Charcoal 25%)
- Tab Bar Hairline: `rgba(44,62,80,0.15)` (Dark Slate Gray 15%)

#### **3. Vibrant Sunset** → `vibrant-sunset`
**Classification**: Light Theme (with vibrant accents)
**Colors**: `#FF6B6B`, `#FF8E53`, `#FF6B35`, `#F7931E`, `#FFD23F`
**Mapping**:
- Background: `#FFFBF5` (Custom light background for readability)
- Secondary Background: `#FFD23F` (Sunglow - lightest from palette)
- Tertiary Background: `#FF8E53` (Orange)
- Accent: `#FF6B35` (Red Orange - most distinctive)
- Text Primary: `#8B4513` (Custom dark brown for contrast)
- Text Secondary: `rgba(139,69,19,0.7)` (Dark brown 70%)
- Separator: `rgba(255,107,53,0.3)` (Red Orange 30%)
- Tab Bar Hairline: `rgba(247,147,30,0.25)` (Orange Peel 25%)

#### **4. Ocean Breeze** → `ocean-breeze`
**Classification**: Dark Theme
**Colors**: `#0F4C75`, `#3282B8`, `#BBE1FA`, `#1B262C`, `#A8E6CF`
**Mapping**:
- Background: `#1B262C` (Dark Slate - darkest)
- Secondary Background: `#0F4C75` (Dark Blue)
- Tertiary Background: `#3282B8` (Blue)
- Accent: `#A8E6CF` (Mint Green - distinctive)
- Text Primary: `#BBE1FA` (Light Blue - brightest)
- Text Secondary: `rgba(187,225,250,0.75)` (Light Blue 75%)
- Separator: `rgba(168,230,207,0.3)` (Mint Green 30%)
- Tab Bar Hairline: `rgba(187,225,250,0.2)` (Light Blue 20%)

#### **5. Forest Canopy** → `forest-canopy`
**Classification**: Dark Theme
**Colors**: `#2D5016`, `#4F7942`, `#87A96B`, `#C5D1C0`, `#F0F4EC`
**Mapping**:
- Background: `#2D5016` (Dark Forest Green - darkest)
- Secondary Background: `#4F7942` (Forest Green)
- Tertiary Background: `#87A96B` (Sage Green)
- Accent: `#C5D1C0` (Light Sage - distinctive)
- Text Primary: `#F0F4EC` (Ivory - lightest)
- Text Secondary: `rgba(240,244,236,0.8)` (Ivory 80%)
- Separator: `rgba(197,209,192,0.25)` (Light Sage 25%)
- Tab Bar Hairline: `rgba(240,244,236,0.15)` (Ivory 15%)

### 🔧 **Implementation Strategy**

#### **Phase 1: Core Theme Structure**
1. Maintain existing theme structure and compatibility
2. Add new themes to `Themes.json` without breaking existing themes
3. Ensure all new themes follow the established color role mapping

#### **Phase 2: Color Scheme Detection**
```swift
// Auto-detect color scheme based on background luminance
func detectColorScheme(backgroundColor: String) -> AppThemeColorScheme {
    guard let color = Color(themeString: backgroundColor) else { return .light }
    let luminance = calculateLuminance(color)
    return luminance > 0.5 ? .light : .dark
}
```

#### **Phase 3: Accessibility Validation**
- Calculate contrast ratios for all text/background combinations
- Ensure WCAG 2.1 AA compliance (4.5:1 for normal text, 3:1 for large text)
- Provide fallback colors for insufficient contrast

#### **Phase 4: Chart Palette Generation**
For each theme, generate a 5-color chart palette using:
1. Primary accent color
2. Complementary color to accent
3. Analogous colors to accent
4. High contrast colors for data visualization
5. Neutral color for context

### 📱 **UI Component Mapping**

#### **Navigation Elements**
- Tab bar background: `background`
- Tab bar selected: `accent`
- Tab bar unselected: `textSecondary`
- Navigation bar: `secondaryBackground`
- Navigation title: `accent`

#### **Content Areas**
- Main background: `background`
- Card backgrounds: `secondaryBackground`
- Elevated surfaces: `tertiaryBackground`
- Primary text: `textPrimary`
- Secondary text: `textSecondary`

#### **Interactive Elements**
- Buttons: `accent` background, contrasting text
- Links: `accent`
- Form controls: `accent` for active states
- Selection indicators: `accent`

### ⚡ **Performance Considerations**

#### **Theme Loading**
- Lazy load theme resources
- Cache computed color values
- Minimize theme switching overhead

#### **Memory Management**
- Efficient color object creation
- Reuse color instances where possible
- Clean up unused theme resources

### 🧪 **Testing Strategy**

#### **Visual Testing**
- Screenshot tests for each theme
- Contrast validation tests
- Color accessibility tests

#### **Functional Testing**
- Theme switching functionality
- Persistence of theme selection
- Fallback behavior for invalid themes

---

*This strategy ensures consistent, accessible, and performant implementation of trending color palettes as themes in the Crown & Barrel application.*
