
import 'package:evently/data/repositories/event_repository.dart';
import 'package:evently/domain/model/event.dart';
import 'package:evently/providers/add_event_provider.dart';
import 'package:evently/providers/event_list_provider.dart';
import 'package:evently/providers/user_provider.dart';
import 'package:evently/ui/home/create_event/pick_location_screen.dart';
import 'package:evently/ui/home/tabs/home_tab/widgets/event_tab_item_widget.dart';
import 'package:evently/ui/widgets/custom_elevated_button.dart';
import 'package:evently/ui/widgets/custom_text_field.dart';
import 'package:evently/ui/widgets/event_date_or_time.dart';
import 'package:evently/utils/app_colors.dart';
import 'package:evently/utils/app_styles.dart';
import 'package:evently/utils/assets_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddEvent extends StatefulWidget {
  static const routeName = "add_event";
  final Event? event;
  const AddEvent({super.key, this.event});
  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  AddEventProvider get addEventProvider =>
      Provider.of<AddEventProvider>(context, listen: false);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final eventListProvider = Provider.of<EventListProvider>(
        context,
        listen: false,
      );
      eventListProvider.getEventsDataList(context);
      // final addEventProvider = Provider.of<AddEventProvider>(
      //   context,
      //   listen: false,
      // );

      if (widget.event != null) {
        initializeEventData();
      } else {
        addEventProvider.clearData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Consumer3<AddEventProvider, EventListProvider, UserProvider>(
      builder: (
        context,
        addEventProvider,
        eventListProvider,
        userProvider,
        child,
      ) {
        final eventsDataList = eventListProvider.eventsDataList;

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              widget.event == null
                  ? AppLocalizations.of(context)!.create_event
                  : AppLocalizations.of(context)!.edit_event,
              style: AppStyles.medium20Primary,
            ),
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.04,
              vertical: height * 0.01,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(addEventProvider.selectedImage),
                  ),
                  SizedBox(height: height * 0.02),

                  // Event Categories List
                  if (eventsDataList.isNotEmpty)
                    SizedBox(
                      height: height * 0.06,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: eventsDataList.length - 1,
                        itemBuilder: (BuildContext context, int index) {
                          int actualIndex = index + 1;
                          return GestureDetector(
                            onTap: () {
                              addEventProvider.changeSelectedIndex(index);
                            },
                            child: EventTabItemWidget(
                              iconData: eventsDataList[actualIndex].icon,
                              eventName: eventsDataList[actualIndex].name,
                              isSelected:
                                  addEventProvider.selectedIndex == index,
                              selectedBackgroundColor: AppColors.primaryLight,
                              unselectedBackgroundColor: Colors.transparent,
                              borderColor: AppColors.primaryLight,
                              selectedIconColor: AppColors.whiteColor,
                              unselectedIconColor: AppColors.primaryLight,
                              selectedTextStyle: AppStyles.bold16White,
                              unselectedTextStyle: AppStyles.bold16Primary,
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return SizedBox(width: width * 0.02);
                        },
                      ),
                    ),
                  SizedBox(height: height * 0.02),

                  // Form
                  Form(
                    key: addEventProvider.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Field
                        Text(
                          AppLocalizations.of(context)!.title,
                          style: AppStyles.medium16Black,
                        ),
                        SizedBox(height: height * 0.01),
                        CustomTextField(
                          controller: addEventProvider.titleController,
                          prefixIcon: Image.asset(AssetsManager.iconEdit),
                          hintText: AppLocalizations.of(context)!.event_title,
                          validator: (text) {
                            if (text!.isEmpty) {
                              return AppLocalizations.of(
                                context,
                              )!.please_enter_event_title;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: height * 0.02),

                        // Description Field
                        Text(
                          AppLocalizations.of(context)!.description,
                          style: AppStyles.medium16Black,
                        ),
                        SizedBox(height: height * 0.01),
                        CustomTextField(
                          controller: addEventProvider.descriptionController,
                          hintText:
                              AppLocalizations.of(context)!.event_description,
                          maxLines: 4,
                          validator: (text) {
                            if (text!.isEmpty) {
                              return AppLocalizations.of(
                                context,
                              )!.please_enter_event_title;
                            }
                            return null;
                          },
                        ),

                        // Date Picker
                        EventDateOrTime(
                          iconDateOrTime: AssetsManager.iconDate,
                          chooseDateOrTime: addEventProvider.getFormattedDate(
                            context,
                          ),
                          eventDateOrTime:
                              AppLocalizations.of(context)!.event_date,
                          onChooseDateOrTime:
                              () => addEventProvider.chooseDate(context),
                        ),

                        // Time Picker
                        EventDateOrTime(
                          iconDateOrTime: AssetsManager.iconTime,
                          chooseDateOrTime: addEventProvider.getFormattedTime(
                            context,
                          ),
                          eventDateOrTime:
                              AppLocalizations.of(context)!.event_time,
                          onChooseDateOrTime:
                              () => addEventProvider.chooseTime(context),
                        ),

                        SizedBox(height: height * 0.01),

                        // Location
                        Text(
                          AppLocalizations.of(context)!.location,
                          style: AppStyles.medium16Black,
                        ),
                        SizedBox(height: height * 0.01),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              PickLocationScreen.routeName,
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.primaryLight),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  margin: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.primaryLight,
                                    ),
                                  ),
                                  child: SizedBox(
                                    height: 25,
                                    width: 25,
                                    child: Image.asset(
                                      AssetsManager.iconLocation,
                                    ),
                                  ),
                                ),

                                Text(
                                  addEventProvider.eventLocation == null
                                      ? AppLocalizations.of(
                                        context,
                                      )!.choose_event_location
                                      : '${addEventProvider.eventCity}, ${addEventProvider.eventCountry}',

                                  style: AppStyles.medium16Primary,
                                ),
                                Spacer(),
                                Icon(
                                  Icons.arrow_forward_ios_outlined,
                                  color: AppColors.primaryLight,
                                  size: 20,
                                ),
                                SizedBox(width: width * 0.02),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.02),

                        // Submit Button
                        CustomElevatedButton(
                          text:
                              widget.event == null
                                  ? AppLocalizations.of(context)!.add_event
                                  : AppLocalizations.of(context)!.update_event,
                          onButtonClick: () async {
                            if (widget.event == null) {
                              await addEventProvider.updateEvent(
                                context,
                                eventListProvider,
                                userProvider,
                              );
                            } else {
                              bool
                              isUpdated = await EventRepository().editEvent(
                                Event(
                                  id: widget.event!.id,
                                  userId: widget.event!.userId,
                                  title: addEventProvider.titleController.text,
                                  description:
                                      addEventProvider
                                          .descriptionController
                                          .text,
                                  date: DateTime(
                                    addEventProvider.selectedDate!.year,
                                    addEventProvider.selectedDate!.month,
                                    addEventProvider.selectedDate!.day,
                                    addEventProvider.selectedTime!.hour,
                                    addEventProvider.selectedTime!.minute,
                                  ),
                                  time: addEventProvider.formatTime!,
                                  image: addEventProvider.selectedImage,
                                  latitude:
                                      addEventProvider.eventLocation!.latitude,
                                  longitude:
                                      addEventProvider.eventLocation!.longitude,
                                  city: addEventProvider.eventCity!,
                                  country: addEventProvider.eventCountry!,
                                  category:
                                      eventListProvider
                                          .eventsDataList[addEventProvider
                                                  .selectedIndex +
                                              1]
                                          .categoryKey,
                                ),
                                widget.event!.userId,
                              );
                              if (isUpdated) {
                                Navigator.of(context).pop();
                              }
                            }
                          },
                        ),
                        SizedBox(height: height * 0.02),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void initializeEventData() {
    // حول الـ String لـ DateTime أولاً
    DateTime parsedTime = DateFormat('h:mm a').parse(widget.event!.time);

    addEventProvider.selectedIndex = addEventProvider.imageSelectedEventList
        .indexOf(widget.event!.image);
    addEventProvider.titleController.text = widget.event!.title;
    addEventProvider.descriptionController.text = widget.event!.description;
    addEventProvider.selectedDate = widget.event!.date;
    // بعد كده حوله لـ TimeOfDay
    addEventProvider.selectedTime = TimeOfDay.fromDateTime(parsedTime);
    addEventProvider.formatTime = widget.event!.time;
    addEventProvider.eventLocation = LatLng(
      widget.event!.latitude!,
      widget.event!.longitude!,
    );
    addEventProvider.eventCity = widget.event!.city;
    addEventProvider.eventCountry = widget.event!.country;
    // addEventProvider.userId = widget.event!.userId;
  }
}



// addEventProvider.selectedTime = TimeOfDay(
//       hour: widget.event!.date.hour,
//       minute: widget.event!.date.minute,
//     );
//     addEventProvider.formatTime = widget.event!.time;



// addEventProvider.selectedDate = widget.event!.date;
//     addEventProvider.selectedTime = TimeOfDay.fromDateTime(widget.event!.date);
//     addEventProvider.formatTime = widget.event!.time;

