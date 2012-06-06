unit databaza;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, zaznamy;

type
  { TDatabaza }

  TDatabaza = class
    S: string; //zaznamena ktore sme ovorili
    Subor: TStream;
    function Otvor(nazov: string): TZaznam;
    procedure Uloz(veci: TZaznam);
  end;

implementation

{ TDatabaza }

function TDatabaza.Otvor(nazov: string): TZaznam;
var
  Zaznam: TZaznam;
  i: Integer;
begin
  S := nazov;
  if fileexists(nazov + '.dat') then //pokial take existuje
  begin
    Subor := TFileStream.Create(nazov + '.dat', fmOpenRead);
    Subor.Position := 0; //nacita od zaciatku
    i := 0;
    try
      while Subor.Position < Subor.Size-1 do
      begin
        setlength(zaznam, length(zaznam) + 1);
        Subor.Read(Zaznam[i], SizeOf(Zaznam[i]));
        Inc(i);
      end;
    finally
      Subor.Free;
      Result := Zaznam;
    end;
  end
  else
  begin
    Subor := TFileStream.Create(nazov + '.dat', fmCreate);
    //ak nenaslo subor pri tvoreni tak ho vytvori
    Subor.Free;
    ShowMessage('Vytvorená nová evidencia: ' + nazov);
    Result := nil;
  end;
end;

procedure TDatabaza.Uloz(veci: TZaznam);
var
  i: Integer;
begin
  if fileexists(S + '.dat') then //osetrenie
  begin
    try
      Subor := TFileStream.Create(S + '.dat', fmOpenWrite);
      Subor.Size := 0; //rewrite
      Subor.Position := 0;
      for i := 0 to high(veci) do //zapise hackerov do suboru
        Subor.Write(veci[i], SizeOf(veci[i]));
    finally
      Subor.Free;
      ShowMessage('Uložené');
    end;
  end
  else
    ShowMessage('Chyba! Súbor neexistuje.');
end;

end.

