import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

enum NeriBranch { dashboard, servers, explore }

sealed class NeriDestination {
  const NeriDestination({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

final class BranchDestination extends NeriDestination {
  const BranchDestination({
    required super.label,
    required super.icon,
    required this.branch,
  });

  final NeriBranch branch;
}

final class PageDestination extends NeriDestination {
  const PageDestination({
    required super.label,
    required super.icon,
    required this.path,
  });

  final String path;
}

final class AvatarDestination extends NeriDestination {
  const AvatarDestination({required super.label, required super.icon});
}

const neriDestinations = <NeriDestination>[
  BranchDestination(
    label: 'Home',
    icon: Symbols.home_rounded,
    branch: NeriBranch.dashboard,
  ),
  BranchDestination(
    label: 'Explore',
    icon: Symbols.explore_rounded,
    branch: NeriBranch.explore, // sub-routes: /servers, /bots, /themes
  ),
  PageDestination(
    label: 'Settings',
    icon: Symbols.settings_rounded,
    path: '/app/settings',
  ),
  AvatarDestination(label: 'Profile', icon: Symbols.person_rounded),
];
