import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:f1sync/core/theme/f1_colors.dart';
import 'package:f1sync/core/theme/f1_text_styles.dart';
import 'package:f1sync/core/constants/app_constants.dart';
import 'package:f1sync/shared/services/providers.dart';

/// Settings Screen
///
/// Provides app configuration options including:
/// - Clear cache
/// - App info
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isClearing = false;

  Future<void> _clearCache() async {
    setState(() => _isClearing = true);

    try {
      final cacheService = ref.read(cacheServiceProvider);
      await cacheService.clearAll();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Cache limpo com sucesso!'),
              ],
            ),
            backgroundColor: F1Colors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Erro ao limpar cache: $e')),
              ],
            ),
            backgroundColor: F1Colors.vermelho,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isClearing = false);
      }
    }
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: F1Colors.navy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Limpar Cache',
          style: F1TextStyles.headlineSmall.copyWith(
            color: F1Colors.textPrimary,
          ),
        ),
        content: Text(
          'Isso irá remover todos os dados em cache. O app precisará baixar os dados novamente da API.',
          style: F1TextStyles.bodyMedium.copyWith(
            color: F1Colors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(color: F1Colors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearCache();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: F1Colors.vermelho,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: F1Colors.navyDeep,
      appBar: AppBar(
        backgroundColor: F1Colors.navyDeep,
        title: Text(
          'Configurações',
          style: F1TextStyles.headlineSmall.copyWith(
            color: F1Colors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Cache Section
          _buildSectionHeader('Armazenamento'),
          const SizedBox(height: 8),
          _buildSettingsTile(
            icon: Icons.cached,
            title: 'Limpar Cache',
            subtitle: 'Remove dados em cache para forçar atualização',
            trailing: _isClearing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: F1Colors.vermelho,
                    ),
                  )
                : const Icon(
                    Icons.chevron_right,
                    color: F1Colors.textSecondary,
                  ),
            onTap: _isClearing ? null : _showClearCacheDialog,
          ),

          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader('Sobre'),
          const SizedBox(height: 8),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: AppConstants.appName,
            subtitle: 'Versão ${AppConstants.appVersion}',
            onTap: null,
          ),
          _buildSettingsTile(
            icon: Icons.code,
            title: 'API',
            subtitle: 'Powered by Jolpica F1 API',
            onTap: null,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: F1TextStyles.bodySmall.copyWith(
          color: F1Colors.textSecondary,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: F1Colors.navy,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: F1Colors.border,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: F1Colors.navyLight.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: F1TextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: F1TextStyles.bodySmall.copyWith(
            color: F1Colors.textSecondary,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
