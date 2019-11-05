class NewCarRepository {
  Future<List<String>> fetchBrands() async {
    await Future.delayed(Duration(milliseconds: 200));
    return [
      'Chevy',
      'Toyota',
      'Honda',
    ];
  }

  Future<List<String>> fetchModels({String brand}) async {
    await Future.delayed(Duration(milliseconds: 200));
    switch (brand) {
      case 'Chevy':
        return ['Malibu', 'Impala'];
      case 'Toyota':
        return ['Corolla', 'Supra'];
      case 'Honda':
        return ['Civic', 'Accord'];
      default:
        return [];
    }
  }

  Future<List<String>> fetchYears({String brand, String model}) async {
    await Future.delayed(Duration(milliseconds: 200));
    switch (brand) {
      case 'Chevy':
        switch (model) {
          case 'Malibu':
            return ['2019', '2018'];
          case 'Impala':
            return ['2017', '2016'];
          default:
            return [];
        }
        break;
      case 'Toyota':
        switch (model) {
          case 'Corolla':
            return ['2015', '2014'];
          case 'Supra':
            return ['2013', '2012'];
          default:
            return [];
        }
        break;
      case 'Honda':
        switch (model) {
          case 'Civic':
            return ['2011', '2010'];
          case 'Accord':
            return ['2009', '2008'];
          default:
            return [];
        }
        break;
      default:
        return [];
    }
  }
}
