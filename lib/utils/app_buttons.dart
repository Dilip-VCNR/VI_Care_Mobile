import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:vicare/main.dart';
import 'package:vicare/utils/app_colors.dart';

getPrimaryAppButton(BuildContext context, String label,
    {required Future<Null> Function() onPressed, Color? buttonColor}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      // margin: const EdgeInsets.symmetric(horizontal: 2),
      width: screenSize!.width,
      height: 50,
      decoration: BoxDecoration(
          color: buttonColor ?? AppColors.primaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: Center(
          child: Text(
        label,
        style: const TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      )),
    ),
  );
}

showLanguageBottomSheet(
    BuildContext context, Function(String languageCode) onLanguageChange) {
  showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          width: screenSize!.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Select Language",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              ListView.separated(
                  shrinkWrap: true,
                  itemCount: localization.supportedLanguageCodes.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        onLanguageChange(
                            localization.supportedLanguageCodes[index]);
                        Navigator.pop(context);
                      },
                      child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${localization.getLanguageName(languageCode: localization.supportedLanguageCodes[index].toString())} - ${localization.supportedLanguageCodes[index]} ",
                                style: const TextStyle(fontSize: 18),
                              ),
                              localization.supportedLanguageCodes[index] ==
                                      localization.currentLocale!.languageCode
                                  ? const Icon(
                                      Icons.check,
                                      color: AppColors.primaryColor,
                                    )
                                  : const SizedBox.shrink()
                            ],
                          )),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider();
                  }),
            ],
          ),
        );
      });
}

void showImageSourceDialog(BuildContext context,
    {required Future<Null> Function(dynamic value) onOptionSelected}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: const Text("Choose Image Source"),
        children: <Widget>[
          SimpleDialogOption(
            onPressed: () async {
              onOptionSelected('Camera');
              Navigator.pop(context);
            },
            child: const ListTile(
              leading: Icon(Icons.camera),
              title: Text("Camera"),
            ),
          ),
          SimpleDialogOption(
            onPressed: () async {
              onOptionSelected('Gallery');
              Navigator.pop(context);
            },
            child: const ListTile(
              leading: Icon(Icons.image),
              title: Text("Gallery"),
            ),
          ),
        ],
      );
    },
  );
}

void showSuccessNotification(BuildContext context, String content, String title) {
  return ElegantNotification(
    title: Text(title),
    description: Text(content,style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 14,
        color: Colors.white),),
    icon: const Icon(Icons.check_circle, color: Colors.white),
    background: Colors.grey.shade50,
   progressIndicatorColor: Colors.green,
    animationDuration: const Duration(seconds: 3),
  ).show(context);
}

void showErrorNotification(BuildContext context, String content, String title) {
   return ElegantNotification(
    title: Text(title),
    description: Text(content,style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 14,
        color: Colors.white
    ),),
    icon: const Icon(Icons.check_circle, color: Colors.white),
    background: Colors.grey.shade50,
    progressIndicatorColor: Colors.red,
    animationDuration: const Duration(seconds: 3),
  ).show(context);
}

void showSuccessToast(BuildContext context, String content) {
  return DelightToastBar(
    position: DelightSnackbarPosition.top,
    autoDismiss: true,
    animationDuration: const Duration(seconds: 1),
    snackbarDuration: const Duration(seconds: 3),
    builder: (context) => ToastCard(
      color: Colors.green,
      leading: const Icon(
        Icons.check_circle,
        size: 28,
        color: Colors.white,
      ),
      title: Text(
        content,
        style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: Colors.white
        ),
      ),
    ),
  ).show(context);
}

void showErrorToast(BuildContext context, String content) {
  return DelightToastBar(
    position: DelightSnackbarPosition.top,
    autoDismiss: true,
    animationDuration: const Duration(seconds: 1),
    snackbarDuration: const Duration(seconds: 3),
    builder: (context) => ToastCard(
      color: Colors.red,
      leading: const Icon(
        Icons.error,
        size: 28,
        color: Colors.white,
      ),
      title: Text(
        content,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: Colors.white
        ),
      ),
    ),
  ).show(context);
}

showLoaderDialog(BuildContext context) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset('assets/lottie/loading.json', height: 150),
              const Text(
                "Loading...",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              )
            ],
          ),
        );
      });
}



Future<bool>showStopTestWarningDialog(BuildContext context) async {
  bool result = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("Are you sure to abort the test?"),
          backgroundColor: Colors.white,
          content: Text("Aborting in middle of the test will result in loss of recorded data for this test"),
          actions: [
            TextButton(onPressed: () {
              Navigator.pop(context,true);
            },
            child: Text("Yes Abort now",style: TextStyle(color: Colors.red))),
            TextButton(onPressed: () {
              Navigator.pop(context,false);
            },
            child:Text("No Continue test",style: TextStyle(color: Colors.green)))
          ],
        );
      });
  return result; // Default to false if result is null
}