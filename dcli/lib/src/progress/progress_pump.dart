// ignore_for_file: dangling_library_doc_comments
/// After a process is spawned via mailbox/isolate
/// the data is retrieved via this pump.
/// 
/// The code that spawns the isolate does not read the
/// data but instead waits for the user to call one
/// of the Progress methods which then starts the
/// pump (which runs synchronously) and pushes the
/// data out via the callback
/// 
/// For something like a call to 'lines' we fetch all
/// of the lines util the process exists and then
/// return from the call to lines.
/// 
/// For a Progress Stream we somehow need
/// to get the mailbox to push the data directly into the
/// stream.
/// 
/// is this even possible?
/// Could we start the stream - push in a fake 'iniital' package
/// and then each time listen does a callback force another
/// round trip to the mailbox which adds another item to the stream.
/// repeat until the mailbox comes up empty.
/// 
/// 
/// So in each case the progress needs access to the mailbox.
/// Essentially when 'processUntil' is called we need to 
/// do that in the progress.
/// 
/// 
