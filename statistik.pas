unit statistik;

{$mode objfpc}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, zaznamy, Math;

type
  { TStat }
  TBlbost = array[0..10] of integer;
  TStat = class(TForm)
    Img2: TImage;
    Img: TImage;
    procedure FormCreate(Sender: TObject);
    procedure top10(aaa: TZoznam);
    procedure mapka(bbb: TZoznam);
    procedure kraj(aaa: TZoznam);
    procedure vykresli(obr,obr1 : TCanvas; ev: TZaznam);
    procedure vykresliskup(obr,obr1 : TCanvas; a: array of string ;b : TBlbost; moznost : integer);
    function najvacsie(cislo: TBlbost) : TBlbost;
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Stat: TStat;
  W : TZoznam;
  celkovo, celkovoskup : integer;
  inekafe, kafe: array of string;

implementation

{ TStat }

procedure TStat.vykresli(obr, obr1: TCanvas; ev: TZaznam);
var
  i:integer;
begin
  randomize;
  obr.Brush.Style := bsSolid;
  obr.FillRect(Img.ClientRect);
  obr1.FillRect(Img.ClientRect);
  obr.Pen.Color := clGray;
  for i:=1 to 9 do
   obr.Line(10, 10+(i*38), 790, 10+(i*38));
  obr.Pen.Color := clBlack;
  obr1.Pen.Color := clBlack;
  obr.Pen.Width := 2;
  obr.Brush.Style := bsClear;
  obr.rectangle(10,10,790,390);
  obr.Brush.Style := bsSolid;
   celkovo := 0;
  for i:=0 to 9 do
   if length(ev) >= (i+1) then
    celkovo := celkovo + W.Dalsie[i].Skoda;
  obr.TextOut(325, 5, ' TOP 10 Pomer (Škoda/Chytený)' );
  for i:=0 to 9 do
  begin
   if length(ev) >= (i+1) then
   begin
    obr.Brush.Style := bsSolid;
    obr.Pen.Width := 1;
    obr.Brush.Color := RGBToColor(Random(256),Random(256),Random(256));
    obr1.Brush.Color := obr.Brush.Color;
    obr.rectangle(10+(25*(i+1))+(i*50), 390, 10+(25*(i+1))+(i*50)+50, 390-Round((380/celkovo)*ev[i].Skoda));
    obr1.rectangle(5,(10*i)+(i*10),15, (10*i)+((i+1)*10));
    obr.Brush.Color := clWhite;
    obr1.Brush.Color := obr.Brush.Color;
    obr.Brush.Style := bsClear;
    obr.TextOut(10+(25*(i+1))+(i*50)+10, 390-Round((380/celkovo)*ev[i].Skoda+13), inttostr(ev[i].Skoda));
    obr1.TextOut(20,(10*i)+(i*10), ev[i].Meno + ' ' + ev[i].Priezvisko);
   end;
  end;
end;

procedure TStat.FormCreate(Sender: TObject);
begin
  W := TZoznam.Create;
end;

procedure TStat.top10(aaa: TZoznam);
var
  i: integer;
begin
 W := aaa;
 setlength(W.pomocne, 0);
 setlength(W.Dalsie, length(W.Zaznamy));
     for i := 0 to high(W.Zaznamy) do
     begin
      W.Dalsie[i].Meno := W.Zaznamy[i].Meno;
      W.Dalsie[i].Priezvisko := W.Zaznamy[i].Priezvisko;
      W.Dalsie[i].Skoda := W.Zaznamy[i].Skoda div (W.Zaznamy[i].Chyteny+1);
      end;
     W.Pamat := W.RadixNum(W.Dalsie, -2);
     setlength(W.pomocne, length(W.Pamat));
     for i := 0 to high(W.Pamat) do
     begin
      W.pomocne[i] := W.Pamat[i]^; //priradenie zoradenych hackerov
     end;
     vykresli(img.Canvas, img2.Canvas, W.Pomocne);
end;

procedure TStat.mapka(bbb: TZoznam);
var
  j,e: TBlbost;
  k: integer;
begin
  W := bbb;
  setlength(inekafe, 11);
  setlength(kafe, 11);
  inekafe[0] := 'Anonymous';
  inekafe[1] := 'Blackhole';
  inekafe[2] := 'Dzihad';
  inekafe[3] := 'EliteZ';
  inekafe[4] := 'EVE';
  inekafe[5] := 'HaxorZ';
  inekafe[6] := 'Hysteria';
  inekafe[7] := 'ISS';
  inekafe[8] := 'LulzSec';
  inekafe[9] := 'Mysteria';
  inekafe[10]:= 'Ostatne';
  for k:= 0 to high(inekafe) do
  begin
    W.Pomocne := W.Hladaj(AnsiLowerCase(inekafe[k]), W.Zaznamy, 4);
    j[k] := length(W.Pomocne);
  end;
  e := najvacsie(j);
  vykresliskup(Img.Canvas, Img2.Canvas, inekafe, e, 1);
end;

procedure TStat.kraj(aaa: TZoznam);
var
  j,e: TBlbost;
  k: integer;
begin
  W := aaa;
  setlength(inekafe, 11);
  setlength(kafe, 11);
  inekafe[0] := 'Brazilia ';
  inekafe[1] := 'Cesko';
  inekafe[2] := 'Francuzko';
  inekafe[3] := 'Madarsko';
  inekafe[4] := 'Nemecko';
  inekafe[5] := 'Polsko';
  inekafe[6] := 'Rusko';
  inekafe[7] := 'Slovensko';
  inekafe[8] := 'Turecko';
  inekafe[9] := 'USA';
  inekafe[10]:= 'Ostatne';
  for k:= 0 to high(inekafe) do
  begin
    W.Pomocne := W.Hladaj(AnsiLowerCase(inekafe[k]), W.Zaznamy, 3);
    j[k] := length(W.Pomocne);
  end;
  e := najvacsie(j);
  vykresliskup(Img.Canvas, Img2.Canvas, inekafe, e, 2);
end;

procedure TStat.vykresliskup(obr,obr1 : TCanvas; a: array of string ;b : TBlbost; moznost : integer);
var
  i: integer;
begin
  randomize;
    obr.Brush.Style := bsSolid;
    obr.FillRect(Img.ClientRect);
    obr1.FillRect(Img.ClientRect);
    obr.Pen.Color := clGray;
    celkovoskup := 0;
    for i:=0 to 9 do
     celkovoskup := celkovoskup + b[i];
    for i:=1 to 9 do
     obr.Line(10, 10+(i*38), 790, 10+(i*38));
    obr.Pen.Color := clBlack;
    obr1.Pen.Color := clBlack;
    obr.Pen.Width := 2;
    obr.Brush.Style := bsClear;
    obr.rectangle(10,10,790,390);
    obr.Brush.Style := bsSolid;
    case moznost of
      1: obr.TextOut(325, 5, '  TOP 10 Skupiny  ');
      2: obr.TextOut(325, 5, '  TOP 10 Krajiny  ');
    end;
    for i:=0 to 9 do
    begin
     if length(a) >= (i+1) then
     begin
      obr.Brush.Style := bsSolid;
      obr.Pen.Width := 1;
      obr.Brush.Color := RGBToColor(Random(256),Random(256),Random(256));
      obr1.Brush.Color := obr.Brush.Color;
      obr.rectangle(10+(25*(i+1))+(i*50), 390, 10+(25*(i+1))+(i*50)+50, 390-Round((380/celkovoskup)*b[i]));
      obr1.rectangle(5,(10*i)+(i*10),15, (10*i)+((i+1)*10));
      obr.Brush.Color := clWhite;
      obr1.Brush.Color := obr.Brush.Color;
      obr.Brush.Style := bsClear;
      obr.TextOut(10+(25*(i+1))+(i*50)+10, 390-Round((380/celkovoskup)*b[i]+13), inttostr(b[i]));
      obr1.TextOut(20,(10*i)+(i*10), a[i]);
     end;
    end;
end;

function TStat.najvacsie(cislo: TBlbost): TBlbost;
var
  i,j: integer;
  prve : boolean;
  pc : TBlbost;
begin
  pc := cislo;
  for i:= 0 to high(cislo) do
  begin
   result[i] := maxvalue(pc);
   prve := true;
   for j:= 0 to high(pc) do
   begin
    if (pc[j] = result[i]) and prve then
    begin
     pc[j] := -1;
     kafe[i] := inekafe[j];
     prve := false;
    end;
   end;
  end;
  inekafe := kafe;
end;

initialization
  {$I statistik.lrs}

end.

