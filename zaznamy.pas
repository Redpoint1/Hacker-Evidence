unit zaznamy;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, Grids, Math;

type
  TRecord = record //zaznam hackera
    Id: integer;
    Meno, Priezvisko, Nick, Krajina, Uroven, Skupina: string[30];
    Skoda, Chyteny: integer;
  end;
  TZaznam = array of TRecord; //cela evidencia
  TPamat = array of ^TRecord; //adresy hackerov
  TAdresa = ^TRecord; //adresa hackera

  { TZoznam }

  TZoznam = class
    Zaznamy, Pomocne, Dalsie: TZaznam; //evidencia hackerov
    Pamat: TPamat;
    Nastavenie: array of boolean; //nastavenie stlpcov
    procedure Ukaz(tab: TStringGrid; zaz: TZaznam); //zobrazi evidenciu
    procedure Zmaz(Index: integer); //zmaze hackera
    procedure Zmen(Row, Col: integer; tab: TStringGrid); //zmeni udaje o hackerovi
    procedure Zobrazenie;
    function NajdiID(Index: integer): integer;
    //Unikatne ID pre kazdeho hackera (pomocne na zmenu, vymazanie ..)
    function Radix(pole: TZaznam; moznost: integer): TPamat; //zoradenie pismien
    function RadixNum(pole: TZaznam; moznost: integer): TPamat; //zoradenie cisiel
    function Hladaj(co: string; vcom: TZaznam; ktore: integer): TZaznam;
  end;

implementation

{ TZoznam }

procedure TZoznam.Ukaz(tab: TStringGrid; zaz: TZaznam);
var
  i: integer;
begin
  tab.Clear; //vycisti tabulki
  tab.RowCount := length(zaz) + 1; //nastavenie dlzky tabulky podla poctu hackerov
  Zobrazenie;
  for i := 1 to 6 do
    tab.Columns.Items[i].Visible := Nastavenie[i - 1]; //zobr. stlpce podla nastavenia
  for i := 0 to high(zaz) do //priradi do stlcpov informacie o hackerovi
  begin
    tab.Cells[1, i + 1] := IntToStr(zaz[i].Id);
    tab.Cells[2, i + 1] := zaz[i].Meno;
    tab.Cells[3, i + 1] := zaz[i].Priezvisko;
    tab.Cells[4, i + 1] := zaz[i].Nick;
    tab.Cells[5, i + 1] := zaz[i].Krajina;
    tab.Cells[6, i + 1] := zaz[i].Uroven;
    tab.Cells[7, i + 1] := zaz[i].Skupina;
    tab.Cells[8, i + 1] := IntToStr(zaz[i].Skoda);
    tab.Cells[9, i + 1] := IntToStr(zaz[i].Chyteny);
  end;
end;

procedure TZoznam.Zmaz(Index: integer);
var
  pom: TZaznam;
  i: integer;
begin
  if (length(zaznamy) >= index) and (Index > 0) then //osetrenie
  begin
    if length(zaznamy) > index then //osetrenie
      pom := copy(zaznamy, Index, length(zaznamy) - Index); //zoberie zvysok za indexom
    setlength(zaznamy, Index - 1); //vymaze hackera
    for i := 0 to high(pom) do //znova priradi zvysok ktory bol za nim
    begin
      setlength(zaznamy, length(zaznamy) + 1);
      zaznamy[high(zaznamy)] := pom[i];
    end;
  end;
end;

procedure TZoznam.Zmen(Row, Col: integer; tab: TStringGrid);
var
  Index: integer;
begin
  if TryStrToInt(tab.Cells[1, Row], Index) then
  begin
    Index := NajdiID(Index); //najde ktoremu musi zmenit hodnotu
    case Col of //zmeni podla toho ktory stlpec sme menili
      2: zaznamy[Index].Meno := tab.Cells[Col, Row];
      3: zaznamy[Index].Priezvisko := tab.Cells[Col, Row];
      4: zaznamy[Index].Nick := tab.Cells[Col, Row];
      5: zaznamy[Index].Krajina := tab.Cells[Col, Row];
      6: zaznamy[Index].Uroven := tab.Cells[Col, Row];
      7: zaznamy[Index].Skupina := tab.Cells[Col, Row];
      8: zaznamy[Index].Skoda := StrToInt(tab.Cells[Col, Row]);
      9: zaznamy[Index].Chyteny := StrToInt(tab.Cells[Col, Row]);
    end;
  end;
end;

procedure TZoznam.Zobrazenie;
var
  Sub: TStream;
  i: integer;
begin
  if fileexists('nastavenie.ini') then //v pripade ak existuje
  begin
    Sub := TFileStream.Create('nastavenie.ini', fmOpenRead);
    //nacitame ktore stlpce maju byt zobrazene a ktore nie
    Sub.Position := 0;
    setlength(Nastavenie, 0);
    while Sub.Position < Sub.Size do
    begin
      setlength(Nastavenie, length(Nastavenie) + 1);
      Sub.Read(Nastavenie[high(Nastavenie)], sizeof(boolean));
    end;
    Sub.Destroy;
  end
  else //ak neexistuje subor tak vsetky ukaze
  begin
    setlength(nastavenie, 6);
    for i := 0 to high(nastavenie) do
      Nastavenie[i] := True;
  end;
end;

function TZoznam.NajdiID(Index: integer): integer;
var
  i: integer;
begin
  Result := -1; //ak nenajde
  for i := 0 to high(zaznamy) do
  begin
    if zaznamy[i].Id = Index then
    begin
      Result := i; //najde kde sa id nachadza (na ktorom mieste v poli)
      exit;
    end;
  end;
end;

function TZoznam.Radix(pole: TZaznam; moznost: integer): TPamat;
var
  i, j, k, n: integer;
  fpole, opacne: TPamat; //adresy
  ffpole: array[0..26] of TPamat; //adresy hackerov
  npole: array of string;
  cpole: array of integer;
  //pole ktore obsahuje dlzky slov, potom pomocou maxvalue vybere najvacsi
  ppole: array[0..26] of array of string;
  // 0-ka ak nema na I-tom mieste pismeno, 1..26 = a..z
begin
  setlength(npole, length(pole));
  setlength(fpole, length(pole));
  case abs(moznost) of //podla coho budeme sortovat
    1:
      for i := 0 to high(pole) do
      begin
        npole[i] := pole[i].Meno;
        fpole[i] := @pole[i];
      end;
    2:
      for i := 0 to high(pole) do
      begin
        npole[i] := pole[i].Priezvisko;
        fpole[i] := @pole[i];
      end;
    3:
      for i := 0 to high(pole) do
      begin
        npole[i] := pole[i].Nick;
        fpole[i] := @pole[i];
      end;
    4:
      for i := 0 to high(pole) do
      begin
        npole[i] := pole[i].Krajina;
        fpole[i] := @pole[i];
      end;
    5:
      for i := 0 to high(pole) do
      begin
        npole[i] := pole[i].Skupina;
        fpole[i] := @pole[i];
      end;
    0: exit;
  end;
  //najdne najdlhsie slovo
  setlength(cpole, length(npole));
  for i := 0 to high(npole) do
    cpole[i] := length(npole[i]);
  n := MaxValue(cpole);
  for i := n downto 1 do
  begin
    for j := 0 to high(npole) do
    begin
      if (length(npole[j]) >= i) then
      begin
        if (Ord(npole[j][i]) - 64 < 27) and (Ord(npole[j][i]) - 64 > 0) then
          //ak sa nachadza v A-Z
        begin
          setlength(ppole[Ord(npole[j][i]) - 64],
            length(ppole[Ord(npole[j][i]) - 64]) + 1);
          setlength(ffpole[Ord(npole[j][i]) - 64],
            length(ffpole[Ord(npole[j][i]) - 64]) + 1);
          ppole[Ord(npole[j][i]) - 64][high(ppole[Ord(npole[j][i]) - 64])] := npole[j];
          ffpole[Ord(npole[j][i]) - 64][high(ffpole[Ord(npole[j][i]) - 64])] := fpole[j];
        end
        else if (Ord(npole[j][i]) - 96 < 27) and (Ord(npole[j][i]) - 96 > 0) then
          //ak sa nachadza v a-z
        begin
          setlength(ppole[Ord(npole[j][i]) - 96],
            length(ppole[Ord(npole[j][i]) - 96]) + 1);
          setlength(ffpole[Ord(npole[j][i]) - 96],
            length(ffpole[Ord(npole[j][i]) - 96]) + 1);
          ppole[Ord(npole[j][i]) - 96][high(ppole[Ord(npole[j][i]) - 96])] := npole[j];
          ffpole[Ord(npole[j][i]) - 96][high(ffpole[Ord(npole[j][i]) - 96])] := fpole[j];
        end
        else
        begin
          setlength(ppole[0], length(ppole[0]) + 1);
          setlength(ffpole[0], length(ffpole[0]) + 1);
          ppole[0][high(ppole[0])] := npole[j];
          ffpole[0][high(ffpole[0])] := fpole[j];
        end;
      end
      else
      begin
        setlength(ppole[0], length(ppole[0]) + 1);
        setlength(ffpole[0], length(ffpole[0]) + 1);
        ppole[0][high(ppole[0])] := npole[j];
        ffpole[0][high(ffpole[0])] := fpole[j];
      end;
    end;
    setlength(npole, 0);
    //zmazeme npole, aby sme mohli dohno dat utriedene slova podla I-teho pismena
    setlength(fpole, 0);
    for k := 0 to 26 do
    begin
      for j := 0 to high(ppole[k]) do
      begin
        setlength(npole, length(npole) + 1);
        setlength(fpole, length(fpole) + 1);
        npole[high(npole)] := ppole[k][j];
        fpole[high(fpole)] := ffpole[k][j];
      end;
      setlength(ppole[k], 0);
      //zmazene ppole aby sme mohli znova vediet utriedovat ,ci na konci uz ho nebudeme potrebovat
      setlength(ffpole[k], 0);
    end;
  end;
  if moznost < 0 then //ci ASC ,alebo DESC
  begin
    setlength(opacne, length(fpole));
    for i := 0 to high(fpole) do
      opacne[i] := fpole[high(fpole) - i];
    Result := opacne;
  end
  else
    Result := fpole;
end;

function TZoznam.RadixNum(pole: TZaznam; moznost: integer): TPamat;
var
  i, j, k, n, overenie: integer;
  fpole, opacne: TPamat;
  ffpole: array[0..9] of TPamat;
  cpole, npole: array of integer;
  ppole: array[0..9] of array of integer;

  function pozcis(g, Num: integer): integer; //ktora pozicia cisla
  begin
    if g = 1 then
      Result := Num mod 10
    else
      Result := pozcis(g - 1, Num div 10);
  end;

begin
  setlength(npole, length(pole));
  setlength(fpole, length(pole));
  case abs(moznost) of  //podla ktoreho sortime
    1:
      for i := 0 to high(pole) do
      begin
        npole[i] := pole[i].Id;
        fpole[i] := @pole[i];
      end;
    2:
      for i := 0 to high(pole) do
      begin
        npole[i] := pole[i].Skoda;
        fpole[i] := @pole[i];
      end;
    3:
      for i := 0 to high(pole) do
      begin
        npole[i] := pole[i].Chyteny;
        fpole[i] := @pole[i];
      end;
    0: exit;
  end;
  setlength(cpole, length(npole));
  for i := 0 to high(cpole) do
    cpole[i] := length(IntToStr(npole[i]));
  n := MaxValue(cpole);
  for i := 1 to n do
  begin
    for j := 0 to high(npole) do
    begin
      overenie := pozcis(i, npole[j]);
      if (overenie <= 9) and (overenie >= 0) then
      begin
        setlength(ppole[overenie], length(ppole[overenie]) + 1);
        setlength(ffpole[overenie], length(ffpole[overenie]) + 1);
        ppole[overenie][high(ppole[overenie])] := npole[j];
        ffpole[overenie][high(ffpole[overenie])] := fpole[j];
      end;
    end;
    setlength(npole, 0);
    setlength(fpole, 0);
    for k := 0 to 9 do
    begin
      for j := 0 to high(ppole[k]) do
      begin
        setlength(npole, length(npole) + 1);
        setlength(fpole, length(fpole) + 1);
        npole[high(npole)] := ppole[k][j];
        fpole[high(fpole)] := ffpole[k][j];
      end;
      setlength(ppole[k], 0);
      setlength(ffpole[k], 0);
    end;
  end;
  if moznost < 0 then //ASC, DESC
  begin
    setlength(opacne, length(fpole));
    for i := 0 to high(fpole) do
      opacne[i] := fpole[high(fpole) - i];
    Result := opacne;
  end
  else
    Result := fpole;
end;

function TZoznam.Hladaj(co: string; vcom: TZaznam; ktore: integer): TZaznam;
var
  vysledne: TZaznam;
  i, poz, dlzka: integer;
begin
  for i := 0 to high(vcom) do
  begin
    poz := 1;
    dlzka := 0;
    case ktore of
      0:
      begin
        repeat
          if (co[dlzka + 1] = (AnsiLowerCase(vcom[i].Meno[poz]))) or (co[dlzka + 1] = '*') then
          begin
            dlzka := dlzka + 1;
            if length(co) = dlzka then
            begin
              setlength(vysledne, length(vysledne) + 1);
              vysledne[high(vysledne)] := vcom[i];
              poz := length(vcom[i].Meno);
            end;
          end
          else
            dlzka := 0;
          poz := poz + 1;
        until poz > length(vcom[i].Meno);
      end;
      1:
      begin
        repeat
          if (co[dlzka + 1] = (AnsiLowerCase(vcom[i].Priezvisko[poz]))) or (co[dlzka + 1] = '*') then
          begin
            dlzka := dlzka + 1;
            if length(co) = dlzka then
            begin
              setlength(vysledne, length(vysledne) + 1);
              vysledne[high(vysledne)] := vcom[i];
              poz := length(vcom[i].Priezvisko);
            end;
          end
          else
            dlzka := 0;
          poz := poz + 1;
        until poz > length(vcom[i].Priezvisko);
      end;
      2:
      begin
        repeat
          if (co[dlzka + 1] = (AnsiLowerCase(vcom[i].Nick[poz]))) or (co[dlzka + 1] = '*') then
          begin
            dlzka := dlzka + 1;
            if length(co) = dlzka then
            begin
              setlength(vysledne, length(vysledne) + 1);
              vysledne[high(vysledne)] := vcom[i];
              poz := length(vcom[i].Nick);
            end;
          end
          else
            dlzka := 0;
          poz := poz + 1;
        until poz > length(vcom[i].Nick);
      end;
      3:
      begin
        repeat
          if (co[dlzka + 1] = (AnsiLowerCase(vcom[i].Krajina[poz]))) or (co[dlzka + 1] = '*') then
          begin
            dlzka := dlzka + 1;
            if length(co) = dlzka then
            begin
              setlength(vysledne, length(vysledne) + 1);
              vysledne[high(vysledne)] := vcom[i];
              poz := length(vcom[i].Krajina);
            end;
          end
          else
            dlzka := 0;
          poz := poz + 1;
        until poz > length(vcom[i].Krajina);
      end;
      4:
      begin
        repeat
          if (co[dlzka + 1] = (AnsiLowerCase(vcom[i].Skupina[poz]))) or (co[dlzka + 1] = '*') then
          begin
            dlzka := dlzka + 1;
            if length(co) = dlzka then
            begin
              setlength(vysledne, length(vysledne) + 1);
              vysledne[high(vysledne)] := vcom[i];
              poz := length(vcom[i].Skupina);
            end;
          end
          else
            dlzka := 0;
          poz := poz + 1;
        until poz > length(vcom[i].Skupina);
      end;
    end;
  end;
  Result := vysledne;
end;

end.

