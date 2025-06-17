class Pet {
  String id;
  String name;
  String species;
  String breed;
  DateTime birthDate;
  double weight;
  String gender;
  String ownerId;
  String imageUrl;

  Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.birthDate,
    required this.weight,
    required this.gender,
    required this.ownerId,
    this.imageUrl = '',
  });

  // For demo purposes - factory method to create sample pets
  factory Pet.sample(String id, String ownerId) {
    return Pet(
      id: id,
      name: id == '1'
          ? 'Max'
          : id == '2'
          ? 'Bella'
          : 'Charlie',
      species: id == '1'
          ? 'Dog'
          : id == '2'
          ? 'Cat'
          : 'Bird',
      breed: id == '1'
          ? 'Golden Retriever'
          : id == '2'
          ? 'Siamese'
          : 'Parakeet',
      birthDate: DateTime.now().subtract(Duration(days: int.parse(id) * 365)),
      weight: id == '1'
          ? 30.5
          : id == '2'
          ? 4.2
          : 0.3,
      gender: id == '1'
          ? 'Male'
          : id == '2'
          ? 'Female'
          : 'Male',
      ownerId: ownerId,
      imageUrl: id == '1'
          ? 'https://images.unsplash.com/photo-1552053831-71594a27632d?ixlib=rb-4.0.3'
          : id == '2'
          ? 'https://images.unsplash.com/photo-1548247416-ec66f4900b2e?ixlib=rb-4.0.3'
          : 'https://images.unsplash.com/photo-1522926193341-e9ffd686c60f?ixlib=rb-4.0.3',
    );
  }

  // Calculate age in years and months
  String getAge() {
    final now = DateTime.now();
    final years = now.year - birthDate.year;
    final months = now.month - birthDate.month;

    if (years > 0) {
      return '$years year${years > 1 ? 's' : ''} ${months > 0 ? '$months month${months > 1 ? 's' : ''}' : ''}';
    } else {
      return '$months month${months > 1 ? 's' : ''}';
    }
  }
}
