String capitalize(String toCapitalize) {
  if (toCapitalize.isEmpty) {
    return toCapitalize;
  }
  return "${toCapitalize[0].toUpperCase()}${toCapitalize.substring(1).toLowerCase()}";
}

String capitalizeNames(String names) {
  if (names.isEmpty) {
    return names;
  }
  List<String> elements = names.split(' ');
  List<String> capitalizedElements = [];
  for (int i = 0; i < elements.length; i++) {
    if (elements[i].isNotEmpty) {
      capitalizedElements.add(capitalize(elements[i]));
    }
  }
  return capitalizedElements.join(' ');
}
