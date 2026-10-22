enum RolePermissionFlag {
  admin(bit: 1 << 0, name: '', description: '', icon: ''),
  sendMessage(bit: 1 << 1, name: '', description: '', icon: ''),
  manageRoles(bit: 1 << 2, name: '', description: 'G', icon: ''),
  manageChannels(bit: 1 << 3, name: '', description: '', icon: ''),
  kick(bit: 1 << 4, name: '', description: '', icon: ''),
  ban(bit: 1 << 5, name: '', description: '', icon: ''),
  mentionEveryone(bit: 1 << 6, name: '', description: '', icon: ''),
  nicknameMember(bit: 1 << 7, name: '', description: '', icon: ''),
  mentionRoles(bit: 1 << 8, name: '', description: '', icon: '');

  final int bit;
  final String name;
  final String description;
  final String icon;

  const RolePermissionFlag({
    required this.bit,
    required this.name,
    required this.description,
    required this.icon,
  });
}
