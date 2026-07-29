import 'package:evently/data/repositories/location/location_repository.dart';
import 'package:evently/ui/home/tabs/home_tab/cubit/location/location_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';

class LocationCubit extends Cubit<LocationState> {
  LocationRepository locationRepository;
  LocationCubit(this.locationRepository) : super(LocationInitial());

  Future<void> getCurrentLocation() async {
    emit(LocationLoading());
    try {
      final locationData = await locationRepository.getCurrentLocation();
      print(" 👌STEP A: before convert");

      final placeInfo = await locationRepository.convertLatLng(
        LatLng(locationData.latitude!, locationData.longitude!),
      );
      print("👌STEP B: after convert");
      emit(
        LocationSuccess(
          cityName: placeInfo['city'],
          countryName: placeInfo['country'],
           latLng:   LatLng(locationData.latitude!, locationData.longitude!), 
        ),
      );
    } catch (e) {
       if (!isClosed) { 
    emit(LocationError(e.toString()));
  }
    }
  }
}
