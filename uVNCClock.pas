unit uVNCClock;
{$mode objfpc}{$H+}

interface
uses
   GlobalConst,
   SysUtils,
   uVNC, uCanvas;

procedure RunClock;

implementation
procedure RunClock;
var
  aVnc: TVNCServer;
  FrameCounter: Integer;
begin
  aVNC := TVNCServer.Create;
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
end;
end.
