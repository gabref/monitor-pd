unit Log;

interface

uses
  Windows, System.Classes, System.SysUtils, Vcl.Forms, System.IOUtils;

  procedure CreateLogfile;
  procedure WriteLogs(data: string);

implementation

//** This procedure just creates a new Logfile an appends when it was created **
procedure CreateLogfile;
var
  StreamWriter: TStreamWriter;
  FileName: string;
begin
  // Getting the filename for the logfile (In this case, the Filename is 'application-exename.log'
  FileName := ChangeFileExt(Application.Exename, '.log');

  // Create the TStreamWriter instance with ASCII encoding
  StreamWriter := TStreamWriter.Create(FileName, False, TEncoding.ASCII);
  try
    // Write the log content
    StreamWriter.WriteLine('');
    StreamWriter.WriteLine('This Logfile was created on ' + DateTimeToStr(Now));
    StreamWriter.WriteLine('');
    StreamWriter.WriteLine('');
  finally
    // Free the TStreamWriter object
    StreamWriter.Free;
  end;
end;

// Procedure for appending a Message to an existing logfile with current Date and Time **
procedure WriteLogs(data:String);
var
  T:TextFile;
FN:String;
begin
  // Getting the filename for the logfile (In this case the Filename is 'application-exename.log'
  FN := ChangeFileExt(Application.Exename, '.log');

  //Checking for file
  if (not FileExists(FN)) then
  begin
    // if file is not available then create a new file
    CreateLogFile;
  end;

  // Assigns Filename to variable F
  AssignFile(T, FN);
  // start appending text
  Append(T);
  //Write a new line with current date and message to the file
  WriteLn(T, DateTimeToStr(Now) + ': ' + data);
  // Close file
  CloseFile(T)
end;


end.
