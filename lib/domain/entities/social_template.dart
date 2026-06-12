import 'package:flutter/material.dart';

class SocialTemplate {
  final String id;
  final String namePtBr;
  final String nameEn;
  final String nameEs;
  final Color backgroundColor;
  final Color accentColor;
  final bool isFree;

  const SocialTemplate({
    required this.id,
    required this.namePtBr,
    required this.nameEn,
    required this.nameEs,
    required this.backgroundColor,
    required this.accentColor,
    this.isFree = true,
  });
}

const kSocialTemplates = [
  SocialTemplate(
    id: 'default',
    namePtBr: 'Apex Dark',
    nameEn: 'Apex Dark',
    nameEs: 'Apex Dark',
    backgroundColor: Color(0xFF080808),
    accentColor: Color(0xFF22C55E),
    isFree: true,
  ),
  SocialTemplate(
    id: 'cyber',
    namePtBr: 'Cyber Blue',
    nameEn: 'Cyber Blue',
    nameEs: 'Cyber Blue',
    backgroundColor: Color(0xFF050515),
    accentColor: Color(0xFF3B82F6),
    isFree: true,
  ),
  SocialTemplate(
    id: 'energy',
    namePtBr: 'Energy',
    nameEn: 'Energy',
    nameEs: 'Energy',
    backgroundColor: Color(0xFF0A0505),
    accentColor: Color(0xFFF97316),
    isFree: false,
  ),
];
