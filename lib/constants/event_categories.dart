import 'package:evently/ui/home/tabs/home_tab/models/event_category_model.dart';
import 'package:icons_plus/icons_plus.dart';

class EventCategories {
  static const List<EventCategory> categories = [
    EventCategory(icon: Bootstrap.house, categoryKey: 'all'),
    EventCategory(icon: FontAwesome.futbol_solid, categoryKey: 'sport'),
    EventCategory(icon: Iconsax.cake_bold, categoryKey: 'birthday'),
    EventCategory(icon: EvaIcons.people, categoryKey: 'meeting'),
    EventCategory(icon: Bootstrap.controller, categoryKey: 'gaming'),
    EventCategory(icon: LineAwesome.toolbox_solid, categoryKey: 'workshop'),
    EventCategory(icon: MingCute.book_2_fill, categoryKey: 'book_club'),
    EventCategory(icon: Clarity.picture_line,  categoryKey: 'exhibition',),
    EventCategory( icon:LineAwesome.hotel_solid,categoryKey: 'holiday'),
    EventCategory(icon: IonIcons.fast_food,categoryKey: 'eating',),
  ];
}