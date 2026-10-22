enum ChannelPermissionFlag {
  publicChannel(bit: 1 << 0, name: 'Public Channel', description: '', icon: ''),
  sendMessage(bit: 1 << 1, name: 'Send Message', description: '', icon: ''),
  joinVoice(bit: 1 << 2, name: 'Join Voice', description: '', icon: '');

  final int bit;
  final String name;
  final String description;
  final String icon;

  const ChannelPermissionFlag({
    required this.bit,
    required this.name,
    required this.description,
    required this.icon,
  });
}
