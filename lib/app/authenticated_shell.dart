import 'package:evently/data/repositories/auth_repository.dart';
import 'package:evently/data/repositories/event_repository.dart';
import 'package:evently/domain/model/event.dart';
import 'package:evently/ui/home/create_event/add_event.dart';
import 'package:evently/ui/home/create_event/pick_location_screen.dart';
import 'package:evently/ui/home/event_details/event_details_screen.dart';
import 'package:evently/ui/home/home_screen.dart';
import 'package:evently/ui/home/tabs/favorite_tab/cubit/favorite_cubit.dart';
import 'package:evently/ui/home/tabs/home_tab/cubit/events/event_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:evently/ui/home/tabs/home_tab/cubit/location/location_cubit.dart';
import 'package:evently/data/repositories/location/location_repository_impl.dart';

class AuthenticatedShell extends StatefulWidget {
  const AuthenticatedShell({super.key});

  @override
  State<AuthenticatedShell> createState() => _AuthenticatedShellState();
}

class _AuthenticatedShellState extends State<AuthenticatedShell> {
  //   @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //             context.read<LocationCubit>().getCurrentLocation();

  //     });
  // }
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (_) =>
                  EventCubit(EventRepository(), AuthRepository())
                    ..listenToEvents(),
        ),
        BlocProvider(
          create:
              (_) =>
                  LocationCubit(LocationRepositoryImpl())..getCurrentLocation(),
        ),
        BlocProvider(
          create:
              (_) =>
                  FavoriteCubit(EventRepository(), AuthRepository())
                    ..listenToFavorites(),
        ),
      ],
      child: Navigator(
        initialRoute: "/",
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case "/":
              return MaterialPageRoute(builder: (_) => const HomeScreen());
            case EventDetailsScreen.routeName:
              final eventId = settings.arguments as String;
              return MaterialPageRoute(
                builder: (_) => EventDetailsScreen(eventId: eventId),
              );
            case AddEvent.routeName:
              final event = settings.arguments as Event?;
              return MaterialPageRoute(builder: (_) => AddEvent(event: event));
            case PickLocationScreen.routeName:
              return MaterialPageRoute(
                builder: (_) => const PickLocationScreen(),
              );
            default:
              return MaterialPageRoute(builder: (_) => const HomeScreen());
          }
        },
      ),
    );
  }
}
