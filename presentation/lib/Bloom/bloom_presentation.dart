import 'package:flutter/material.dart';
import '../interaction/bloom.dart';

class BloomPresentation {
  static const capabilities = <BloomCapability>[
    BloomCapability.analyze,
    BloomCapability.stewardship,
    BloomCapability.compare,
    BloomCapability.explore,
    BloomCapability.plan,
    BloomCapability.insights,
    BloomCapability.explain,
  ];

  static const companionMessage = 'Bloom is the civilization gateway and companion. It exposes capability paths and follows the human through Criterivox.';
  static const capabilityCount = 7;
}
