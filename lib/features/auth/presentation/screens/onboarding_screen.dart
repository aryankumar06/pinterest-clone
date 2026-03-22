import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0; // 0=Email, 1=Password, 2=Age

  // Form Controllers
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  
  bool _isPasswordVisible = false;

  void _nextStep() async {
    final authNotifier = ref.read(authProvider.notifier);
    
    // Validations
    if (_currentStep == 0) {
      if (_emailCtrl.text.isEmpty || !_emailCtrl.text.contains('@')) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid email')));
         return;
      }
    }
    
    if (_currentStep == 1) {
      if (_passCtrl.text.length < 8) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password must be at least 8 characters')));
        return;
      }
    }

    if (_currentStep == 2) {
      if (_ageCtrl.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your age')));
        return;
      }
      
      // Final Step -> Register User on Appwrite
      final success = await authNotifier.register(
        _emailCtrl.text.trim(), 
        _passCtrl.text, 
        _emailCtrl.text.split('@')[0], 
      );
      
      if (success) {
        // Optionally save age to preferences
        await authNotifier.updatePreferences({'age': _ageCtrl.text});
        if (mounted) context.go('/home');
      } else {
        if (mounted) {
          final err = ref.read(authProvider).error;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err ?? 'Signup failed')));
        }
      }
      return;
    }

    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    setState(() => _currentStep++);
  }

  void _prevStep() {
    if (_currentStep == 0) {
      context.pop();
    } else {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: _prevStep,
        ),
        title: Text(
          'Sign up',
          style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildEmailStep(),
                _buildPasswordStep(),
                _buildAgeStep(),
              ],
            ),
          ),
          _buildBottomAction(),
        ],
      ),
    );
  }

  Widget _buildEmailStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What's your email?", 
            style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5)
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailCtrl,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            cursorColor: const Color(0xFFE60023),
            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600),
            decoration: const InputDecoration(
              hintText: 'Email address',
              hintStyle: TextStyle(color: Colors.black26),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Create a password", 
            style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5)
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passCtrl,
            autofocus: true,
            obscureText: !_isPasswordVisible,
            cursorColor: const Color(0xFFE60023),
            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              suffixIcon: IconButton(
                icon: const Icon(Icons.cancel, color: Colors.black12),
                onPressed: () => _passCtrl.clear(),
              )
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            child: Row(
              children: [
                 Container(
                   padding: const EdgeInsets.all(2),
                   decoration: BoxDecoration(
                     color: _isPasswordVisible ? Colors.black : Colors.transparent,
                     shape: BoxShape.circle,
                     border: Border.all(color: _isPasswordVisible ? Colors.black : Colors.black26, width: 2)
                   ),
                   child: Icon(Icons.check, size: 14, color: _isPasswordVisible ? Colors.white : Colors.transparent),
                 ),
                 const SizedBox(width: 8),
                 Text('Show password', style: GoogleFonts.inter(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500))
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeStep() {
    final name = _emailCtrl.text.isNotEmpty ? _emailCtrl.text.split('@')[0] : 'User';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("Hi $name", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(width: 4),
              const Icon(Icons.edit, size: 16, color: Colors.black),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "How old are you?", 
            style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5)
          ),
          const SizedBox(height: 12),
          Text(
            "This helps us find you more relevant content. We won't show it on your profile.", 
            style: GoogleFonts.inter(color: Colors.black54, fontSize: 15, fontWeight: FontWeight.w500)
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _ageCtrl,
            keyboardType: TextInputType.number,
            autofocus: true,
            cursorColor: const Color(0xFFE60023),
            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600),
            decoration: const InputDecoration(
              hintText: 'Age',
              hintStyle: TextStyle(color: Colors.black26),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    final progress = (_currentStep + 1) / 3;
    final isLoading = ref.watch(authProvider).isLoading;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${_currentStep + 1} of 3', 
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.black12,
              valueColor: const AlwaysStoppedAnimation(Colors.black),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isLoading ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE60023),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
              child: isLoading 
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Next', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

