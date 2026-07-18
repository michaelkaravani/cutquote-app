import 'package:flutter/material.dart';

/// Error boundary widget that catches errors in its child widget tree
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Function(FlutterErrorDetails)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetails? _errorDetails;

  @override
  Widget build(BuildContext context) {
    if (_errorDetails != null) {
      return ErrorScreen(
        errorDetails: _errorDetails!,
        onRetry: () {
          setState(() {
            _errorDetails = null;
          });
        },
      );
    }

    return widget.child;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reset error on navigation
    _errorDetails = null;
  }
}

/// User-friendly error screen
class ErrorScreen extends StatelessWidget {
  final FlutterErrorDetails errorDetails;
  final VoidCallback onRetry;

  const ErrorScreen({
    super.key,
    required this.errorDetails,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.grey[50],
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Error icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: Colors.red.shade400,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Error title
                  Text(
                    'אופס! משהו השתבש',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Error description
                  Text(
                    'נתקלנו בבעיה בלתי צפויה. אנחנו מצטערים על אי הנוחות.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Action buttons
                  Column(
                    children: [
                      // Retry button
                      ElevatedButton.icon(
                        onPressed: onRetry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.refresh, size: 20),
                        label: const Text(
                          'נסה שוב',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Show details button (debug mode)
                      if (const bool.fromEnvironment('dart.vm.product') == false)
                        TextButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => _ErrorDetailsDialog(
                                errorDetails: errorDetails,
                              ),
                            );
                          },
                          icon: const Icon(Icons.info_outline, size: 18),
                          label: const Text('הצג פרטים טכניים'),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Help text
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'אם הבעיה נמשכת, נסה לצאת ולהיכנס שוב לאפליקציה',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.blue.shade200 : Colors.blue.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dialog showing technical error details (debug mode only)
class _ErrorDetailsDialog extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const _ErrorDetailsDialog({required this.errorDetails});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('פרטים טכניים'),
        content: SingleChildScrollView(
          child: SelectableText(
            errorDetails.toString(),
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('סגור'),
          ),
        ],
      ),
    );
  }
}
