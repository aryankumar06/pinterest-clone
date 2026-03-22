import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  // Pinterest aesthetic demo images
  final List<String> col1Images = [
    'https://images.unsplash.com/photo-1517849845537-4d257902454a?w=400',
    'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400',
    'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=400',
    'https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0?w=400',
    'https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d?w=400',
  ];

  final List<String> col2Images = [
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
    'https://images.unsplash.com/photo-1549488344-9f2683dc0924?w=400',
    'https://images.unsplash.com/photo-1542241647-9cbbada2dd8d?w=400',
    'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=400',
    'https://images.unsplash.com/photo-1517849845537-4d257902454a?w=400',
  ];

  late ScrollController _scrollController1;
  late ScrollController _scrollController2;
  late ScrollController _scrollController3;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scrollController1 = ScrollController();
    _scrollController2 = ScrollController();
    _scrollController3 = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  void _startScrolling() {
    const double speed = 0.5;
    _timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) return;
      
      if (_scrollController1.hasClients) {
        _scrollController1.jumpTo(_scrollController1.offset + speed);
      }
      if (_scrollController2.hasClients) {
        _scrollController2.jumpTo(_scrollController2.offset + (speed * 1.5));
      }
      if (_scrollController3.hasClients) {
        _scrollController3.jumpTo(_scrollController3.offset + (speed * 0.8));
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController1.dispose();
    _scrollController2.dispose();
    _scrollController3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Infinite Motion Grid
          Positioned(
            top: -50,
            left: 0,
            right: 0,
            bottom: size.height * 0.4,
            child: ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black, Colors.transparent],
                  stops: [0.7, 1.0],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: Row(
                children: [
                  Expanded(child: _ScrollingColumn(controller: _scrollController1, images: col1Images)),
                  const SizedBox(width: 8),
                  Expanded(child: _ScrollingColumn(controller: _scrollController2, images: col2Images)),
                  const SizedBox(width: 8),
                  Expanded(child: _ScrollingColumn(controller: _scrollController3, images: col1Images.reversed.toList())),
                ],
              ),
            ),
          ),
          
          // Bottom Content
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.45,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                   // Pinterest Logo
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE60023),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          'P',
                          style: GoogleFonts.notoSerif(
                            color: Colors.white,
                            fontSize: 50,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Text(
                    'Welcome to Pinterest',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => context.push('/onboarding'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE60023),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'Sign up',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Log In Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => context.push('/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE9E9E9),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'Log in',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const Spacer(),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'By continuing, you agree to Pinterest\'s Terms of Service and acknowledge you\'ve read our Privacy Policy',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: Colors.black54, height: 1.4),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScrollingColumn extends StatelessWidget {
  const _ScrollingColumn({required this.controller, required this.images});
  final ScrollController controller;
  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 9999,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final image = images[index % images.length];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              image,
              fit: BoxFit.cover,
              height: (index % 3 == 0) ? 180 : (index % 3 == 1 ? 240 : 200),
            ),
          ),
        );
      },
    );
  }
}


