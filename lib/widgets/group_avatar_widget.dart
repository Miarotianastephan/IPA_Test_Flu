import 'package:flutter/material.dart';
import 'package:live_app/models/conversation_user.dart';

class GroupAvatarWidget extends StatelessWidget {
  final List<ConversationUser> members;
  final double size;
  final String? groupAvatarUrl;

  const GroupAvatarWidget({
    super.key,
    required this.members,
    this.size = 48,
    this.groupAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (groupAvatarUrl != null && groupAvatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: Colors.grey[800],
        child: ClipOval(
          child: Image.network(
            groupAvatarUrl!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.group, size: size * 0.6, color: Colors.white);
            },
          ),
        ),
      );
    }

    final validMembers = members
        .where((m) => m.user != null && m.user!.avatar != null)
        .toList();

    if (validMembers.isEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: Colors.grey[800],
        child: Icon(Icons.group, size: size * 0.6, color: Colors.white),
      );
    }

    final displayMembers = validMembers.take(4).toList();

    if (displayMembers.length == 1) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: Colors.grey[800],
        child: ClipOval(
          child: Image.network(
            displayMembers[0].user!.avatar!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Text(
                displayMembers[0].user!.nickname?.substring(0, 1) ?? "?",
                style: TextStyle(color: Colors.white, fontSize: size * 0.4),
              );
            },
          ),
        ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: displayMembers.length == 2
            ? _buildTwoAvatarsMosaic(displayMembers, size)
            : displayMembers.length == 3
            ? _buildThreeAvatarsMosaic(displayMembers, size)
            : _buildFourAvatarsMosaic(displayMembers, size),
      ),
    );
  }

  Widget _buildTwoAvatarsMosaic(List<ConversationUser> members, double size) {
    return Row(
      children: [
        _buildAvatarTile(members[0], size / 2, size),
        _buildAvatarTile(members[1], size / 2, size),
      ],
    );
  }

  Widget _buildThreeAvatarsMosaic(List<ConversationUser> members, double size) {
    return Column(
      children: [
        _buildAvatarTile(members[0], size, size / 2),
        Row(
          children: [
            _buildAvatarTile(members[1], size / 2, size / 2),
            _buildAvatarTile(members[2], size / 2, size / 2),
          ],
        ),
      ],
    );
  }

  Widget _buildFourAvatarsMosaic(List<ConversationUser> members, double size) {
    return Column(
      children: [
        Row(
          children: [
            _buildAvatarTile(members[0], size / 2, size / 2),
            _buildAvatarTile(members[1], size / 2, size / 2),
          ],
        ),
        Row(
          children: [
            _buildAvatarTile(members[2], size / 2, size / 2),
            _buildAvatarTile(members[3], size / 2, size / 2),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatarTile(
    ConversationUser member,
    double width,
    double height,
  ) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 0.5),
      ),
      child: member.user?.avatar != null
          ? Image.network(
              member.user!.avatar!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[800],
                  child: Center(
                    child: Text(
                      member.user?.nickname?.substring(0, 1) ?? "?",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * 0.4,
                      ),
                    ),
                  ),
                );
              },
            )
          : Container(
              color: Colors.grey[800],
              child: Center(
                child: Text(
                  member.user?.nickname?.substring(0, 1) ?? "?",
                  style: TextStyle(color: Colors.white, fontSize: width * 0.4),
                ),
              ),
            ),
    );
  }
}
