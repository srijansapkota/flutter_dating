int calculateAge(String birthdate, {DateTime? now}) {
  final birthDate = DateTime.parse(birthdate);
  final today = now ?? DateTime.now();

  int age = today.year - birthDate.year;

  if (today.month < birthDate.month ||
      (today.month == birthDate.month && today.day < birthDate.day)) {
    age--;
  }

  return age;
}