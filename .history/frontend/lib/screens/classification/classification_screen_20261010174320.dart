if (connectivity.isOffline) ...[
  const SizedBox(height: 16),

  OfflineBanner(
    message:
        'Internet connection is required to classify '
        'Guso images. You can still review the selected '
        'image while offline.',
    onRetry: () async {
      await context
          .read<ConnectivityProvider>()
          .refreshConnection();

      if (!mounted) return;

      final isOnline =
          context
              .read<ConnectivityProvider>()
              .isOnline;

      if (isOnline) {
        setState(() {
          _errorMessage = null;
        });
      }
    },
  ),
],