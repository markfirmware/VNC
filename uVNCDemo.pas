unit uVncDemo;

{$mode objfpc}{$H+}

{$hints off}
{$notes off}

interface
uses
  GlobalTypes;
procedure VncDemoServer (SetPort: Integer; SetConsole3: TWindowHandle);

implementation
uses
  GlobalConfig,
  GlobalConst,
  Platform,
  Threads,
  SysUtils,
  Classes,
  Console,
  Ultibo, uVNC, uCanvas,
  uLog
  { Add additional units here };

type
  { THelper }
  THelper = class
    procedure VNCPointer (Sender : TObject; Thread : TVNCThread; x, y : TCard16; BtnMask : TCard8);
    procedure VNCKey (Sender : TObject; Thread : TVNCThread; Key : TCard32; Down : boolean);
  end;

var
  Port: Integer;
  LoopHandle:TThreadHandle = INVALID_HANDLE_VALUE;
  Console3: TWindowHandle;
  aVnc: TVNCServer;
  Helper: THelper;

{ THelper }

procedure THelper.VNCPointer (Sender: TObject; Thread: TVNCThread; x,
  y: TCard16; BtnMask: TCard8);
begin
  ConsoleWindowSetXY (Console3, 1, 1);
  Consolewindowwrite (Console3, IntToStr (x) + ',' + IntToStr (y) + ' Btns ' + BtnMask.ToHexString (2) + '    ');
end;

var
  PixelY:Integer=160 + 60;

procedure THelper.VNCKey (Sender: TObject; Thread: TVNCThread; Key: TCard32;
  Down: boolean);
begin
  ConsoleWindowSetXY (Console3, 1, 2);
  Consolewindowwrite (Console3, IntToStr (Key) + ' Down ' + ft[Down] + '    ');
  aVNC.Canvas.DrawText (40, PixelY, 'Key Pressed!', 'arial', 24, COLOR_WHITE);
  Inc(PixelY, 60);
end;

function Loop (Parameter: Pointer): PtrInt;
var
  ch: Char;
begin
  try
    Result := 0;
    aVnc := TVNCServer.Create (Port);
    Helper := THelper.Create;
    aVNC.OnKey := @Helper.VNCKey;
    aVNC.OnPointer := @Helper.VNCPointer;
    aVNC.InitCanvas (640, 480);
    aVNC.Canvas.Fill (COLOR_RED);
    aVNC.Canvas.Fill (SetRect (50, 50, 100, 200), COLOR_GREEN);
    aVNC.Canvas.Fill (SetRect (200, 50, 250, 300), COLOR_BLUEIVY);
    aVNC.Canvas.DrawText (40, 40, 'ULTIBO VNC TEST.', 'arial', 24, COLOR_WHITE);
    aVNC.Canvas.DrawText (40, 100, 'THIS IS A CANVAS.', 'arial', 24, COLOR_WHITE);
    aVNC.Canvas.DrawText (40, 160, 'THIS IS NOT THE FRAMEBUFFER.', 'arial', 24, COLOR_WHITE);
    aVNC.Title := 'Demo of Ultibo VNC Server';
    aVNC.Active := true;
    ch := #0;
    while true do
      begin
        if ConsoleGetKey (ch, nil) then
          case (ch) of
            '1' : aVNC.Active := true;
            '2' : aVNC.Active := false;
            end;
      end;
  except on
    E: Exception do
      Log (E.Message);
  end;
end;

procedure VncDemoServer (SetPort: Integer; SetConsole3: TWindowHandle);
begin
  Port := SetPort;
  Console3 := SetConsole3;
  BeginThread(@Loop,Nil,LoopHandle,THREAD_STACK_DEFAULT_SIZE);
end;
end.
