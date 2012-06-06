unit pref;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Grids;

type

  { TNastavenie }

  TNastavenie = class(TForm)
    Button1: TButton;
    Button2: TButton;
    N: TCheckGroup;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Nastavenie: TNastavenie;
  Nastav: TStream;
  tabulator: TStringGrid;


implementation

{$R *.lfm}

{ TNastavenie }

procedure TNastavenie.Button1Click(Sender: TObject);
var
  i: Integer;
begin //ulozenie nastavenia
  if not fileexists('nastavenie.ini') then //v pripade ak nie je este subor
  begin
    Nastav := TFileStream.Create('nastavenie.ini', fmCreate);
    Nastav.Free;
  end;
  Nastav := TFileStream.Create('nastavenie.ini', fmOpenWrite);
  Nastav.Size := 0; //ako rewrite
  Nastav.Position := 0;
  for i := 0 to N.Items.Count - 1 do //zapiseme do subor ,ktore stlpce maju byt zobrazene
  begin
    tabulator.Columns.Items[i + 1].Visible := N.Checked[i];
    Nastav.Write(N.Checked[i], SizeOf(boolean));
  end;
  Nastav.Destroy;
  Close;  //zatvori formular nastavenia
end;

procedure TNastavenie.Button2Click(Sender: TObject);
begin
  Close; //zatvori bez ulozenia
end;

procedure TNastavenie.FormCreate(Sender: TObject);
var
  i: Integer;
  PomZob: array of Boolean;
begin
  if fileexists('nastavenie.ini') then
    //pri vytvoreni overi ci mame uz nejake nastavenie a tak zaskrtava checkboxy
  begin
    Nastav := TFileStream.Create('nastavenie.ini', fmOpenRead);
    Nastav.Position := 0;
    for i := 0 to N.Items.Count - 1 do
    begin
      setlength(PomZob, length(PomZob) + 1);
      Nastav.Read(PomZob[i], SizeOf(boolean));
      N.Checked[i] := PomZob[high(PomZob)];
    end;
    Nastav.Destroy;
  end;
end;

end.

