import 'package:flutter/material.dart';
import 'package:route_r_dam/components/return.dart';
import 'package:route_r_dam/components/toggle_buttom.dart';
import 'package:route_r_dam/models/place_with_distances.dart';

class BuildRoutePageFilter extends StatefulWidget {
  final Set<String> categories;
  final void Function(bool Function(PlaceWithDistances)) func;

  const BuildRoutePageFilter(
      {Key? key, required this.categories, required this.func})
      : super(key: key);

  @override
  State<BuildRoutePageFilter> createState() => _BuildRoutePageFilterState();
}

class _BuildRoutePageFilterState extends State<BuildRoutePageFilter> {
  Set<String> categoriesFilters = {};

  _addFilterValuesFromToggles(String filterValue) {
    categoriesFilters.add(filterValue);
  }

  _removeFilterValuesFromToggles(String filterValue) {
    categoriesFilters.remove(filterValue);
  }

  @override
  Widget build(BuildContext context) {
    bool Function(PlaceWithDistances) filterFunctionCategories = (a) {
      bool test = false;
      for (String b in categoriesFilters) {
        if (a.categories.contains(b)) {
          test = true;
        }
      }
      return test;
    };

    final _categories =
        widget.categories.where((e) => e.isNotEmpty || e != "").toSet();
    return Scaffold(
      body: Padding(
        padding:
            EdgeInsets.fromLTRB(0, MediaQuery.of(context).padding.top, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Row(
                children: const [
                  Return(),
                ],
              ),
            ),
            Expanded(
              flex: 13,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      border: Border.all(color: Colors.grey, width: 2)),
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 5,
                              runSpacing: 5,
                              children: [
                                Text(
                                  'Filtrar localidades que contenham as categorias...',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 32 *
                                          MediaQuery.of(context)
                                              .textScaleFactor /
                                          2),
                                ),
                                ..._categories
                                    .map((e) => ToggleButtonHM(
                                        e,
                                        _addFilterValuesFromToggles,
                                        _removeFilterValuesFromToggles))
                                    .toList()
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(
                            width: 2,
                            color: Theme.of(context).scaffoldBackgroundColor))),
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    textStyle: TextStyle(
                        fontSize:
                            32 * MediaQuery.of(context).textScaleFactor / 2),
                    primary: Theme.of(context).scaffoldBackgroundColor,
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(0))),
                  ),
                  onPressed: () {
                    if (categoriesFilters
                        .where((e) => e.isNotEmpty || e != "")
                        .toList()
                        .isNotEmpty) {
                      widget.func(filterFunctionCategories);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Filtrar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
