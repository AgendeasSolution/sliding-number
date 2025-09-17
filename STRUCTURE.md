# Flutter Sliding Tile - Project Structure

This document outlines the complete, standard, and organized file and folder structure for the Flutter Sliding Tile project.

## 📁 Project Structure

```
lib/
├── app/                          # App-level configuration
│   ├── providers/               # State management providers
│   └── routing/                 # App routing configuration
├── components/                  # Reusable UI components (legacy - use widgets/)
├── constants/                   # Application constants
│   ├── app_colors.dart         # Color definitions
│   ├── app_constants.dart      # Game and UI constants
│   └── constants.dart          # Barrel export
├── core/                       # Core functionality
│   ├── constants/
│   │   └── app_strings.dart    # String constants
│   ├── errors/
│   │   └── game_errors.dart    # Custom error classes
│   ├── theme/                  # Core theme files
│   └── utils/
│       └── validators.dart     # Validation utilities
├── features/                   # Feature-based organization
│   └── game/                   # Game feature
│       ├── data/               # Data layer (repositories, data sources)
│       ├── domain/             # Business logic (entities, use cases)
│       └── presentation/       # UI layer (pages, widgets, controllers)
├── models/                     # Data models
│   ├── game_state.dart        # Game state model
│   └── models.dart            # Barrel export
├── pages/                      # Screen/Page widgets
│   └── game_page.dart         # Main game screen
├── services/                   # Business logic services
│   └── game_service.dart      # Game logic service
├── shared/                     # Shared utilities and widgets
│   ├── services/              # Shared services
│   └── widgets/               # Shared widgets
├── theme/                      # Theme configuration
│   └── app_theme.dart         # App theme definitions
├── utils/                      # Utility functions
│   ├── game_utils.dart        # Game-specific utilities
│   └── utils.dart             # Barrel export
├── widgets/                    # Reusable UI widgets
│   ├── game_board.dart        # Game board widget
│   ├── game_button.dart       # Custom button widget
│   ├── game_tile.dart         # Individual tile widget
│   ├── goal_board.dart        # Goal display widget
│   ├── instruction_item.dart  # Instruction item widget
│   ├── modal_container.dart   # Modal container widget
│   ├── modal_footer.dart      # Modal footer widget
│   ├── modal_header.dart      # Modal header widget
│   ├── stat_item.dart         # Statistics display widget
│   └── widgets.dart           # Barrel export
└── main.dart                   # App entry point
```

## 🏗️ Architecture Overview

### **Separation of Concerns**

- **Models**: Data structures and state management
- **Services**: Business logic and game mechanics
- **Widgets**: Reusable UI components
- **Pages**: Screen-level widgets
- **Utils**: Pure utility functions
- **Constants**: Configuration and constants
- **Theme**: Styling and theming

### **Key Components**

#### **Models** (`/models/`)

- `game_state.dart`: Centralized game state management
- Immutable state objects with copyWith methods
- Clear separation between UI state and business logic

#### **Services** (`/services/`)

- `game_service.dart`: Core game logic
- Stateless service functions
- Pure functions for game operations

#### **Widgets** (`/widgets/`)

- Reusable, composable UI components
- Single responsibility principle
- Consistent styling through theme

#### **Pages** (`/pages/`)

- Screen-level widgets
- State management and user interactions
- Composition of smaller widgets

#### **Utils** (`/utils/`)

- Pure utility functions
- No side effects
- Easy to test and maintain

#### **Constants** (`/constants/`)

- Centralized configuration
- Type-safe constants
- Easy to modify and maintain

#### **Theme** (`/theme/`)

- Consistent styling
- Dark theme implementation
- Reusable design tokens

## 🎯 Benefits of This Structure

1. **Maintainability**: Clear separation makes code easy to find and modify
2. **Scalability**: Easy to add new features without affecting existing code
3. **Testability**: Pure functions and clear boundaries make testing straightforward
4. **Reusability**: Widgets and utilities can be easily reused
5. **Consistency**: Standardized patterns across the codebase
6. **Team Collaboration**: Clear structure helps multiple developers work together

## 📋 File Naming Conventions

- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables/Functions**: `camelCase`
- **Constants**: `UPPER_SNAKE_CASE`
- **Private members**: `_camelCase`

## 🔧 Usage Examples

### Importing Components

```dart
// Import specific widgets
import '../widgets/game_button.dart';

// Import barrel exports
import '../widgets/widgets.dart';
import '../constants/constants.dart';
```

### Using Services

```dart
import '../services/game_service.dart';

// Use service functions
final newState = GameService.moveTile(currentState, row, col);
```

### Accessing Constants

```dart
import '../constants/constants.dart';

// Use color constants
color: AppColors.primaryGold

// Use game constants
if (level <= AppConstants.maxLevel) { ... }
```

## 🚀 Future Enhancements

This structure supports easy addition of:

- New game features
- Different game modes
- Settings and preferences
- Analytics and tracking
- Multiplayer functionality
- Sound and animations

The modular structure ensures that new features can be added without disrupting existing functionality.
