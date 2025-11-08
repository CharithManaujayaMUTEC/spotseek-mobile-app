class Profile {
  final String name;
  final String avatarUrl;
  final bool appNotifications;
  final bool appPermissions;
  final String version;

  Profile({required this.name, required this.avatarUrl, required this.appNotifications, required this.appPermissions, required this.version});

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
        name: j['name']?.toString() ?? '',
        avatarUrl: j['avatarUrl']?.toString() ?? '',
        appNotifications: j['appNotifications'] is bool ? j['appNotifications'] as bool : (j['appNotifications']?.toString() == 'true'),
        appPermissions: j['appPermissions'] is bool ? j['appPermissions'] as bool : (j['appPermissions']?.toString() == 'true'),
        version: j['version']?.toString() ?? '1.0.0',
      );
}
