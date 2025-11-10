import 'package:evently/model/event.dart';
import 'package:evently/providers/event_list_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:evently/providers/user_provider.dart';
import 'package:evently/ui/home/tabs/home_tab/widgets/event_tab_item_widget.dart';
import 'package:evently/ui/widgets/custom_elevated_button.dart';
import 'package:evently/ui/widgets/custom_text_field.dart';
import 'package:evently/ui/widgets/event_date_or_time.dart';
import 'package:evently/utils/app_colors.dart';
import 'package:evently/utils/firebase_utils.dart';
import 'package:evently/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:evently/utils/app_styles.dart';
import 'package:evently/utils/assets_manager.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddEvent extends StatefulWidget {
  static const routeName =  "add_event";

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
  String? formatTime;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late EventListProvider eventListProvider;

  @override
  void initState() {
    super.initState();
    // تهيئة قائمة الأحداث عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      eventListProvider = Provider.of<EventListProvider>(
        context,
        listen: false,
      );
      eventListProvider.getEventsDataList(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    eventListProvider = Provider.of<EventListProvider>(context);

    final eventsDataList = eventListProvider.eventsDataList;

    // تأكد من أن القائمة ليست فارغة قبل استخدام selectedIndex
    final String selectedImage =
        selectedIndex < imageSelectedEventList.length
            ? imageSelectedEventList[selectedIndex]
            : imageSelectedEventList[0];

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
              // تحقق من أن القائمة ليست فارغة قبل عرض ListView
              if (eventsDataList.isNotEmpty)
                SizedBox(
                  height: height * 0.06,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount:
                        eventsDataList.length - 1, // نستثني "All" من القائمة
                    itemBuilder: (BuildContext context, int index) {
                      // نبدأ من index 1 لتجنب "All"
                      int actualIndex = index + 1;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                        child: EventTabItemWidget(
                          iconData: eventsDataList[actualIndex].icon,
                          eventName: eventsDataList[actualIndex].name,
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

  Future<void> chooseTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked == null) return;
    setState(() {
      selectedTime = picked;
      formatTime = picked.format(context);
    });
  }

  void updateEvent() {
    var userProvider = Provider.of<UserProvider>(context, listen: false);
    if (formKey.currentState?.validate() == true) {
      // التحقق من أن selectedDate و selectedTime ليسا null
      if (selectedDate == null) {
        ToastUtils.showToast(
          message: AppLocalizations.of(context)!.choose_date,
          backgroundColor: Colors.red,
        );
        return;
      }
      if (selectedTime == null || formatTime == null) {
        ToastUtils.showToast(
          message: AppLocalizations.of(context)!.choose_time,
          backgroundColor: Colors.red,
        );
        return;
      }

      // التحقق من أن القائمة ليست فارغة
      if (eventListProvider.eventsDataList.isEmpty) {
        ToastUtils.showToast(
          message: "Error: Event categories not loaded",
          backgroundColor: Colors.red,
        );
        return;
      }

      // نستخدم selectedIndex + 1 لأننا استثنينا "All" من القائمة
      int actualIndex = selectedIndex + 1;

      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        ToastUtils.showToast(
          message: "Please login first",
          backgroundColor: Colors.red,
        );
        return;
      }

      Event event = Event(
        category: eventListProvider.eventsDataList[actualIndex].categoryKey,
        eventName: eventListProvider.eventsDataList[actualIndex].name,
        image: imageSelectedEventList[selectedIndex],
        description: descriptionController.text,
        title: titleController.text,
        date: selectedDate!,
        time: formatTime!,
        userId: userId,
      );
      FirebaseUtils.addEvent(event, userProvider.user!.id).then((Value) {
        if (context.mounted) {
          ToastUtils.showToast(
            message: AppLocalizations.of(context)!.event_added_successfully,
            backgroundColor: Colors.green,
          );
          eventListProvider.getAllEvents(userProvider.user!.id);
          eventListProvider.changeSelectedIndex(0);
          Navigator.pop(context);
        
        }
      });
    }
  }
}
