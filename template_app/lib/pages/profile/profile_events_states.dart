// EVENTS

import 'package:flutter/cupertino.dart';
import 'package:template_app/objects/TEMPLATE.dart';

abstract class ProfileEvents {
  const ProfileEvents();
}

class LoadProfileEvent extends ProfileEvents {
  const LoadProfileEvent();
}

class LogoutEvent extends ProfileEvents {
  final BuildContext context;
  const LogoutEvent({required this.context});
}

// STATES
abstract class ProfileState {
  const ProfileState();
}

class LoadingProfileState extends ProfileState {
  const LoadingProfileState();
}

class ShowProfileState extends ProfileState {
  // TODO: REPLACE WITH REAL MODEL
  final TEMPLATE profile;
  const ShowProfileState({required this.profile});
}
