program VNCTest;

{$mode objfpc}{$H+}

{$define use_tftp}
{$hints off}
{$notes off}

uses
//{$ifdef BUILD_QEMUVPB} QEMUVersatilePB, VersatilePB, {$endif}
//{$ifdef BUILD_RPI    } RaspberryPi,                  {$endif}
//{$ifdef BUILD_RPI2   } RaspberryPi2,                 {$endif}
//{$ifdef BUILD_RPI3   } RaspberryPi3,                 {$endif}
  RaspberryPi3,
  GlobalConfig,
  GlobalConst,
  GlobalTypes,
  Platform,
  Threads,
  SysUtils,
  Classes,
  Console,
  Ultibo, uVNC, uCanvas,
  Winsock2,
{$ifdef use_tftp}
  uTFTP,
{$endif}
  uLog,
  uVNCDemo,
  uVNCClock
  { Add additional units here };

var
  Console1, Console2, Console3 : TWindowHandle;
  IPAddress : string;

procedure SerialChar (c : char);
begin
  {$ifdef BUILD_QEMUVPB}
    PLongWord(VERSATILEPB_UART0_REGS_BASE)^ := Ord(c);
  {$endif}
end;

procedure SerialMessage (s : string);
var
  i : integer;
begin
  for i:=1 to High (s) do
    SerialChar (s[i]);
  SerialChar (char (10));
end;

procedure Log1 (s : string);
begin
  ConsoleWindowWriteLn (Console1, s);
  SerialMessage ('Log1 ' + s);
end;

procedure Log2 (s : string);
begin
 ConsoleWindowWriteLn (Console2, s);
  SerialMessage ('Log2 ' + s);
end;

procedure Log3 (s : string);
begin
  ConsoleWindowWriteLn (Console3, s);
  SerialMessage ('Log3 ' + s);
end;

procedure Msg2 (Sender : TObject; s : string);
begin
  Log2 ('TFTP - ' + s);
end;

procedure WaitForSDDrive;
begin
  {$ifndef BUILD_QEMUVPB}
    while not DirectoryExists ('C:\') do sleep (500);
  {$endif}
end;

function WaitForIPComplete : string;
var
  TCP : TWinsock2TCPClient;
begin
  TCP := TWinsock2TCPClient.Create;
  Result := TCP.LocalAddress;
  if (Result = '') or (Result = '0.0.0.0') or (Result = '255.255.255.255') then
    begin
      while (Result = '') or (Result = '0.0.0.0') or (Result = '255.255.255.255') do
        begin
          sleep (1000);
          Result := TCP.LocalAddress;
        end;
    end;
  TCP.Free;
end;

procedure RestoreBootFile(Prefix,FileName:String);
var
 Source:String;
begin
 Source:=Prefix + '-' + FileName;
 Log(Format('Restoring from %s ...',[Source]));
 while not DirectoryExists('C:\') do
  sleep(500);
 if FileExists(Source) then
  CopyFile(PChar(Source),PChar(FileName),False);
 Log(Format('Restoring from %s done',[Source]));
end;

procedure RunMain;
begin
  Console1 := ConsoleWindowCreate (ConsoleDeviceGetDefault, CONSOLE_POSITION_LEFT, true);
  Console2 := ConsoleWindowCreate (ConsoleDeviceGetDefault, CONSOLE_POSITION_TOPRIGHT, false);
  Console3 := ConsoleWindowCreate (ConsoleDeviceGetDefault, CONSOLE_POSITION_BOTTOMRIGHT, false);
  SetLogProc (@Log1);
  Log1 ('VNC Server Test.');
  Log1 ('2018 pjde.');

  RestoreBootFile('default','config.txt');

  Log3 ('');
  WaitForSDDrive;
  Log1 ('SD Drive Ready.');
  IPAddress := WaitForIPComplete;
  Log1 ('Run VNC Viewer and point to ' + IPAddress);

{$ifdef use_tftp}
  Log2 ('TFTP - Enabled.');
  Log2 ('TFTP - Syntax "tftp -i ' + IPAddress + ' PUT kernel7.img"');
  SetOnMsg (@Msg2);
  Log2 ('');
{$endif}

  VncDemoServer (5900, Console3);
  VncClockServer (5901);
  ThreadHalt (0);
end;

begin
 RunMain;
end.
