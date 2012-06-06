unit about;

{$mode objfpc}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls;

type

  { Toprog }

  Toprog = class(TForm)
    Label1: TLabel;
    StaticText1: TStaticText;
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  oprog: Toprog;

implementation

initialization
  {$I about.lrs}

end.

