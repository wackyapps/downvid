import 'package:flutter/material.dart';

class LanguageModel {
  final String code;
  final String name;
  final String flagAsset;

  const LanguageModel({
    required this.code,
    required this.name,
    required this.flagAsset,
  });
}

class LanguagesListScreen extends StatefulWidget {
  const LanguagesListScreen({super.key});

  @override
  State<LanguagesListScreen> createState() => _LanguagesListScreenState();
}

class _LanguagesListScreenState extends State<LanguagesListScreen> {
  String _selectedLanguageCode = 'en'; // Default: English

  final List<LanguageModel> _languages = const [
    LanguageModel(code: 'en', name: 'English', flagAsset: 'assets/flags/en.png'),
    LanguageModel(code: 'af', name: 'Afrikaans', flagAsset: 'assets/flags/af.png'),
    LanguageModel(code: 'sq', name: 'Albanian', flagAsset: 'assets/flags/sq.png'),
    LanguageModel(code: 'am', name: 'Amharic', flagAsset: 'assets/flags/am.png'),
    LanguageModel(code: 'ar', name: 'Arabic', flagAsset: 'assets/flags/ar.png'),
    LanguageModel(code: 'hy', name: 'Armenian', flagAsset: 'assets/flags/hy.png'),
    LanguageModel(code: 'az', name: 'Azerbaijan', flagAsset: 'assets/flags/az.png'),
    LanguageModel(code: 'bn', name: 'Bangla', flagAsset: 'assets/flags/bn.png'),
    LanguageModel(code: 'eu', name: 'Basque', flagAsset: 'assets/flags/eu.png'),
    LanguageModel(code: 'be', name: 'Belarusian', flagAsset: 'assets/flags/be.png'),
    // Add more as needed...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3B82F6)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Language',
          style: TextStyle(
            color: Color(0xFF3B82F6),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'DONE',
              style: TextStyle(
                color: Color(0xFF3B82F6),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _languages.length,
        itemBuilder: (context, index) {
          final lang = _languages[index];
          final isSelected = _selectedLanguageCode == lang.code;

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF0F7FF) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFF3B82F6) : Colors.grey.shade200,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: ClipOval(
                child: Image.asset(
                  lang.flagAsset,
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.flag, size: 32);
                  },
                ),
              ),
              title: Text(
                lang.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? const Color(0xFF3B82F6) : Colors.black87,
                ),
              ),
              trailing: Radio<String>(
                value: lang.code,
                groupValue: _selectedLanguageCode,
                activeColor: const Color(0xFF3B82F6),
                onChanged: (value) {
                  setState(() {
                    _selectedLanguageCode = value!;
                  });
                },
              ),
              onTap: () {
                setState(() {
                  _selectedLanguageCode = lang.code;
                });
              },
            ),
          );
        },
      ),
    );
  }
}