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
  T:TextFile;
FN:String;
begin
  // Getting the filename for the logfile (In this case the Filename is 'application-exename.log'
  FN := ChangeFileExt(Application.Exename, '.log');
  // Assigns Filename to variable F
  AssignFile(T, FN);
  // Rewrites the file F
  Rewrite(T);
  // Open file for appending
  Append(T);
  // Write text to Textfile F
  WriteLn(T, sLineBreak);
  WriteLn(T, 'This Logfile was created on ' + DateTimeToStr(Now));
  WriteLn(T, sLineBreak);
  WriteLn(T, '');
  // finally close the file
  CloseFile(T);
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
