abstract class IOccurrenceRepository {
  Future<void> createOccurrence(Map<String, dynamic> occurrenceData);
  // You might add other methods here like getOccurrenceById, updateOccurrence, deleteOccurrence
}