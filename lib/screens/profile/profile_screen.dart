import 'package:datingappflutter/providers/auth_provider.dart';
import 'package:datingappflutter/providers/stream_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'edit_profile_screen.dart';
import '../../providers/current_profile_provider.dart';
import '../../utils/calculate_age.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);

    return Scaffold(
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Failed to load profile'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  ref.invalidate(currentProfileProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (userProfile) {
          if (userProfile == null) {
            return const Center(child: Text('Profile not found'));
          }

          final age = calculateAge(userProfile.birthdate);

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                title: const Text('My Profile'),
                floating: true,
                snap: true,
                actions: [
                  IconButton(
                    onPressed: () async {
                      await ref.read(streamServiceProvider).disconnect();
                      await ref.read(authServiceProvider).signOut();
                    },
                    icon: const Icon(Icons.logout),
                    tooltip: 'Sign Out',
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage:
                              userProfile.avatarUrl != null &&
                                  userProfile.avatarUrl!.isNotEmpty
                              ? NetworkImage(userProfile.avatarUrl!)
                              : null,
                          child:
                              userProfile.avatarUrl == null ||
                                  userProfile.avatarUrl!.isEmpty
                              ? const Icon(Icons.person, size: 60)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          '${userProfile.fullName}, $age',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          '@${userProfile.username}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Member since ${userProfile.createdAt.substring(0, 10)}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'About Me',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          userProfile.bio.isEmpty
                              ? 'No bio added yet.'
                              : userProfile.bio,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Basic Information',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.person_outline),
                              title: const Text('Gender'),
                              trailing: Text(userProfile.gender),
                            ),
                            ListTile(
                              leading: const Icon(Icons.cake_outlined),
                              title: const Text('Birthday'),
                              trailing: Text(userProfile.birthdate),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditProfileScreen(profile: userProfile),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Profile'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}