import 'package:flutter/material.dart';

enum CharacterHairStyle { messy, visor, longHair, bun, cropped }
enum CharacterClothing { jacket, hoodie, collar, utility, layered }
enum CharacterAccessory { headphones, orb, badge, notebook, none }
enum CharacterMotion { subtle, attentive, analytical, adaptive, energetic }

/// Single source of truth for visual identity. New sprint characters register
/// here without changing the animation engine.
class CharacterVisualProfile {
  final String characterId;
  final Color skin;
  final Color face;
  final Color body;
  final Color trousers;
  final Color hair;
  final Color accent;
  final Color dark;
  final CharacterHairStyle hairStyle;
  final CharacterClothing clothing;
  final CharacterAccessory accessory;
  final CharacterMotion idleMotion;
  final CharacterMotion workMotion;

  const CharacterVisualProfile({
    required this.characterId,
    required this.skin,
    required this.face,
    required this.body,
    required this.trousers,
    required this.hair,
    required this.accent,
    required this.dark,
    required this.hairStyle,
    required this.clothing,
    required this.accessory,
    required this.idleMotion,
    required this.workMotion,
  });

  static const Map<String, CharacterVisualProfile> registry = {
    'dharen': CharacterVisualProfile(characterId:'dharen', skin:Color(0xffc98964), face:Color(0xffffd7bc), body:Color(0xff8b5e3c), trousers:Color(0xff403d46), hair:Color(0xff34251f), accent:Color(0xffd98b43), dark:Color(0xff201b1a), hairStyle:CharacterHairStyle.messy, clothing:CharacterClothing.jacket, accessory:CharacterAccessory.notebook, idleMotion:CharacterMotion.analytical, workMotion:CharacterMotion.analytical),
    'sandre': CharacterVisualProfile(characterId:'sandre', skin:Color(0xffa96f58), face:Color(0xffffcbb5), body:Color(0xff496d6d), trousers:Color(0xff343f43), hair:Color(0xff2d2522), accent:Color(0xff63b9a8), dark:Color(0xff1d2527), hairStyle:CharacterHairStyle.longHair, clothing:CharacterClothing.collar, accessory:CharacterAccessory.badge, idleMotion:CharacterMotion.subtle, workMotion:CharacterMotion.attentive),
    'kaelen': CharacterVisualProfile(characterId:'kaelen', skin:Color(0xffbd805e), face:Color(0xffffd1b8), body:Color(0xff50575f), trousers:Color(0xff20252a), hair:Color(0xff1d1b1b), accent:Color(0xfff19a3e), dark:Color(0xff17191c), hairStyle:CharacterHairStyle.messy, clothing:CharacterClothing.jacket, accessory:CharacterAccessory.headphones, idleMotion:CharacterMotion.subtle, workMotion:CharacterMotion.energetic),
    'anuka': CharacterVisualProfile(characterId:'anuka', skin:Color(0xffd69a79), face:Color(0xffffdfcf), body:Color(0xfff0b9c8), trousers:Color(0xff343044), hair:Color(0xff2a2025), accent:Color(0xffbd7fe4), dark:Color(0xff221b27), hairStyle:CharacterHairStyle.bun, clothing:CharacterClothing.hoodie, accessory:CharacterAccessory.orb, idleMotion:CharacterMotion.adaptive, workMotion:CharacterMotion.adaptive),
    'syvax': CharacterVisualProfile(characterId:'syvax', skin:Color(0xffb87c63), face:Color(0xffffd4bd), body:Color(0xff344d63), trousers:Color(0xff252d36), hair:Color(0xff17232e), accent:Color(0xff62d8f5), dark:Color(0xff14202a), hairStyle:CharacterHairStyle.visor, clothing:CharacterClothing.hoodie, accessory:CharacterAccessory.headphones, idleMotion:CharacterMotion.subtle, workMotion:CharacterMotion.attentive),
  };

  static CharacterVisualProfile? forId(String id) => registry[id.trim().toLowerCase()];
}
