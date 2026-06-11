program demo2;
// RTTI directive to remove this reference from the final executable. This is to reduce the size of the executable:
//{$IFOPT D-}{$WEAKLINKRTTI ON}{$ENDIF}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}

// You can also add the following, again somewhere in your .dpr file:
{$SetPEFlags $0001} //IMAGE_FILE_RELOCS_STRIPPED}
// This will strip the relocation information which is not needed in a .exe. Don't add this to a DLL or package!

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Form1},
  sevenzip in '..\..\sevenzip.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
