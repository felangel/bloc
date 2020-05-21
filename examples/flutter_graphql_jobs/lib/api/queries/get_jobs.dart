const getJobs = r'''
  query GetJobs() {
    jobs {
      id,
      title,
      locationNames,
      isFeatured
    }
  }
''';
