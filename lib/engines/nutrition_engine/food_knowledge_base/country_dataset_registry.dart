import 'country_food_dataset.dart';
import 'countries/cameroon/cameroon_dataset.dart';

/// Every country dataset FoodKnowledgeBase knows about, keyed by
/// CountryFoodDataset.countryCode.
///
/// Adding a new country: implement CountryFoodDataset (see
/// countries/cameroon/ for the reference layout), then add one entry
/// here. FoodKnowledgeBase itself never changes.
const Map<String, CountryFoodDataset> countryFoodDatasets = {
  'Cameroon': CameroonDataset(),
};
