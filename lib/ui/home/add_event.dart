import 'package:evently/ui/home/tabs/home_tab/models/event_data_model.dart';
import 'package:evently/ui/home/tabs/home_tab/widgets/event_tab_item_widget.dart';
import 'package:evently/ui/widgets/custom_elevated_button.dart';
import 'package:evently/ui/widgets/custom_text_field.dart';
import 'package:evently/ui/widgets/event_date_or_time.dart';
import 'package:evently/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:evently/utils/app_styles.dart';
import 'package:evently/utils/assets_manager.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';

class AddEvent extends StatefulWidget {
  static const routeName = '/add_event';

  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  int selectedIndex = 0;

  final List<String> imageSelectedEventList = [
    AssetsManager.sportImage,
    AssetsManager.birthdayImage,
    AssetsManager.meetingImage,
    AssetsManager.gamingImage,
    AssetsManager.workshopImage,
    AssetsManager.bookClubImage,
    AssetsManager.exhibitionImage,
    AssetsManager.holidayImage,
    AssetsManager.eatingImage,
  ];

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    final List<EventData> eventsDataList = [
      EventData(
        name: AppLocalizations.of(context)!.sport,
        icon: FontAwesome.futbol_solid,
      ),
      EventData(
        name: AppLocalizations.of(context)!.birthday,
        icon: Iconsax.cake_bold,
      ),
      EventData(
        name: AppLocalizations.of(context)!.meeting,
        icon: EvaIcons.people,
      ),
      EventData(
        name: AppLocalizations.of(context)!.gaming,
        icon: Bootstrap.controller,
      ),
      EventData(
        name: AppLocalizations.of(context)!.workshop,
        icon: LineAwesome.toolbox_solid,
      ),
      EventData(
        name: AppLocalizations.of(context)!.book_club,
        icon: MingCute.book_2_fill,
      ),
      EventData(
        name: AppLocalizations.of(context)!.exhibition,
        icon: Clarity.picture_line,
      ),
      EventData(
        name: AppLocalizations.of(context)!.holiday,
        icon: LineAwesome.hotel_solid,
      ),
      EventData(
        name: AppLocalizations.of(context)!.eating,
        icon: IonIcons.fast_food,
      ),
    ];

    final String selectedImage = imageSelectedEventList[selectedIndex];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.create_event,
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
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(selectedImage),
              ),
              SizedBox(height: height * 0.02),
              SizedBox(
                height: height * 0.06,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: eventsDataList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: EventTabItemWidget(
                        iconData: eventsDataList[index].icon,
                        eventName: eventsDataList[index].name,
                        isSelected: selectedIndex == index,
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
              Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.title,
                      style: AppStyles.medium16Black,
                    ),
                    SizedBox(height: height * 0.01),
                    CustomTextField(
                      controller: titleController,
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
                    Text(
                      AppLocalizations.of(context)!.description,
                      style: AppStyles.medium16Black,
                    ),
                    SizedBox(height: height * 0.01),
                    CustomTextField(
                      controller: descriptionController,
                      hintText: AppLocalizations.of(context)!.event_description,
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
                    EventDateOrTime(
                      iconDateOrTime: AssetsManager.iconDate,
                      chooseDateOrTime:
                          selectedDate == null
                              ? AppLocalizations.of(context)!.choose_date
                              : DateFormat("dd/MM/yyyy").format(selectedDate!),
                      eventDateOrTime: AppLocalizations.of(context)!.event_date,
                      onChooseDateOrTime: chooseDate,
                    ),
                    EventDateOrTime(
                      iconDateOrTime: AssetsManager.iconTime,
                      chooseDateOrTime:
                          selectedTime == null
                              ? AppLocalizations.of(context)!.choose_time
                              : selectedTime!.format(context),
                      eventDateOrTime: AppLocalizations.of(context)!.event_time,
                      onChooseDateOrTime: chooseTime,
                    ),
                    SizedBox(height: height * 0.01),
                    Text(
                      AppLocalizations.of(context)!.location,
                      style: AppStyles.medium16Black,
                    ),
                    SizedBox(height: height * 0.01),
                    Container(
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
                              border: Border.all(color: AppColors.primaryLight),
                            ),
                            child: Image.asset(AssetsManager.iconLocation),
                          ),
                          Text(
                            "Cairo , Egypt",
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
                    SizedBox(height: height * 0.02),
                    CustomElevatedButton(
                      text: AppLocalizations.of(context)!.update_event,
                      onButtonClick: updateEvent,
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
  }

  void chooseDate() async {
    var chooseDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      initialDate: DateTime.now(),
    );
    selectedDate = chooseDate;
    setState(() {});
  }

  void chooseTime() async {
    var chooseTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    selectedTime = chooseTime;
    setState(() {});
  }

  void updateEvent() {
    if(formKey.currentState?.validate()== true) {
 
    }
  }
}
