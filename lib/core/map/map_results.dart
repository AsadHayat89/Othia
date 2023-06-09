import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:othia/core/main_page.dart';
import 'package:othia/core/map/exclusive_widgets/app_bar_creator.dart';
import 'package:othia/core/map/exclusive_widgets/current_position.dart';
import 'package:othia/modules/models/eA_summary/eA_summary.dart';
import 'package:othia/modules/models/get_map_result_ids/get_map_result_ids.dart';
import 'package:othia/utils/services/rest-api/rest_api_service.dart';
import 'package:othia/utils/ui/future_service.dart';
import 'package:othia/utils/ui/ui_utils.dart';
import 'package:othia/widgets/action_buttons.dart';
import 'package:othia/widgets/nav_bar/nav_bar_notifier.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../widgets/filter_related/notifiers/map_notifier.dart';
import '../../widgets/keep_alive_future_builder.dart';
import '../../widgets/vertical_discovery/favourite_list_item.dart';

class MapResultsInit extends StatelessWidget {
  const MapResultsInit({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildMapAppBar(context: context, body: MapResults());
  }
}

class MapResults extends StatefulWidget {
  const MapResults({Key? key}) : super(key: key);

  @override
  State<MapResults> createState() => _MapResultsState();
}

class _MapResultsState extends State<MapResults> {
  late latLng.LatLng? userPosition;
  late MapResultIds mapResultIds;
  List<String>? eAIds;
  int activeIndex = 0;
  final CarouselController carouselController = CarouselController();

  @override
  void initState() {
    FirebaseAnalytics.instance.setCurrentScreen(
      screenName: 'mapScreen',
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserPositionNotifier>(builder: (context, model, child) {
      userPosition = model.getUserPosition;
      if (userPosition != null) {
        return Consumer<MapNotifier>(builder: (context, model, child) {
          return FutureBuilder(
              future: Provider.of<MapNotifier>(context, listen: false)
                  .getSearchQueryResult(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: defaultStillLoadingWidget,
                  );
                }
                if (snapshot.hasData) {
                  return snapshotHandler(context, snapshot, futureMap, []);
                } else {
                  return Center(
                    child: Text("No Data Exit"),
                  );
                }
              });
        });
      } else {
        // TODO clear (extern) implement exception handling and messages for user permission, e.g. implement loading when map is not shown
        // TODO clear (extern) align style
        return Align(
          alignment: Alignment.center,
          child: Column(
            children: [
              // Text(
              //   AppLocalizations.of(context)!.waitingLocationPermission,
              //   textAlign: TextAlign.center,
              // ),
              ElevatedButton(
                  onPressed: () async {
                    PermissionStatus permission =
                        await Permission.location.request();
                    if (permission == PermissionStatus.granted) {
                      setState(() {
                        Get.snackbar(
                            titleText:
                                Center(child: Text("Permission Granted")),
                            "",
                            "",
                            snackPosition: SnackPosition.BOTTOM,
                            colorText: Colors.white);
                        Get.to(MainPage(), transition: Transition.fadeIn);
                      });
                    }
                    if (permission == PermissionStatus.denied) {
                      // Get.snackbar('Permission is recommended', "");
                      Get.to(MainPage(), transition: Transition.fadeIn);
                      openAppSettings();
                    }
                  },
                  child: Text("get Location"))
            ],
          ),
        );
      }
    });
  }

  Widget futureMap(Map<String, dynamic> json) {
    mapResultIds = MapResultIds.fromJson(json);

    return FlutterMap(
      options: MapOptions(

        // to prevent map to rotate
        interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
        center: userPosition,
        zoom: 15.0,
        maxZoom: 18.49,
        minZoom: 3,
      ),
      nonRotatedChildren: [
        if (eAIds != null)
          Container(
            child: buildSummaryCarousel(),
            alignment: Alignment.bottomCenter,
          ),
        Container(
          alignment: Alignment.bottomRight,
          padding: const EdgeInsetsDirectional.only(end: 8, bottom: 2),
          child: Text(
            '© OpenStreetMap',
            style: TextStyle(color: Theme.of(context).focusColor),
          ),
        ),
        // TODO clear (extern) align colors, font size of Event and Activity colored box & introduce background color for the legend in order to make it better visible. We highly appreciate your input if you have better ideas.

        Container(
          alignment: Alignment.bottomRight,
          padding:  EdgeInsetsDirectional.only(start: 8, bottom: 2),
          child: Row(
            children: [
              SizedBox(
                width: 10,
                height: 8,
                child: DecoratedBox(
                  decoration:
                      BoxDecoration(color: Theme.of(context).primaryColor),
                ),
              ),
              getHorSpace(5.h),
              Container(
                  // height: 30.h,
                  // width: 30.w,
                  decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding:  EdgeInsets.all(8.0),
                    child: Text(
                      AppLocalizations.of(context)!.event,
                      style: TextStyle(color: Colors.white),
                    ),
                  )),
              getHorSpace(10.h),
              SizedBox(
                width: 10,
                height: 8,
                child: DecoratedBox(
                  decoration:
                      BoxDecoration(color: Theme.of(context).bottomAppBarColor),
                ),
              ),
              getHorSpace(5.h),
              Container(
                decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding:  EdgeInsets.all(8.0),
                  child: Text(AppLocalizations.of(context)!.activity,
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        )
      ],
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'othia.de',
        ),
        MarkerClusterLayerWidget(
          options: MarkerClusterLayerOptions(
            anchor: AnchorPos.align(AnchorAlign.center),
            rotate: false,
            maxClusterRadius: 120,
            size:  Size(40, 40),
            fitBoundsOptions:  FitBoundsOptions(
              padding: EdgeInsets.all(50),
            ),
            markers: getResultMarkers(),
            polygonOptions:  PolygonOptions(
                color: Colors.black12, borderStrokeWidth: 3),
            builder: (context, markers) {
              return FloatingActionButton(
                foregroundColor: Colors.white,
                child: Text(markers.length.toString()),
                onPressed: null,
              );
            },
          ),
        ),
        // MarkerLayer(markers: getResultMarkers()),
      ],
    );
  }

  Marker getMarker(
      {required Map<String, dynamic> locationData,
      required Color markerColor,
      required bool select}) {

    bool selecton=false;
    return Marker(
        width: 50.0,
        height: 50.0,
        rotate: true,
        point: latLng.LatLng(locationData["coordinates"]["latitude"],
            locationData["coordinates"]["longitude"]),
        builder: (ctx) => GestureDetector(
              onTap: () => {
                // TODO (extern) highlight selected marker
                setState(() {
                 selecton = true;
                  markerColor = Colors.deepPurple;
                  print("select value: " + selecton.toString());
                  eAIds = getAllIdsUnderMarker(
                    locationData["coordinates"]["latitude"],
                    locationData["coordinates"]["longitude"],
                  );
                  print(latLng.LatLng(locationData["coordinates"]["latitude"],
                      locationData["coordinates"]["longitude"]));
                })
                // NavigatorConstants.sendT
                //
                //
                //
                // oNext(Routes.detailedEventRoute,
                //     arguments: {
                //       NavigatorConstants.EventActivityId: locationData["id"]
                //     })
              },
              child: selecton?Icon(
                Icons.add,
                size: 44,
                color: select == true ? Colors.deepPurpleAccent : markerColor,
              ):
              Icon(
                Icons.location_on,
                size: 44,
                color: select == true ? Colors.deepPurpleAccent : markerColor,
              ),
            ));
  }

  List<String> getAllIdsUnderMarker(double latitude, double longitude) {
    List<String> Ids = [];
    mapResultIds.eventResults.forEach(
      (element) {
        if ((element!["coordinates"]["latitude"] == latitude) &
            (element["coordinates"]["longitude"] == longitude)) {
          Ids.add(element["id"]);
        }
      },
    );
    mapResultIds.activityResults.forEach(
      (element) {
        if ((element!["coordinates"]["latitude"] == latitude) &
            (element["coordinates"]["longitude"] == longitude)) {
          print(latitude.toString()+","+longitude.toString());
          Ids.add(element["id"]);
        }
      },
    );
    return Ids;
  }

  List<Marker> getResultMarkers() {
    List<Marker> markerList = [];

    // TODO (extern) modify code such that the user location icon is never part of a cluster, also make sure the number of the cluster does not rotate

    // for activities
    //TODO  (extern) align color scheme for event and activity icons.
    mapResultIds.activityResults.forEach((element) {
      markerList.add(getMarker(
          select: false,
          locationData: element!,
          markerColor: Theme.of(context).colorScheme.primary));
    });
    mapResultIds.eventResults.forEach((element) {
      markerList.add(getMarker(
          select: false,
          locationData: element!,
          markerColor: Theme.of(context).colorScheme.tertiaryContainer));
    });
    markerList.add(Marker(
      width: 50.0,
      height: 500.0,
      rotate: false,
      builder: (ctx) => GestureDetector(
        child: Icon(
          Icons.my_location,
          size: 22,
          color: Colors.blue,
        ),
      ),
      point: userPosition!,
    ));
    return markerList;
  }

  Container buildSummaryCarousel() {
    // TODO clear (extern) find a solution indicating to the user that they can swipe to see all the events happening at this location; changing the viewportfraction to 0.8, e.g., would solve the problem but in this case overflows appear. It might be also beneficial to change the scrolling direction to vertical
    return Container(
      margin: EdgeInsets.only(bottom: 45.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CarouselSlider.builder(
            carouselController: carouselController,
            options: CarouselOptions(
              height: 150.h,
              viewportFraction: 1,
              initialPage: 0,
              enableInfiniteScroll: true,
              reverse: false,
              onPageChanged: (index, reason) {
                setState(() {
                  activeIndex = index;
                });
              },
              //autoPlay: true,
              //autoPlayInterval: Duration(seconds: 6),
              //autoPlayAnimationDuration: Duration(milliseconds: 800),
              //autoPlayCurve: Curves.fastOutSlowIn,
              //enlargeCenterPage: true,
              //enlargeFactor: 1,
              scrollDirection: Axis.horizontal,
            ),
            itemCount: eAIds!.length,
            itemBuilder:
                (BuildContext context, int itemIndex, int pageViewIndex) =>
                    Container(
              child: buildSummaryCard(eAIds![itemIndex]),
            ),
          ),
          buildIndicator(
              eAIds: eAIds,
              carouselController: carouselController,
              activeIndex: activeIndex,
              context: context)
        ],
      ),
    );
  }

  KeepAliveFutureBuilder buildSummaryCard(String id) {
    Future<Object> eASummary = RestService().getEASummary(id: id);
    return KeepAliveFutureBuilder(
        future: eASummary,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: defaultStillLoadingWidget);
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            return snapshotHandler(
                context, snapshot, buildMapSummary, [context]);
          } else {
            return Center(
              child: Text("No Data Exit"),
            );
          }
        });
  }
}

class buildIndicator extends StatelessWidget {
  const buildIndicator({
    Key? key,
    required this.eAIds,
    required this.carouselController,
    required this.activeIndex,
    required this.context,
  }) : super(key: key);

  final List<String>? eAIds;
  final CarouselController carouselController;
  final int activeIndex;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.size.width,
      child: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: eAIds!.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => carouselController.animateToPage(entry.key),
              child: Container(
                width: activeIndex == entry.key ? 17 : 10,
                height: 9.0,
                margin: const EdgeInsets.symmetric(
                  horizontal: 3.0,
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: activeIndex == entry.key
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.tertiaryContainer),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

Widget buildMapSummary(
  BuildContext context,
  Map<String, dynamic> decodedJson,
) {
  SummaryEventOrActivity eASummary =
      SummaryEventOrActivity.fromJson(decodedJson);
  return Align(
    alignment: Alignment.bottomCenter,
    child: Padding(
      padding: EdgeInsets.only(left: 5.h, right: 5.h, bottom: 20.h),
      child: Container(
        height: 90.h,
        child: getVerticalSummary(
            eASummary: eASummary,
            context: context,
            actionButton: getActionButton(
                actionButtonType: ActionButtonType.addLikeButton,
                eASummary: eASummary,
                context: context)),
      ),
    ),
  );
}
