program evidencia;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, zaklad, zaznamy, databaza, pref, about, statistik
  { you can add units after this };

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TEvidence, Evidence);
  Application.CreateForm(TNastavenie, Nastavenie);
  Application.CreateForm(Toprog, oprog);
  Application.CreateForm(TStat, Stat);
  Application.Run;
end.

