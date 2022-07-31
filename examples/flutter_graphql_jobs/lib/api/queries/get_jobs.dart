const getJobs = '''
  query GetJobs() {
    jobs {
      id,
      title,
      locationNames,
      isFeatured
    }
  }
''';
