# 🤝 Contributing to Nefer

Thank you for your interest in contributing to Nefer! This document provides guidelines and information for contributors.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Issue Reporting](#issue-reporting)

## 📜 Code of Conduct

By participating in this project, you agree to abide by our Code of Conduct:

- Be respectful and inclusive
- Use welcoming and inclusive language
- Be collaborative and constructive
- Focus on what is best for the community
- Show empathy towards other community members

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.16.0+
- Dart SDK 3.2.0+
- Firebase CLI
- Node.js 16+
- Git

### Setup Development Environment

1. **Fork and clone the repository**
   ```bash
   git clone https://github.com/your-username/nefer.git
   cd nefer
   ```

2. **Setup the project**
   ```bash
   make setup
   # or manually:
   flutter pub get
   flutter packages pub run build_runner build
   flutter gen-l10n
   ```

3. **Configure Firebase**
   ```bash
   firebase login
   firebase use --add  # Select your Firebase project
   ```

4. **Run the app**
   ```bash
   make dev
   # or: flutter run --flavor dev
   ```

## 🔄 Development Workflow

### Branch Naming Convention

- `feature/description` - New features
- `bugfix/description` - Bug fixes
- `hotfix/description` - Critical fixes
- `docs/description` - Documentation updates
- `refactor/description` - Code refactoring
- `test/description` - Test improvements

### Development Process

1. **Create a new branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```

2. **Make your changes**
   - Follow coding standards
   - Write tests for new features
   - Update documentation if needed

3. **Test your changes**
   ```bash
   make test
   make analyze
   ```

4. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: add amazing feature"
   ```

5. **Push and create PR**
   ```bash
   git push origin feature/amazing-feature
   ```

## 📝 Coding Standards

### Dart/Flutter Guidelines

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `dart format` for code formatting
- Run `flutter analyze` to check for issues
- Prefer composition over inheritance
- Use meaningful variable and function names

### Code Organization

```dart
// Good: Clear, descriptive naming
class ProductListController extends StateNotifier<ProductListState> {
  final ProductRepository _productRepository;
  
  ProductListController(this._productRepository) : super(const ProductListState.loading());
  
  Future<void> loadProducts() async {
    // Implementation
  }
}

// Bad: Unclear naming
class PLC extends StateNotifier<PLS> {
  final PR _pr;
  // ...
}
```

### Architecture Guidelines

- Follow Clean Architecture principles
- Use Riverpod for state management
- Implement proper error handling
- Use Freezed for immutable models
- Separate business logic from UI

### File Structure

```
lib/features/feature_name/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
└── presentation/
    ├── controllers/
    ├── screens/
    └── widgets/
```

## 🧪 Testing Guidelines

### Test Types

1. **Unit Tests** - Test individual functions/classes
2. **Widget Tests** - Test UI components
3. **Integration Tests** - Test complete user flows

### Writing Tests

```dart
// Unit test example
group('ProductController', () {
  late ProductController controller;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    controller = ProductController(mockRepository);
  });

  test('should load products successfully', () async {
    // Arrange
    when(() => mockRepository.getProducts())
        .thenAnswer((_) async => [mockProduct]);

    // Act
    await controller.loadProducts();

    // Assert
    expect(controller.state, isA<ProductListLoaded>());
  });
});
```

### Test Coverage

- Aim for >80% test coverage
- Test happy paths and error cases
- Mock external dependencies
- Use meaningful test descriptions

### Running Tests

```bash
# All tests
make test

# Specific test types
make test-unit
make test-widget
make test-integration

# With coverage
make test-coverage
```

## 📝 Commit Guidelines

### Commit Message Format

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types

- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation changes
- `style` - Code style changes (formatting, etc.)
- `refactor` - Code refactoring
- `test` - Adding or updating tests
- `chore` - Maintenance tasks

### Examples

```bash
feat(auth): add Google Sign-In support
fix(cart): resolve item duplication issue
docs(readme): update installation instructions
test(products): add unit tests for ProductController
```

### Scope Guidelines

- `auth` - Authentication features
- `products` - Product-related features
- `cart` - Shopping cart functionality
- `orders` - Order management
- `admin` - Admin dashboard
- `ui` - UI components
- `core` - Core functionality

## 🔍 Pull Request Process

### Before Submitting

1. **Ensure tests pass**
   ```bash
   make test
   make analyze
   ```

2. **Update documentation** if needed

3. **Add/update tests** for new features

4. **Follow commit message conventions**

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Widget tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Screenshots (if applicable)
Add screenshots for UI changes

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Tests added/updated
- [ ] Documentation updated
```

### Review Process

1. **Automated checks** must pass
2. **Code review** by maintainers
3. **Testing** on different devices/platforms
4. **Approval** from at least one maintainer

## 🐛 Issue Reporting

### Bug Reports

Use the bug report template:

```markdown
**Describe the bug**
Clear description of the bug

**To Reproduce**
Steps to reproduce the behavior

**Expected behavior**
What you expected to happen

**Screenshots**
If applicable, add screenshots

**Environment:**
- Device: [e.g. iPhone 12]
- OS: [e.g. iOS 15.0]
- App Version: [e.g. 1.0.0]

**Additional context**
Any other context about the problem
```

### Feature Requests

Use the feature request template:

```markdown
**Is your feature request related to a problem?**
Clear description of the problem

**Describe the solution you'd like**
Clear description of what you want to happen

**Describe alternatives you've considered**
Alternative solutions or features

**Additional context**
Any other context or screenshots
```

## 🏷️ Labels

We use labels to categorize issues and PRs:

- `bug` - Something isn't working
- `enhancement` - New feature or request
- `documentation` - Improvements or additions to docs
- `good first issue` - Good for newcomers
- `help wanted` - Extra attention is needed
- `priority: high` - High priority
- `priority: low` - Low priority

## 🎯 Areas for Contribution

### High Priority

- Performance optimizations
- Accessibility improvements
- Test coverage improvements
- Documentation enhancements

### Medium Priority

- New payment methods
- Additional languages
- UI/UX improvements
- Admin dashboard features

### Low Priority

- Code refactoring
- Developer tools
- Example applications
- Blog posts/tutorials

## 📞 Getting Help

- **Discord**: [Join our community](https://discord.gg/nefer)
- **GitHub Discussions**: For questions and discussions
- **Email**: dev@nefer-ecommerce.com

## 🙏 Recognition

Contributors will be recognized in:

- README.md contributors section
- Release notes
- Hall of Fame page
- Special Discord role

Thank you for contributing to Nefer! 🏛️
