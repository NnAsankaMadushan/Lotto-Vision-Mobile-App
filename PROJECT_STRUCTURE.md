# Project Structure

## Complete File Tree

```
lotto_vision/
│
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart         # App-wide constants
│   │   │   └── lottery_types.dart         # Lottery types and configurations
│   │   ├── errors/
│   │   │   ├── exceptions.dart            # Custom exceptions
│   │   │   └── failures.dart              # Failure classes
│   │   ├── theme/
│   │   │   └── app_theme.dart             # Light & Dark themes
│   │   ├── utils/
│   │   │   └── typedefs.dart              # Type definitions
│   │   ├── widgets/
│   │   └── di/
│   │       └── injection_container.dart   # Dependency injection setup
│   │
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── local_datasource.dart      # Hive local storage
│   │   │   └── remote_datasource.dart     # OCR & API calls
│   │   ├── models/
│   │   │   ├── lottery_ticket_model.dart  # Ticket model with Hive adapter
│   │   │   ├── lottery_ticket_model.g.dart # Generated Hive adapter
│   │   │   ├── lottery_result_model.dart  # Result model with Hive adapter
│   │   │   └── lottery_result_model.g.dart # Generated Hive adapter
│   │   └── repositories/
│   │       └── lottery_repository_impl.dart # Repository implementation
│   │
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── lottery_ticket.dart        # Ticket entity
│   │   │   ├── lottery_result.dart        # Result entity
│   │   │   └── user.dart                  # User entity
│   │   ├── repositories/
│   │   │   ├── lottery_repository.dart    # Lottery repository interface
│   │   │   └── auth_repository.dart       # Auth repository interface
│   │   └── usecases/
│   │       ├── scan_ticket.dart           # Scan ticket use case
│   │       ├── check_ticket.dart          # Check winning use case
│   │       └── get_all_tickets.dart       # Get tickets use case
│   │
│   ├── presentation/
│   │   ├── providers/
│   │   ├── screens/
│   │   │   ├── home/
│   │   │   │   └── home_screen.dart       # Main home screen with tabs
│   │   │   ├── camera/
│   │   │   │   └── camera_screen.dart     # Camera/Gallery picker
│   │   │   ├── scanner/
│   │   │   │   └── scanner_screen.dart    # OCR processing screen
│   │   │   ├── results/
│   │   │   │   ├── results_screen.dart    # Latest results screen
│   │   │   │   └── ticket_detail_screen.dart # Ticket details & check
│   │   │   ├── history/
│   │   │   │   └── history_screen.dart    # Scanned tickets history
│   │   │   └── settings/
│   │   │       └── settings_screen.dart   # App settings
│   │   └── widgets/
│   │
│   ├── services/
│   │   ├── ocr/
│   │   │   ├── ocr_service.dart           # ML Kit OCR service
│   │   │   └── lottery_parser.dart        # Ticket text parser
│   │   ├── lottery/
│   │   │   ├── lottery_results_service.dart # NLB results scraper
│   │   │   └── ticket_checker.dart        # Winning logic
│   │   ├── firebase/
│   │   └── storage/
│   │
│   ├── l10n/
│   │   ├── app_en.arb                     # English translations
│   │   ├── app_si.arb                     # Sinhala translations
│   │   └── app_ta.arb                     # Tamil translations
│   │
│   └── main.dart                          # App entry point
│
├── test/
│   ├── unit/                              # Unit tests
│   ├── integration/                       # Integration tests
│   └── mocks/                             # Mock objects
│
├── assets/
│   ├── images/                            # Image assets
│   └── fonts/                             # Custom fonts
│
├── android/                               # Android native code
├── ios/                                   # iOS native code
├── pubspec.yaml                           # Dependencies
├── analysis_options.yaml                  # Linter rules
├── README.md                              # Project documentation
└── PROJECT_STRUCTURE.md                   # This file
```

## Key Files Explained

### Core Layer

**[lib/core/constants/lottery_types.dart](lib/core/constants/lottery_types.dart)**
- Defines all supported Sri Lankan lottery types
- Contains lottery configurations (number count, ranges, prize tiers)
- Used for validation and parsing

**[lib/core/errors/failures.dart](lib/core/errors/failures.dart)** & **[exceptions.dart](lib/core/errors/exceptions.dart)**
- Clean architecture pattern for error handling
- Exceptions for data layer
- Failures for domain/presentation layer

**[lib/core/di/injection_container.dart](lib/core/di/injection_container.dart)**
- GetIt dependency injection setup
- Initializes all services, repositories, and use cases
- Called once at app startup

### Data Layer

**[lib/data/models/lottery_ticket_model.dart](lib/data/models/lottery_ticket_model.dart)**
- Hive model for local ticket storage
- Converts between entity and storage format
- Includes generated Hive TypeAdapter

**[lib/data/datasources/local_datasource.dart](lib/data/datasources/local_datasource.dart)**
- Manages Hive box operations
- CRUD operations for tickets and results
- Offline-first approach

**[lib/data/datasources/remote_datasource.dart](lib/data/datasources/remote_datasource.dart)**
- Coordinates OCR scanning
- Fetches lottery results from web
- Image preprocessing

**[lib/data/repositories/lottery_repository_impl.dart](lib/data/repositories/lottery_repository_impl.dart)**
- Implements domain repository interface
- Combines local and remote data sources
- Handles error mapping from exceptions to failures

### Domain Layer

**[lib/domain/entities/](lib/domain/entities/)**
- Pure business objects (no external dependencies)
- LotteryTicket, LotteryResult, User, CheckResult

**[lib/domain/repositories/](lib/domain/repositories/)**
- Abstract interfaces for data operations
- Followed by data layer implementations

**[lib/domain/usecases/](lib/domain/usecases/)**
- Single responsibility business logic
- Each use case performs one specific action
- Called by presentation layer

### Services Layer

**[lib/services/ocr/ocr_service.dart](lib/services/ocr/ocr_service.dart)**
- Google ML Kit text recognition
- Image preprocessing for better OCR
- Returns raw text from ticket images

**[lib/services/ocr/lottery_parser.dart](lib/services/ocr/lottery_parser.dart)**
- Parses OCR text to extract ticket info
- Regex patterns for different lottery types
- Supports Sinhala and Tamil text
- Validates extracted numbers

**[lib/services/lottery/lottery_results_service.dart](lib/services/lottery/lottery_results_service.dart)**
- Web scraping for NLB results
- HTML parsing
- **⚠️ Needs customization based on actual NLB website structure**

**[lib/services/lottery/ticket_checker.dart](lib/services/lottery/ticket_checker.dart)**
- Compares ticket numbers with winning numbers
- Calculates prize amounts
- Determines winning tiers
- Provides probability statistics

### Presentation Layer

**[lib/presentation/screens/home/home_screen.dart](lib/presentation/screens/home/home_screen.dart)**
- Main app navigation with bottom nav bar
- Four tabs: Home, Results, History, Settings

**[lib/presentation/screens/camera/camera_screen.dart](lib/presentation/screens/camera/camera_screen.dart)**
- Image picker (camera or gallery)
- Permission handling
- Image quality validation

**[lib/presentation/screens/scanner/scanner_screen.dart](lib/presentation/screens/scanner/scanner_screen.dart)**
- Shows image being scanned
- Calls OCR service
- Handles scanning errors
- Navigates to ticket details on success

**[lib/presentation/screens/results/ticket_detail_screen.dart](lib/presentation/screens/results/ticket_detail_screen.dart)**
- Displays extracted ticket information
- "Check Results" button
- Shows winning status and prize amount
- Beautiful UI for winners

### Localization

**[lib/l10n/app_*.arb](lib/l10n/)**
- Translation files for English, Sinhala, Tamil
- Flutter's built-in l10n system
- Auto-generates helper classes

## Data Flow

### Scanning Flow
```
User Action (Take Photo)
    ↓
CameraScreen (image picker)
    ↓
ScannerScreen (shows image)
    ↓
ScanTicket UseCase
    ↓
LotteryRepository
    ↓
RemoteDataSource
    ↓
OCRService (extract text) → LotteryParser (parse ticket)
    ↓
LocalDataSource (cache ticket)
    ↓
TicketDetailScreen (display)
```

### Checking Results Flow
```
User Action (Check Ticket)
    ↓
TicketDetailScreen
    ↓
CheckTicket UseCase
    ↓
LotteryRepository
    ↓
1. Fetch Results (RemoteDataSource → LotteryResultsService)
2. Check Numbers (TicketChecker)
    ↓
Display Win/Loss Status
```

## Generated Files

After running `flutter pub run build_runner build`:
- `lib/data/models/*.g.dart` - Hive TypeAdapters
- `lib/presentation/providers/*.g.dart` - Riverpod providers (if used)

## Configuration Files

**pubspec.yaml**
- All dependencies and versions
- Asset declarations
- Flutter l10n generation config

**analysis_options.yaml**
- Dart linter rules
- Code quality standards

## Next Steps for Customization

1. **Update NLB Results Parser**: Inspect https://www.nlb.lk and update parsing logic in `lottery_results_service.dart`

2. **Add Firebase**: Configure Firebase and uncomment auth code

3. **Fine-tune OCR Patterns**: Test with real tickets and adjust regex in `lottery_parser.dart`

4. **Add State Management**: Implement Riverpod providers in `presentation/providers/`

5. **Write Tests**: Add unit tests for parsers and use cases

6. **Add More Lottery Types**: Extend `LotteryType` enum and add configurations
