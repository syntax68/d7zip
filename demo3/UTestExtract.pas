unit UTestExtract;

interface

uses WinApi.Windows, System.Classes, System.SysUtils, System.IOUtils,
	Vcl.Forms, Vcl.StdCtrls, Vcl.Controls, Vcl.ExtCtrls, Vcl.Dialogs,
	sevenzip;

const
	MAX_ArchiveExtensionList = 51;	// = total-1
	ArchiveExtensionList: array [0..MAX_ArchiveExtensionList] of string = (
		// ZIP :
		'.zip', '.zipx', '.cbz', '.jar', '.xpi', '.kmz',
		'.docx', '.docm', '.dotx', '.dotm',
		'.xlsx', '.xlsm', '.xltx', '.xltm',
		'.pptx', '.pptm', '.potx', '.potm', '.ppsx', '.ppsm',
		'.epub',
		// 7z :
		'.7z', '.7zip', '.cb7', '.001',	// Comic Book (.cb7), split archive (.7z.001)
		'.lzma',
		// RAR :
		'.rar', '.cbr', '.rar5',			// .rar can be RAR or RAR5 format
		// Executables :
		'.exe',
		// Microsoft disk images:
		'.cab', '.wim', '.swm',
		// Disk Images:
		'.iso',
		// LZH :
		'.lzh', '.lha',
		// Containers :
		'.tar', '.cbt',						// Comic Book (Tar)
		// GZip :
		'.gz', '.gzip', '.tgz', '.tpz',
		// Others:
		'.z', '.taz', '.xar',
		'.zstd', '.arj',
		'.xz',
		'.bz2', '.bzip2', '.tbz2', '.tbz'
	);

	ArchiveValueList: array [0..MAX_ArchiveExtensionList] of integer = (
		1, 2, 1, 1, 1, 1,			// ZIP
		1, 1, 1, 1,					// word
		1, 1, 1, 1,					// excel
		1, 1, 1, 1, 1, 1,			// power point
		1,								// ePub
		10, 10, 10, 10,			// 7z
		11,							// lzma
		20, 20, 21,					// RAR
		30,							// exe
		31, 32, 32,					// Microsoft (cab, wim, swm)
		33,							// iso
		50, 50,						// LZH
		60, 60,						// containers
		70, 70, 70, 70,			// gz gzip tgz tpz
		80, 80, 81,					// z taz xar
		90, 91,						// zstd arj
		100,							// xz
		110, 110, 110, 110		// bz2 bzip2 tbz2 tbz
	);

type
  TFormExtract = class(TForm)
	 Panel1: TPanel;
	 Panel4: TPanel;
	 btAction: TButton;
	 btQuit: TButton;
	 Memo1: TMemo;
	 edTargetDir: TEdit;
	 lbSource: TLabel;
	 lbTarget: TLabel;
	 btSelect: TButton;
	 OpenDialog1: TOpenDialog;
    edFilename: TEdit;
	 procedure FormResize(Sender: TObject);
	 procedure btQuitClick(Sender: TObject);
	 procedure btSelectClick(Sender: TObject);
	 procedure btActionClick(Sender: TObject);
  private
	 procedure Decompress;
	 function GetArchiveType(const filename:string):integer;
	 function GetArchiveTypeRAR(const filename:string):integer;
	 function GetArchiveCFormat(const index:integer):TGUID;
  public
  end;

var
  FormExtract: TFormExtract;

implementation
{$R *.dfm}
{ -----------------------------------------------------------------------------
 02/09/2026
----------------------------------------------------------------------------- }
procedure TFormExtract.FormResize(Sender: TObject);
begin
	btSelect.Left:=self.width-109;
	edFilename.Width:=btSelect.left-edFilename.left-15;
	edTargetDir.Width:=edFilename.Width;
end;

{ -----------------------------------------------------------------------------
 08/06/2026
 Bouton Quitter
----------------------------------------------------------------------------- }
procedure TFormExtract.btQuitClick(Sender: TObject);
begin
	close;
end;

{ -----------------------------------------------------------------------------
 02/09/2026
----------------------------------------------------------------------------- }
procedure TFormExtract.btSelectClick(Sender: TObject);
begin
	OpenDialog1.InitialDir:=extractfilepath(edFilename.Text);
	OpenDialog1.Execute;
	edFilename.Text:=OpenDialog1.FileName;
	if length(ExtractFileDir(edFilename.Text))>0 then
		edTargetDir.Text:=ExtractFileDir(edFilename.Text);
end;

{ -----------------------------------------------------------------------------
 08/06/2026
----------------------------------------------------------------------------- }
procedure TFormExtract.btActionClick(Sender: TObject);
begin
	memo1.Lines.Clear;
	memo1.lines.Add('****************************************************************');
	memo1.lines.Add(' Source filename = '+edFilename.Text);
	memo1.lines.Add('****************************************************************');
	if FileExists(edFilename.Text)=false then
	begin
		memo1.lines.Add('-> error, this file does''nt exists');
		exit;
	end;
	btAction.Enabled:=false;
	btQuit.Enabled:=false;
	try
		Decompress;
	finally
		memo1.lines.Add('****************************************************************');
		memo1.lines.Add('** END **');
		memo1.lines.Add('****************************************************************');
		btAction.Enabled:=true;
		btQuit.Enabled:=true;
	end;
end;

{ -----------------------------------------------------------------------------
 02/09/2026
 Decompress an archive
 Manage multi-volume files just like single-volume files. The component handles everything.
 Simply create the I7zInArchive component, then open the first file.
 Important: only the **first file** should be specified in the `OpenFile` command.
----------------------------------------------------------------------------- }
procedure TFormExtract.Decompress;
var
	aID:TGUID;
	Arch: I7zInArchive;
	code:integer;
	j:cardinal;
	TargetDir:string;
begin
	Arch:=nil;
	TargetDir:=IncludeTrailingPathDelimiter(edTargetDir.Text);

	try
	try
		// To get the correct GUID, do this...
		code:=GetArchiveType(edFilename.Text);
		if code<0 then
		begin
			memo1.Lines.Add('--> information, unknown file format');
			exit;
		end;
//		memo1.Lines.Add('Format='+inttostr(code));
		aID:=GetArchiveCFormat(code);

		Memo1.Lines.Add('1 - CreateInArchive');
		Arch := CreateInArchive(aID);
		if not assigned(Arch) then
		begin
			Memo1.Lines.Add('--> error, Arch is not assigned');
			Exit;
		end;
		Memo1.Lines.Add('2 - CreateInArchive OK');

		Memo1.Lines.Add('3 - Open Archive');
		Arch.OpenFile(edFilename.Text);
		Memo1.Lines.Add('4 - Open Archive OK');
		Memo1.Lines.Add('The archive contains '+inttostr(Arch.NumberOfItems)+' items');

		// You have several functions at your disposal for extracting files.
		// - ExtractTo: extracts all files to the designated folder.
		// - ExtractItemToPath: extracts a file (via its index) to the designated folder.
		// - etc.

		// Extract all files:
//		Arch.ExtractTo(TargetDir);

		// Extract files one by one:
		j:=0;
		while j<Arch.NumberOfItems do
		begin
			if Arch.ItemIsFolder[j] then			// c'est un dossier
			begin
//				Memo1.Lines.Add('folder #'+inttostr(j)+' = '+Arch.ItemPath[j]);
				inc(j);
				continue;
			end;
			Memo1.Lines.Add('extracting file #'+inttostr(j)+' = '+Arch.ItemPath[j]);
			Arch.ExtractItemToPath(j, TargetDir, false);
			inc(j);
		end;

	except
		on E: Exception do
			Memo1.Lines.Add('--> error, ' + E.ClassName + ' : ' + E.Message);
	end;
	finally
		Memo1.Lines.Add('Result: '+Format('%d files extracted, %d files with errors, %d files deleted',
				[Arch.ExtractedFileCount, Arch.FailedFileCount, Arch.DeletedFileCount]));
		if Arch<>nil then
			Arch.Close;
	end;
end;

{ -----------------------------------------------------------------------------
 02/09/2026
 Returns a code based on the extension of a file passed as a parameter.
----------------------------------------------------------------------------- }
function TFormExtract.GetArchiveType(const filename:string):integer;
var
	i:integer;
	ext:string;
begin
	result:=-1;												// error
	ext:=AnsiLowerCase(ExtractFileExt(filename));
	for i:=0 to MAX_ArchiveExtensionList do
		begin
			if ArchiveExtensionList[i]=ext then
			begin
				result:=ArchiveValueList[i];
				break;
			end;
		end;
	// Additionnal test if RAR file:
	if result=20 then
		result:=GetArchiveTypeRAR(filename);
end;

{ -----------------------------------------------------------------------------
 02/09/2026
 Distinguishes between RAR version 5 files (returns code 21) and earlier
 versions (returns code 20).
----------------------------------------------------------------------------- }
function TFormExtract.GetArchiveTypeRAR(const filename:string):integer;
var
	FS:TFileStream;
	head:array[0..7] of byte;
	sig:array[0..7] of byte;
begin
	result:=20;												// RAR par défaut
	// RAR5 magic header:
	sig[0]:=$52;   sig[1]:=$61;   sig[2]:=$72;   sig[3]:=$21;
	sig[4]:=$1A;   sig[5]:=$07;   sig[6]:=$01;   sig[7]:=$00;
	FS:=TFileStream.create(filename,fmOpenRead);
	if assigned(FS)=false then exit;
	FS.Read(head,8);
	FS.Free;
	if compareMem(@head,@sig,8) then
		result:=21;											// RAR 5
end;

{ -----------------------------------------------------------------------------
 02/09/2026
 Returns the CLSID code used in the 7z.dll library.
----------------------------------------------------------------------------- }
function TFormExtract.GetArchiveCFormat(const index:integer):TGUID;
begin
	result:=CLSID_CFormatZip;
	case index of
		1:  result:=CLSID_CFormatZip;					// zip jar xpi cbz
		2:  result:=CLSID_CFormatZip;					// zipx
		10: result:=CLSID_CFormat7z;					// 7z cb7
		11: result:=CLSID_CFormatLzma;				// lzma
		20: result:=CLSID_CFormatRar;					// rar r00
		21: result:=CLSID_CFormatRar5;				// rar5
		30: result:=CLSID_CFormatPE;					// exe
		31: result:=CLSID_CFormatCab;					// cab
		32: result:=CLSID_CFormatWim;					// wim swm
		33: result:=CLSID_CFormatIso;					// iso
		50: result:=CLSID_CFormatLzh;					// lzh lha
		60: result:=CLSID_CFormatTar;					// tar
		70: result:=CLSID_CFormatGZip;				// gz gzip tgz tpz
		80: result:=CLSID_CFormatZ;					// z taz
		81: result:=CLSID_CFormatXar;					// xar
		90: result:=CLSID_CFormatZStd;				// zstd
		91: result:=CLSID_CFormatArj;					// arj
		100: result:=CLSID_CFormatXz;					// xz
		110: result:=CLSID_CFormatBZ2;				// bz2 bzip2 tbz2 tbz
	end;
end;



end.
