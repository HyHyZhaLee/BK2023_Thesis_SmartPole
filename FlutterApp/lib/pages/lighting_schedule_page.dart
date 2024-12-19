import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter_app/widgets/add_event_dialog.dart';
import 'package:flutter_app/widgets/event_details_dialog.dart';
import 'package:flutter_app/utils/custom_route.dart';
import 'package:flutter_app/provider/event_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/model/appointment_extension.dart';

class LightingSchedulePage extends StatefulWidget {
  const LightingSchedulePage({super.key});

  @override
  _LightingSchedulePage createState() => _LightingSchedulePage();
}

class _LightingSchedulePage extends State<LightingSchedulePage> {
  late List<CustomAppointment> _appointments;
  final CalendarView _calendarView = CalendarView.month;
  late CustomAppointmentDataSource _calendarDataSource;

  @override
  void initState() {
    super.initState();
    // Set up listener to update appointments from provider
    final provider =
        Provider.of<CustomAppointmentProvider>(context, listen: false);

    provider.listenForRealtimeUpdates();

    _appointments = provider.appointments;
    _calendarDataSource = CustomAppointmentDataSource(_appointments);

    // Add a listener to provider changes
    provider.addListener(updateAppointments);
  }

  void updateAppointments() {
    final provider =
        Provider.of<CustomAppointmentProvider>(context, listen: false);
    setState(() {
      _appointments = provider.appointments;
      _calendarDataSource = CustomAppointmentDataSource(_appointments);
    });
  }

  @override
  void dispose() {
    Provider.of<CustomAppointmentProvider>(context, listen: false)
        .removeListener(updateAppointments);
    super.dispose();
  }

  String _getDayOfWeek(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'MO';
      case DateTime.tuesday:
        return 'TU';
      case DateTime.wednesday:
        return 'WE';
      case DateTime.thursday:
        return 'TH';
      case DateTime.friday:
        return 'FR';
      case DateTime.saturday:
        return 'SA';
      case DateTime.sunday:
        return 'SU';
      default:
        return 'MO';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SfCalendar(
        view: _calendarView,
        headerHeight: 50,
        headerStyle: const CalendarHeaderStyle(
          textStyle: TextStyle(color: Colors.white, fontSize: 20),
          textAlign: TextAlign.center,
          backgroundColor: Colors.blue,
        ),
        firstDayOfWeek: 1,
        dataSource: _calendarDataSource,
        allowDragAndDrop: false,
        showNavigationArrow: false,
        showDatePickerButton: true,
        showTodayButton: true,
        allowViewNavigation: false,
        showCurrentTimeIndicator: true,
        allowAppointmentResize: true,
        cellBorderColor: Colors.transparent,
        onTap: handleCalendarTap,
        monthViewSettings: const MonthViewSettings(
            showAgenda: true,
            agendaViewHeight: 200.0,
            appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurpleAccent,
        shape: const CircleBorder(),
        onPressed: () => Navigator.of(context)
            .push(AddEventPageRuote(page: const AddEventPage())),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  void handleCalendarTap(CalendarTapDetails details) {
    if (details.targetElement == CalendarElement.appointment &&
        details.appointments != null &&
        details.appointments!.isNotEmpty) {
      final CustomAppointment appointment = details.appointments!.first;
      EventDetailsDialog.show(
        context,
        appointment,
      );
    } else if (details.targetElement == CalendarElement.calendarCell &&
        details.date != null &&
        (details.appointments == null || details.appointments!.isEmpty)) {
      if (kDebugMode) {
        print("Tapped on Date: ${details.date}");
      }
      // Here you can handle other actions like navigating to an add event page
      navigateToAddEventPage(context, details.date);
    }
  }

  void navigateToAddEventPage(BuildContext context, DateTime? selectedDate) {
    if (selectedDate != null) {
      Navigator.of(context).push(AddEventPageRuote(
          page: AddEventPage(
        date: selectedDate,
      )));
    }
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.blue,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
