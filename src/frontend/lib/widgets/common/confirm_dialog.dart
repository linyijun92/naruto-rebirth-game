import 'package:flutter/material.dart';

/// 确认对话框组件
///
/// 用于删除确认、退出确认等场景
/// 流畅的弹出动画
class ConfirmDialog extends StatefulWidget {
  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText,
    this.cancelText,
    required this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
  });

  @override
  State<ConfirmDialog> createState() => _ConfirmDialogState();

  /// 显示确认对话框
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm ?? () => Navigator.of(context).pop(true),
        onCancel: onCancel ?? () => Navigator.of(context).pop(false),
        isDestructive: isDestructive,
      ),
    );
  }
}

class _ConfirmDialogState extends State<ConfirmDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: const Color(0xFF1a1a2e),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: widget.isDestructive
                  ? Colors.red.withOpacity(0.5)
                  : Colors.orange.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                Row(
                  children: [
                    Icon(
                      widget.isDestructive ? Icons.warning_amber : Icons.info_outline,
                      color: widget.isDestructive ? Colors.red : Colors.orange,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 消息
                Text(
                  widget.message,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),

                // 按钮区域
                Row(
                  children: [
                    // 取消按钮（灰色）
                    Expanded(
                      child: TextButton(
                        onPressed: widget.onCancel,
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          foregroundColor: Colors.white70,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          widget.cancelText ?? '取消',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 确认按钮（橙色或红色）
                    Expanded(
                      child: ElevatedButton(
                        onPressed: widget.onConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.isDestructive
                              ? Colors.red
                              : Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          widget.confirmText ?? '确认',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 便捷方法：显示删除确认对话框
Future<bool?> showDeleteConfirmDialog(
  BuildContext context, {
  required String itemName,
  VoidCallback? onConfirm,
}) {
  return ConfirmDialog.show(
    context,
    title: '确认删除',
    message: '确定要删除 "$itemName" 吗？\n此操作无法撤销。',
    confirmText: '删除',
    cancelText: '取消',
    onConfirm: onConfirm,
    isDestructive: true,
  );
}

/// 便捷方法：显示退出确认对话框
Future<bool?> showExitConfirmDialog(
  BuildContext context, {
  String? content,
  VoidCallback? onConfirm,
}) {
  return ConfirmDialog.show(
    context,
    title: '确认退出',
    message: content ?? '确定要退出吗？未保存的进度将会丢失。',
    confirmText: '退出',
    cancelText: '取消',
    onConfirm: onConfirm,
    isDestructive: false,
  );
}

/// 便捷方法：显示放弃确认对话框
Future<bool?> showAbandonConfirmDialog(
  BuildContext context, {
  required String itemName,
  VoidCallback? onConfirm,
}) {
  return ConfirmDialog.show(
    context,
    title: '确认放弃',
    message: '确定要放弃 "$itemName" 吗？',
    confirmText: '放弃',
    cancelText: '取消',
    onConfirm: onConfirm,
    isDestructive: false,
  );
}
