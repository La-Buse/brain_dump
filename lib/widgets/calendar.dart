import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:brain_dump/blocs/calendar/bloc.dart';

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
  @override
  Widget build(BuildContext context) {
    return new BlocBuilder(
      bloc: calendarBloc,
        builder: (BuildContext context, CalendarState state) {
          if (state is InitialCalendarState) {
            calendarBloc.add(FetchItemsEvent(null, null));
            return new Center(child: CircularProgressIndicator(),);
          }
           Map<CalendarFormat,String> calendarFormat = new Map<CalendarFormat, String>();
           calendarFormat.putIfAbsent(CalendarFormat.month, () => 'month');
          return Scaffold(
              resizeToAvoidBottomPadding: false,
              appBar: new AppBar(

              title: new Text("Calendar"),
              actions:  [
                  PopupMenuButton<String>(
                      onSelected: (String optionSelected) {
                        dateNameDescriptionDialog(context,
                          state,
                            calendarBloc,
                            '',
                            false
                        );
                      },
                      itemBuilder: (BuildContext context) {
                        return [PopupMenuItem<String>(
                          value: 'Add calendar event',
                          child: Text('Add calendar event'),
                        )];
                      }
                  ),
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

                  onVisibleDaysChanged: (date1, date2, format) {
                    print(date1);
                    print(date2);
                    print(format);
                    calendarBloc.add(new FetchItemsEvent(date1, date2));
                  },
                  onDaySelected: (date, events) {
                    //selected date is in utc format
                    DateTime utcDate = DateTime.utc(date.year, date.month, date.day);
                    calendarBloc.add(NewDaySelectedEvent(utcDate));
                  },
                ),
                Expanded(child:_buildEventList(state, context, calendarBloc, dateNameDescriptionDialog))
              ],
            )
          );
        }
    );

  }

  Widget _buildEventList(CalendarState thisState, BuildContext thisContext, CalendarBloc thisBloc, Function editCallback) {

    return ListView(
      children: thisState.selectedDayEvents
          .map((event) => Container(
        decoration: BoxDecoration(
          border: Border.all(width: 0.8),
          borderRadius: BorderRadius.circular(12.0),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: ListTile(
          title: Text(event.name),
          onTap: () => print('$event tapped!'),
          trailing: PopupMenuButton(
            onSelected: (String selection) {
              if (selection == 'Delete') {
                thisBloc.add(DeleteCalendarEvent(event));
              } else if (selection == 'Edit') {
                editCallback(thisContext, thisState, thisBloc, '', true);
              } else if (selection == 'Mark as done') {}
            },
            itemBuilder: (BuildContext context) {
              {
                return ['Delete', 'Edit', 'Mark as done'].map((String selection) {
                  return PopupMenuItem<String>(
                    value: selection,
                    child: Text(selection),
                  );
                }).toList();
              }
            },
          ),
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
      CalendarBloc bloc,
      String inputField,
      bool editButtonSelected
      ) {
        return showDialog(
          context: context,
          builder: (BuildContext context) {
            return MyDialogContent(bloc, state, editButtonSelected);
          }
        );
  }


}
class MyDialogContent extends StatefulWidget {
  MyDialogContent(CalendarBloc bloc, CalendarState state, bool editButtonSelected, {
    Key key,
  }) :  this.calendarBloc = bloc, this.calendarState = state, this.editButtonSelected=editButtonSelected,super(key: key);

  CalendarEvent createNewEvent(String name, String description, DateTime timeUtc) {
    return AddNewCalendarEvent(name, description, timeUtc);
  }
  CalendarEvent editEvent(String name, String description, DateTime timeUtc) {
    return new EditCalendarEvent(name, description, timeUtc);
  }

  CalendarState calendarState;
  CalendarBloc calendarBloc;
  bool editButtonSelected;
  @override
  State<StatefulWidget> createState() {
    if (this.editButtonSelected) {
//      this.calendarBloc.add()
      return new MyDialogContentState(this.calendarBloc, this.calendarState, 'Edit', createNewEvent);
    } else {
      return new MyDialogContentState(this.calendarBloc, this.calendarState, 'Confirm', createNewEvent);
    }
  }
}

class MyDialogContentState extends State<MyDialogContent> {
  MyDialogContentState(CalendarBloc calendarBloc, CalendarState state, String actionButtonName, Function actionButtonCallback){
    this.calendarBloc = calendarBloc;
    this.calendarState = state;
    this.actionButtonCallback = actionButtonCallback;
    this.actionButtonName = actionButtonName;
  }
  CalendarBloc calendarBloc;
  CalendarState calendarState;
  String actionButtonName;
  Function actionButtonCallback;

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime nowUtc = DateTime.utc(now.year, now.month, now.day);
    return new BlocBuilder(
      bloc: this.calendarBloc,
      builder: (BuildContext context, CalendarState state) {
        String name = state.name;
        DateTime dateSelected = state.newEventDate;
        String description = state.description;
        return AlertDialog(
                          title: new Text(
                state.newEventDate == null ? 'No date selected.' : state.newEventDate.toIso8601String()),
                actions: [
                  new FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: new Text('Cancel')),
                  new FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        calendarBloc.add(this.actionButtonCallback(name, description, dateSelected));
                      },
                      child: new Text(this.actionButtonName))
                ],
              content: Column(
                children: [
                  new Text('Selected date : ' +
                      (state.newEventDate == null ? 'No date selected.' : state.newEventDate.toIso8601String())),
                  RaisedButton(
                    child: Text('Select another date'),
                    onPressed: () {
                      showDatePicker(
                          context: context,
                          initialDate: nowUtc,
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2030)
                      ).then((date) {
                        //selected date is not in utc format
                        DateTime dateUtc = DateTime.utc(date.year, date.month, date.day, 0);
                        dateSelected = dateUtc;
                        calendarBloc.add(NewEventDateSelected(name, description, dateUtc));
                      });
                    },
                  ),
                  new TextFormField(
                      initialValue: name,
                      decoration: new InputDecoration(
                        labelText: "Name",
                      ),
                      onChanged: (String str) {
                        name = str;
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
                      onChanged: (newDescription) {
                        description = newDescription;
                      },
                    ),
                    // ends the actual text box

                  ),
                ],
              )
        ) ;


      }
    );
  }

  static Future<Null> confirmationDialog (BuildContext context, String message, Function callback) {
    return showDialog(
      barrierDismissible: true,
      builder: (BuildContext context) {
        return new AlertDialog(
            contentPadding: EdgeInsets.all(20.0),
            title: new Text(message),
            content: new Text(message),
            actions: [
              new FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: new Text('Cancel')),
              new FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    callback();
                  },
                  child: new Text('Confirm'))
            ]);
      },
      context: context,
    );
  }
}