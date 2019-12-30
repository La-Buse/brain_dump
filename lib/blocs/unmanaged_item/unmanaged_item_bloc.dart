import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class UnmanagedItemBloc extends Bloc<UnmanagedItemEvent, UnmanagedItemState> {


  @override
  UnmanagedItemState get initialState => InitialUnmanagedItemState();

  @override
  Stream<UnmanagedItemState> mapEventToState(
    UnmanagedItemEvent event,
  ) async* {
    UnmanagedItemState state = InitialUnmanagedItemState();
        await state.initializeItems();
        yield state;
  }
}
