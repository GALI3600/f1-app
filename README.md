# Automagik Forge

A Flutter application with a clean architecture and modern development practices.

## Project Structure

```
lib/
├── core/
│   ├── config/          # App configuration
│   ├── constants/       # App constants
│   ├── router/          # Navigation/routing
│   └── theme/           # Theme configuration
├── features/            # Feature modules
│   └── home/           # Home feature
│       └── presentation/
└── shared/             # Shared resources
    ├── models/         # Data models
    ├── services/       # Services
    ├── utils/          # Utilities
    └── widgets/        # Reusable widgets
```

## Dependencies

- **flutter_riverpod**: State management
- **go_router**: Declarative routing
- **shared_preferences**: Local storage
- **http**: HTTP client
- **flutter_dotenv**: Environment variables

## Getting Started

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Create environment file:
   ```bash
   cp .env.example .env
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Development

- Follow the linting rules defined in `analysis_options.yaml`
- Use feature-based architecture for new features
- Keep widgets small and reusable