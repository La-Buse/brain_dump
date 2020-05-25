import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:brain_dump/blocs/calendar/bloc.dart';
import 'package:brain_dump/widgets/confirmation_dialog.dart';

import '../blocs/calendar/bloc.dart';

class Calendar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _CalendarState();
  }
}

class _CalendarState extends State<Calendar> {
  final calendarBloc = CalendarBloc();
  final CalendarController calendarController = new CalendarController();
  Map<DateTime, List> _events;
  List _selectedEvents;
  @override
  Widget build(BuildContext context) {
    return new BlocBuilder(
      bloc: calendarBloc,
        builder: (BuildContext context, CalendarState state) {
        Map<CalendarFormat,String> calendarFormat = new Map<CalendarFormat, String>();
        calendarFormat.putIfAbsent(CalendarFormat.month, () => 'month');
          return Scaffold(
              resizeToAvoidBottomPadding: false,
              appBar: new AppBar(

              title: new Text("Calendar"),
              actions:  [
                  PopupMenuButton<String>(onSelected: (String optionSelected) {
//                    dateNameDescriptionDialog(context,
//                        state,
//                            (newDate){
//                               calendarBloc.add(NewEventDateSelected(newDate));
//                            },
//                        '');
                  var inputField = '';
                    return showDialog(
                      barrierDismissible: true,
                      builder: (BuildContext context) {
                        DateTime now = DateTime.now();
                        DateTime nowUtc = DateTime.utc(now.year, now.month, now.day);
                        return new AlertDialog(
                            contentPadding: EdgeInsets.all(20.0),
                            title: new Text(
                                state.newEventDate == null ? 'No date selected.' : state.newEventDate.toIso8601String()),
                            content: ListView(
                              children: [
//                  Text(
//                    'Enter date',
//
//                  ),
                                RaisedButton(
                                  child: Text('Pick a date'),
                                  onPressed: () {
                                    showDatePicker(
                                        context: context,
                                        initialDate: nowUtc,
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime(2030)
                                    ).then((date) {
                                      calendarBloc.add(NewEventDateSelected(date));
                                    });
                                  },
                                ),
                                new TextFormField(
                                    initialValue: inputField,
                                    decoration: new InputDecoration(
                                      labelText: "Name",
                                    ),
                                    onChanged: (String str) {
                                      inputField = str;
                                    }),
                                new SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  reverse: true,

                                  // here's the actual text box
                                  child: new TextField(
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null, //grow automatically
                                    decoration: new InputDecoration(
                                      labelText: 'Description',
                                    ),
                                  ),
                                  // ends the actual text box

                                ),
                              ],
                            ),



                            actions: [
                              new FlatButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: new Text('Cancel')),
                              new FlatButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();

                                  },
                                  child: new Text('Confirm'))
                            ]);
                      },
                      context: context,
                    );
                  }, itemBuilder: (BuildContext context) {
                  return [PopupMenuItem<String>(
                    value: 'Add calendar event',
                    child: Text('Add calendar event'),
                  )];
                  }),
          ],
            ),

            body: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                TableCalendar(
                  availableCalendarFormats: calendarFormat,
                  calendarStyle: CalendarStyle(
                      todayColor: Colors.orange,
                      selectedColor: Theme.of(context).primaryColor
                  ),
                  calendarController: calendarController,
                  events: state.allEvents,
                  onDaySelected: (date, events) {
                    calendarBloc.add(NewDaySelectedEvent(date));
                  },
                ),
                Expanded(child:_buildEventList(state))
              ],
            )
          );
        }
    );

  }

  Widget _buildEventList(CalendarState state) {

    return ListView(
      children: state.selectedDayEvents
          .map((event) => Container(
        decoration: BoxDecoration(
          border: Border.all(width: 0.8),
          borderRadius: BorderRadius.circular(12.0),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: ListTile(
          title: Text(event.toString()),
          onTap: () => print('$event tapped!'),
        ),
      ))
          .toList(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    calendarBloc.close();
  }

  static Future<Null> dateNameDescriptionDialog(
      BuildContext context,
      CalendarState state,
      Function callback,
      String inputField
      ) {

    return showDialog(
      barrierDismissible: true,
      builder: (BuildContext context) {
        DateTime now = DateTime.now();
        DateTime nowUtc = DateTime.utc(now.year, now.month, now.day);
        return new AlertDialog(
            contentPadding: EdgeInsets.all(20.0),
            title: new Text(
                state.newEventDate == null ? 'No date selected.' : state.newEventDate.toIso8601String()),
            content: ListView(
              children: [
//                  Text(
//                    'Enter date',
//
//                  ),
                RaisedButton(
                  child: Text('Pick a date'),
                  onPressed: () {
                    showDatePicker(
                        context: context,
                        initialDate: nowUtc,
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2030)
                    ).then((date) {
                      callback(date);
                    });
                  },
                ),
                new TextFormField(
                    initialValue: inputField,
                    decoration: new InputDecoration(
                      labelText: "Name",
                    ),
                    onChanged: (String str) {
                      inputField = str;
                    }),
//                  new TextFormField(
//                      initialValue: inputField,
//                      decoration: new InputDecoration(
//                        labelText: "Description",
//                      ),
//                      onChanged: (String str) {
//                        inputField = str;
//                      }),
                new SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  reverse: true,

                  // here's the actual text box
                  child: new TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null, //grow automatically
                    decoration: new InputDecoration(
                      labelText: 'Description',
                    ),
                  ),
                  // ends the actual text box

                ),
              ],
            ),



            actions: [
              new FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: new Text('Cancel')),
              new FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    callback(inputField);
                  },
                  child: new Text('Confirm'))
            ]);
      },
      context: context,
    );
  }
}