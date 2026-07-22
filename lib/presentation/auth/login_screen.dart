import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _auth = Get.find<AuthService>();
  bool _obscurePassword = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final success =
        await _auth.signIn(_emailController.text.trim(), _passwordController.text);
    if (!success && _auth.errorMessage.isNotEmpty) {
      Get.snackbar('خطأ في تسجيل الدخول', _auth.errorMessage.value,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.error_rounded, color: Colors.white));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 700;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: isWide ? 480 : double.infinity,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(80),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.accentGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withAlpha(80),
                              blurRadius: 20,
                              spreadRadius: 4,
                            )
                          ],
                        ),
                        child: const Icon(Icons.shield_rounded,
                            color: Colors.white, size: 40),
                      ),
                      const SizedBox(height: 20),
                      const Text('مرحباً بك',
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 6),
                      const Text('سجّل دخولك للوحة التحكم',
                          style: TextStyle(
                              fontSize: 14, color: AppColors.textSecondary)),
                      const SizedBox(height: 36),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'البريد الإلكتروني',
                          prefixIcon: Icon(Icons.email_rounded,
                              color: AppColors.textMuted),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'أدخل البريد الإلكتروني';
                          if (!GetUtils.isEmail(v)) return 'بريد إلكتروني غير صحيح';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password
                      Obx(() => TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textDirection: TextDirection.ltr,
                            style: const TextStyle(color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              labelText: 'كلمة المرور',
                              prefixIcon: const Icon(Icons.lock_rounded,
                                  color: AppColors.textMuted),
                              suffixIcon: IconButton(
                                icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_rounded
                                        : Icons.visibility_off_rounded,
                                    color: AppColors.textMuted),
                                onPressed: () =>
                                    setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'أدخل كلمة المرور';
                              if (v.length < 6) return 'كلمة المرور قصيرة جداً';
                              return null;
                            },
                          )),
                      const SizedBox(height: 8),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: _showResetDialog,
                          child: const Text('نسيت كلمة المرور؟',
                              style: TextStyle(color: AppColors.accent)),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Login Button
                      Obx(() => SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _auth.isLoading.value ? null : _login,
                              child: _auth.isLoading.value
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white))
                                  : const Text('تسجيل الدخول',
                                      style: TextStyle(fontSize: 16)),
                            ),
                          )),
                      const SizedBox(height: 24),
                      Text('Elkhalfy Admin v1.0',
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showResetDialog() {
    final ctrl = TextEditingController();
    Get.dialog(AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('استعادة كلمة المرور',
          style: TextStyle(color: AppColors.textPrimary)),
      content: TextFormField(
        controller: ctrl,
        keyboardType: TextInputType.emailAddress,
        textDirection: TextDirection.ltr,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
      ),
      actions: [
        TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء',
                style: TextStyle(color: AppColors.textSecondary))),
        ElevatedButton(
          onPressed: () async {
            if (ctrl.text.isNotEmpty) {
              await _auth.resetPassword(ctrl.text.trim());
              Get.back();
              Get.snackbar('تم الإرسال', 'تم إرسال رابط الاستعادة على بريدك',
                  backgroundColor: AppColors.success, colorText: Colors.white);
            }
          },
          child: const Text('إرسال'),
        ),
      ],
    ));
  }
}
