unit uVNCClock;
{$mode objfpc}{$H+}

interface
procedure VncClockServer (SetPort: Integer);

implementation

uses
   GlobalConst, GlobalTypes, GlobalConfig, SysUtils, uVNC, uCanvas, Threads, uLog;

var
  Port: Integer;
  LoopHandle:TThreadHandle = INVALID_HANDLE_VALUE;

function Loop (Parameter: Pointer): PtrInt;
var
  aVnc: TVNCServer;
  FrameCounter: Integer;
begin
  try
    Result := 0;
    aVNC := TVNCServer.Create (Port);
    aVNC.InitCanvas (640, 480);
    aVNC.Canvas.Fill (COLOR_WHITE);
    aVNC.Title := 'Clock Test of Ultibo VNC Server';;
    aVNC.Active := true;
    FrameCounter := 1;
    while True do
      begin
        aVnc.Canvas.Fill (SetRect (40, 100, 300, 160), COLOR_YELLOW);
        aVnc.Canvas.DrawText (40, 160, Format ('FrameCounter %d', [FrameCounter]), 'arial', 24, COLOR_BLACK);
        Inc (FrameCounter);
        Sleep (1*1000);
      end;
  except on
    E: Exception do
      Log (E.Message);
  end;
end;

procedure VncClockServer (SetPort: Integer);
begin
  Port := SetPort;
  BeginThread(@Loop,Nil,LoopHandle,THREAD_STACK_DEFAULT_SIZE);
end;
end.
