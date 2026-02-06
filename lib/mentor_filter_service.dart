import 'package:flutter/material.dart';

class MentorData {
  final String name;
  final String specialization;
  final int price;
  final double rating;

  MentorData({
    required this.name,
    required this.specialization,
    required this.price,
    required this.rating,
  });
}

class MentorFilterService {
  static List<MentorData> filterMentors({
    required List<MentorData> mentors,
    String? specialization,
    int? maxPrice,
    double? minRating,
  }) {
    return mentors.where((mentor) {
      if (specialization != null && mentor.specialization != specialization) {
        return false;
      }

      if (maxPrice != null && mentor.price > maxPrice) {
        return false;
      }

      if (minRating != null && mentor.rating < minRating) {
        return false;
      }

      return true;
    }).toList();
  }
}
