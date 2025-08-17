# Nefer Project Structure

```
nefer/
├── android/                          # Android-specific configuration
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── kotlin/com/company/nefer/
│   │   │   │   └── MainActivity.kt
│   │   │   ├── res/
│   │   │   │   ├── drawable/
│   │   │   │   ├── mipmap-*/
│   │   │   │   └── values/
│   │   │   │       ├── colors.xml
│   │   │   │       └── strings.xml
│   │   │   └── AndroidManifest.xml
│   │   ├── google-services.json      # Firebase configuration
│   │   ├── build.gradle
│   │   └── key.properties           # Signing configuration
│   ├── gradle/
│   ├── build.gradle
│   ├── gradle.properties
│   └── settings.gradle
├── ios/                              # iOS-specific configuration
│   ├── Runner/
│   │   ├── Assets.xcassets/
│   │   ├── Base.lproj/
│   │   ├── GoogleService-Info.plist  # Firebase configuration
│   │   ├── Info.plist
│   │   ├── AppDelegate.swift
│   │   └── Runner-Bridging-Header.h
│   ├── Runner.xcodeproj/
│   ├── Runner.xcworkspace/
│   └── Podfile
├── web/                              # Web admin dashboard
│   ├── index.html
│   ├── manifest.json
│   └── icons/
├── lib/                              # Main Flutter application code
│   ├── main.dart                     # App entry point
│   ├── app.dart                      # App widget configuration
│   ├── firebase_options.dart         # Firebase configuration
│   ├── core/                         # Core utilities and shared code
│   │   ├── constants/
│   │   │   ├── app_constants.dart
│   │   │   ├── api_constants.dart
│   │   │   └── storage_constants.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   ├── app_colors.dart
│   │   │   ├── app_typography.dart
│   │   │   └── rtl_theme.dart
│   │   ├── utils/
│   │   │   ├── validators.dart
│   │   │   ├── formatters.dart
│   │   │   ├── helpers.dart
│   │   │   └── extensions.dart
│   │   ├── extensions/
│   │   │   ├── string_extensions.dart
│   │   │   ├── datetime_extensions.dart
│   │   │   ├── context_extensions.dart
│   │   │   └── widget_extensions.dart
│   │   ├── errors/
│   │   │   ├── app_error.dart
│   │   │   ├── error_handler.dart
│   │   │   └── failure.dart
│   │   ├── network/
│   │   │   ├── dio_client.dart
│   │   │   ├── network_info.dart
│   │   │   └── api_interceptors.dart
│   │   ├── config/
│   │   │   ├── app_config.dart
│   │   │   └── environment.dart
│   │   ├── routing/
│   │   │   ├── app_router.dart
│   │   │   ├── route_names.dart
│   │   │   └── route_guards.dart
│   │   ├── providers/
│   │   │   ├── providers.dart
│   │   │   └── repository_providers.dart
│   │   └── services/
│   │       ├── analytics_service.dart
│   │       ├── hive_service.dart
│   │       ├── notification_service.dart
│   │       ├── image_service.dart
│   │       └── sync_service.dart
│   ├── features/                     # Feature-based modules
│   │   ├── auth/                     # Authentication feature
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   ├── user.dart
│   │   │   │   │   └── auth_result.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   ├── auth_repository.dart
│   │   │   │   │   └── auth_repository_impl.dart
│   │   │   │   └── datasources/
│   │   │   │       ├── auth_remote_datasource.dart
│   │   │   │       └── auth_local_datasource.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── user_entity.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── auth_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── login_usecase.dart
│   │   │   │       ├── register_usecase.dart
│   │   │   │       └── logout_usecase.dart
│   │   │   ├── presentation/
│   │   │   │   ├── controllers/
│   │   │   │   │   └── auth_controller.dart
│   │   │   │   ├── screens/
│   │   │   │   │   ├── login_screen.dart
│   │   │   │   │   ├── register_screen.dart
│   │   │   │   │   ├── forgot_password_screen.dart
│   │   │   │   │   └── splash_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── login_form.dart
│   │   │   │       ├── register_form.dart
│   │   │   │       └── social_login_buttons.dart
│   │   │   └── auth_module.dart
│   │   ├── home/                     # Home feature
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   ├── presentation/
│   │   │   │   ├── controllers/
│   │   │   │   │   └── home_controller.dart
│   │   │   │   ├── screens/
│   │   │   │   │   └── home_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── welcome_section.dart
│   │   │   │       ├── flash_sales_carousel.dart
│   │   │   │       ├── categories_grid.dart
│   │   │   │       └── recommended_products.dart
│   │   │   └── home_module.dart
│   │   ├── products/                 # Product catalog feature
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   ├── product.dart
│   │   │   │   │   ├── category.dart
│   │   │   │   │   ├── product_variant.dart
│   │   │   │   │   └── product_filters.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   ├── product_repository.dart
│   │   │   │   │   └── product_repository_impl.dart
│   │   │   │   └── datasources/
│   │   │   │       ├── product_remote_datasource.dart
│   │   │   │       └── product_local_datasource.dart
│   │   │   ├── domain/
│   │   │   ├── presentation/
│   │   │   │   ├── controllers/
│   │   │   │   │   ├── product_list_controller.dart
│   │   │   │   │   ├── product_details_controller.dart
│   │   │   │   │   └── search_controller.dart
│   │   │   │   ├── screens/
│   │   │   │   │   ├── product_list_screen.dart
│   │   │   │   │   ├── product_details_screen.dart
│   │   │   │   │   ├── categories_screen.dart
│   │   │   │   │   └── search_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── product_card.dart
│   │   │   │       ├── product_grid.dart
│   │   │   │       ├── product_filters.dart
│   │   │   │       ├── search_bar.dart
│   │   │   │       └── category_card.dart
│   │   │   └── products_module.dart
│   │   ├── cart/                     # Shopping cart feature
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   ├── cart.dart
│   │   │   │   │   ├── cart_item.dart
│   │   │   │   │   └── coupon.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   ├── cart_repository.dart
│   │   │   │   │   └── cart_repository_impl.dart
│   │   │   │   └── datasources/
│   │   │   │       ├── cart_remote_datasource.dart
│   │   │   │       └── cart_local_datasource.dart
│   │   │   ├── domain/
│   │   │   ├── presentation/
│   │   │   │   ├── controllers/
│   │   │   │   │   └── cart_controller.dart
│   │   │   │   ├── screens/
│   │   │   │   │   ├── cart_screen.dart
│   │   │   │   │   ├── checkout_screen.dart
│   │   │   │   │   └── payment_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── cart_item_card.dart
│   │   │   │       ├── cart_summary.dart
│   │   │   │       ├── coupon_input.dart
│   │   │   │       └── checkout_form.dart
│   │   │   └── cart_module.dart
│   │   ├── orders/                   # Order management feature
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   ├── order.dart
│   │   │   │   │   ├── order_item.dart
│   │   │   │   │   └── order_status.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   ├── order_repository.dart
│   │   │   │   │   └── order_repository_impl.dart
│   │   │   │   └── datasources/
│   │   │   │       ├── order_remote_datasource.dart
│   │   │   │       └── order_local_datasource.dart
│   │   │   ├── domain/
│   │   │   ├── presentation/
│   │   │   │   ├── controllers/
│   │   │   │   │   ├── orders_controller.dart
│   │   │   │   │   └── order_tracking_controller.dart
│   │   │   │   ├── screens/
│   │   │   │   │   ├── orders_screen.dart
│   │   │   │   │   ├── order_details_screen.dart
│   │   │   │   │   └── order_tracking_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── order_card.dart
│   │   │   │       ├── order_timeline.dart
│   │   │   │       └── tracking_info.dart
│   │   │   └── orders_module.dart
│   │   ├── profile/                  # User profile feature
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   ├── presentation/
│   │   │   │   ├── controllers/
│   │   │   │   │   └── profile_controller.dart
│   │   │   │   ├── screens/
│   │   │   │   │   ├── profile_screen.dart
│   │   │   │   │   ├── settings_screen.dart
│   │   │   │   │   ├── addresses_screen.dart
│   │   │   │   │   └── wishlist_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── profile_header.dart
│   │   │   │       ├── settings_tile.dart
│   │   │   │       └── address_card.dart
│   │   │   └── profile_module.dart
│   │   ├── admin/                    # Admin dashboard feature
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   ├── presentation/
│   │   │   │   ├── controllers/
│   │   │   │   ├── screens/
│   │   │   │   └── widgets/
│   │   │   └── admin_module.dart
│   │   └── shared/                   # Shared widgets and components
│   │       ├── widgets/
│   │       │   ├── app_bar/
│   │       │   │   ├── pharaoh_app_bar.dart
│   │       │   │   └── animated_app_bar.dart
│   │       │   ├── buttons/
│   │       │   │   ├── primary_button.dart
│   │       │   │   ├── secondary_button.dart
│   │       │   │   └── icon_button.dart
│   │       │   ├── cards/
│   │       │   │   ├── base_card.dart
│   │       │   │   └── info_card.dart
│   │       │   ├── forms/
│   │       │   │   ├── custom_text_field.dart
│   │       │   │   ├── dropdown_field.dart
│   │       │   │   └── date_picker_field.dart
│   │       │   ├── loading/
│   │       │   │   ├── shimmer_loading.dart
│   │       │   │   ├── skeleton_loader.dart
│   │       │   │   └── scarab_loader.dart
│   │       │   ├── navigation/
│   │       │   │   ├── bottom_nav_bar.dart
│   │       │   │   └── drawer.dart
│   │       │   ├── images/
│   │       │   │   ├── optimized_network_image.dart
│   │       │   │   ├── image_carousel.dart
│   │       │   │   └── image_placeholder.dart
│   │       │   ├── animations/
│   │       │   │   ├── pharaoh_animations.dart
│   │       │   │   ├── page_transitions.dart
│   │       │   │   └── micro_interactions.dart
│   │       │   └── dialogs/
│   │       │       ├── confirmation_dialog.dart
│   │       │       ├── error_dialog.dart
│   │       │       └── loading_dialog.dart
│   │       └── utils/
│   │           ├── ui_helpers.dart
│   │           ├── responsive_helper.dart
│   │           └── animation_helpers.dart
│   ├── data/                         # Data layer (global)
│   │   ├── models/                   # Shared data models
│   │   │   ├── base_model.dart
│   │   │   ├── api_response.dart
│   │   │   └── pagination.dart
│   │   ├── repositories/             # Repository implementations
│   │   │   └── base_repository.dart
│   │   ├── datasources/              # Data sources
│   │   │   ├── remote/
│   │   │   │   ├── firebase_datasource.dart
│   │   │   │   └── api_datasource.dart
│   │   │   └── local/
│   │   │       ├── hive_datasource.dart
│   │   │       └── shared_prefs_datasource.dart
│   │   └── services/                 # External services
│   │       ├── firebase_service.dart
│   │       ├── payment_service.dart
│   │       ├── notification_service.dart
│   │       └── storage_service.dart
│   ├── generated/                    # Generated files
│   │   ├── l10n.dart                # Localization
│   │   ├── assets.gen.dart          # Asset generation
│   │   └── intl/                    # Internationalization
│   └── l10n/                        # Localization files
│       ├── app_en.arb
│       ├── app_ar.arb
│       └── l10n.yaml
├── assets/                           # Static assets
│   ├── images/                       # Image assets
│   │   ├── logos/
│   │   ├── icons/
│   │   ├── backgrounds/
│   │   └── placeholders/
│   ├── fonts/                        # Custom fonts
│   │   ├── Cinzel-Regular.ttf
│   │   ├── Cinzel-Bold.ttf
│   │   ├── Inter-Regular.ttf
│   │   ├── Inter-Bold.ttf
│   │   ├── Amiri-Regular.ttf
│   │   └── Amiri-Bold.ttf
│   └── animations/                   # Lottie animations
│       ├── loading.json
│       ├── success.json
│       └── error.json
├── test/                            # Unit and widget tests
│   ├── core/
│   ├── features/
│   ├── data/
│   ├── mocks/
│   └── helpers/
├── integration_test/                # Integration tests
│   ├── app_test.dart
│   ├── auth_test.dart
│   ├── cart_test.dart
│   └── helpers/
├── docs/                            # Documentation
│   ├── api/
│   ├── architecture/
│   ├── deployment/
│   └── user_guides/
├── scripts/                         # Build and deployment scripts
│   ├── build_android.sh
│   ├── build_ios.sh
│   ├── deploy.sh
│   └── generate_assets.dart
├── .env.dev                         # Development environment
├── .env.staging                     # Staging environment
├── .env.prod                        # Production environment
├── .gitignore
├── .metadata
├── analysis_options.yaml            # Dart analyzer configuration
├── pubspec.yaml                     # Dependencies and configuration
├── pubspec.lock                     # Locked dependencies
├── README.md                        # Project documentation
├── CHANGELOG.md                     # Version history
├── LICENSE                          # License file
└── NEFER_BLUEPRINT.md              # This comprehensive blueprint
```

## Key Architecture Principles

1. **Feature-First Organization**: Each feature is self-contained with its own data, domain, and presentation layers
2. **Clean Architecture**: Clear separation of concerns with dependency inversion
3. **Shared Components**: Reusable widgets and utilities in the shared module
4. **Configuration Management**: Environment-specific configurations
5. **Comprehensive Testing**: Unit, widget, and integration tests
6. **Documentation**: Detailed documentation for all components
7. **Scalability**: Structure supports easy addition of new features
8. **Maintainability**: Clear naming conventions and organized code structure
