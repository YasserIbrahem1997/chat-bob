part of 'profile_cubit.dart';

@immutable
abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileImagePickedSuccess extends ProfileState {}

class ProfileImagePickedError extends ProfileState {}

//-----------------
class UploadImageToFireBaseLoding extends ProfileState {}

class UploadImageToFireBaseSacsec extends ProfileState {}

class UploadImageToFireBaseErorre extends ProfileState {}
