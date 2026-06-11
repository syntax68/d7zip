unit Unit1;

interface

uses WinApi.Windows, System.Classes, System.SysUtils, System.IOUtils,
	Vcl.Forms, Vcl.StdCtrls, Vcl.Controls, Vcl.ExtCtrls, sevenzip;

const
	TextCompressMethod: array[0..5] of string=('deflate','deflate64','PPMd','LZMA','LZMA2','BZip2');

type
  TForm1 = class(TForm)
	 Panel1: TPanel;
	 Panel2: TPanel;
	 cbDeflate: TCheckBox;
	 cbDeflate64: TCheckBox;
	 cbLZMA: TCheckBox;
	 cbLZMA2: TCheckBox;
	 cbPPMd: TCheckBox;
	 cbBZip2: TCheckBox;
	 Panel3: TPanel;
	 cbFast: TCheckBox;
	 cbMax: TCheckBox;
	 cbNormal: TCheckBox;
	 cbUltra: TCheckBox;
	 Panel4: TPanel;
	 btAction: TButton;
	 btQuit: TButton;
	 Memo1: TMemo;
	 cbZip: TCheckBox;
	 cb7z: TCheckBox;
	 edNewName: TEdit;
	 lbSource: TLabel;
	 lbTarget: TLabel;
	 Label1: TLabel;
	 cbSolid: TCheckBox;
	 btStop: TButton;
	 Label2: TLabel;
	 edFilename: TEdit;
	 procedure FormCreate(Sender: TObject);
	 procedure btQuitClick(Sender: TObject);
	 procedure btStopClick(Sender: TObject);
	 procedure btActionClick(Sender: TObject);
  private
	 selcompr:integer;		// 0=zip; 1=7z
	 selmethod:integer;		// 0=deflate, 1=deflate64, 2=PPMd, 3=LZMA, 4=LZMA2, 5=BZip2
	 sellevel:integer;		// 3=fast, 5=normal, 7=max, 9=ultra
	 running:boolean;
	 procedure CheckLevel(const method:integer);
	 procedure CheckCompress(const level,method:integer);
	 function CheckCb(const cb:TCheckBox; const value:integer):integer;
	 procedure compressZip(const level,method:integer);
	 procedure compress7Z(const level,method:integer);
  public
  end;

	function CallBack_ZipProgressZip(sender:Pointer; total:boolean; value:int64):HRESULT; stdcall;

var
  Form1: TForm1;

implementation
{$R *.dfm}
{ -----------------------------------------------------------------------------
 08/06/2026
----------------------------------------------------------------------------- }
function CallBack_ZipProgressZip(sender:Pointer; total:boolean; value:int64):HRESULT; stdcall;
begin
	if Form1.running then
		Result:=S_OK										// PROCESS_CONTINUE
	else
		result:=E_ABORT;									// PROGRESS_CANCEL
	Application.ProcessMessages;
end;

{ -----------------------------------------------------------------------------
 08/06/2026
----------------------------------------------------------------------------- }
procedure TForm1.FormCreate(Sender: TObject);
begin
	running:=false;
	btStop.Visible:=false;
	label2.Caption:='(1) Zip only'+#13+'(2) 7z only';
	memo1.Lines.Clear;
	memo1.Lines.add('Enter a filename in "Source filename".');
	memo1.Lines.add('Enter a target root filename in "Target root filename".');
	memo1.Lines.add('The compressed files will be created by appending this root filename to the selected compression method and level. They will be placed in the same folder as the source file.');
end;

{ -----------------------------------------------------------------------------
 08/06/2026
----------------------------------------------------------------------------- }
procedure TForm1.btQuitClick(Sender: TObject);
begin
	close;
end;

{ -----------------------------------------------------------------------------
 25/05/2026
----------------------------------------------------------------------------- }
procedure TForm1.btStopClick(Sender: TObject);
begin
	running:=false;
	memo1.lines.Add('----------------------------------------------------------------');
	memo1.lines.Add('-- Operation cancelled! --');
	memo1.lines.Add('----------------------------------------------------------------');
	application.ProcessMessages;
end;

{ -----------------------------------------------------------------------------
 08/06/2026
 Action button
 0=deflate, 1=deflate64, 2=PPMd, 3=LZMA, 4=LZMA2, 5=BZip2
----------------------------------------------------------------------------- }
procedure TForm1.btActionClick(Sender: TObject);
begin
	if running then
		exit;
	memo1.Lines.Clear;
	memo1.lines.Add('****************************************************************');
	memo1.lines.Add('source filename = '+edFilename.Text);
	memo1.lines.Add('****************************************************************');
	if FileExists(edFilename.Text)=false then
	begin
		memo1.lines.Add('-> error, this file does''nt exists');
		exit;
	end;
	running:=true;
	btStop.Visible:=true;
	btAction.Enabled:=false;
	btQuit.Enabled:=false;
	try
		CheckLevel( CheckCb(cbDeflate,   0));
		CheckLevel( CheckCb(cbDeflate64, 1));
		CheckLevel( CheckCb(cbPPMd,      2));
		CheckLevel( CheckCb(cbLZMA,      3));
		CheckLevel( CheckCb(cbLZMA2,     4));
		CheckLevel( CheckCb(cbBZip2,     5));
	finally
		memo1.lines.Add('****************************************************************');
		memo1.lines.Add('** END **');
		memo1.lines.Add('****************************************************************');
		running:=false;
		btStop.Visible:=false;
		btAction.Enabled:=true;
		btQuit.Enabled:=true;
	end;
end;

{ -----------------------------------------------------------------------------
 08/06/2026
 Compression Level
----------------------------------------------------------------------------- }
procedure TForm1.CheckLevel(const method:integer);
var level:integer;
begin
	if method<0 then exit;
	if running=false then exit;
	CheckCompress( CheckCb(cbFast,   3), method);
	if running=false then exit;
	CheckCompress( CheckCb(cbNormal, 5), method);
	if running=false then exit;
	CheckCompress( CheckCb(cbMax,    7), method);
	if running=false then exit;
	CheckCompress( CheckCb(cbUltra,  9), method);
end;

{ -----------------------------------------------------------------------------
 08/06/2026
 Zip and/or 7z
----------------------------------------------------------------------------- }
procedure TForm1.CheckCompress(const level,method:integer);
begin
	application.ProcessMessages;
	if (level<0) or (method<0) then exit;
	if cbZip.checked then compressZip(level,method);
	if running=false then exit;
	if cb7Z.checked then  compress7Z(level,method);
	if running=false then exit;
end;

{ -----------------------------------------------------------------------------
 08/06/2026
 Tests a checkbox and returns the indicated value if checked.
----------------------------------------------------------------------------- }
function TForm1.CheckCb(const cb:TCheckBox; const value:integer):integer;
begin
	if cb.Checked then
		result:=value
	else
		result:=-1;
end;

{ -----------------------------------------------------------------------------
 08/06/2026
 Zip format
----------------------------------------------------------------------------- }
procedure TForm1.compressZip(const level,method:integer);
var
	Arch:I7zOutArchive;
	dir,filename,st:string;
	t:cardinal;
begin
	memo1.Lines.Add('');
	if (method>=2) and (method<=4) then				// no PPMd, LZMA, LZMA2 in ZIP File
	begin
		memo1.lines.Add('-- CompressZip (begin) ------------------------------------------');
		memo1.lines.Add('format = Zip - method = '+inttostr(method)+' ('+TextCompressMethod[method]+') - level='+inttostr(level));
		memo1.lines.Add('--> this method is not allowed for ZIP files');
		memo1.lines.Add('-- CompressZip (end) --------------------------------------------');
		exit;
	end;
	try
	try
		memo1.lines.Add('-- CompressZip (begin) ------------------------------------------');
		memo1.lines.Add('format = Zip - method = '+inttostr(method)+' ('+TextCompressMethod[method]+') - level='+inttostr(level));
		dir:=IncludeTrailingPathDelimiter(ExtractFileDir(edFilename.Text));
		filename:=ExtractFilename(edFilename.Text);

		// Create archive:
		Arch:=CreateOutArchive(CLSID_CFormatZip);
		Arch.SetProgressCallback(nil,CallBack_ZipProgressZip);
		case method of
			0: begin											// deflate
//				SetCompressionMethod(Arch,mzDeflate); // use this or the following line...
				SetStringProperty(arch,'M', 'DEFLATE');
//				SetCompressionLevel(Arch,cardinal(level)); // or or use the following "case" for more precision.
				case level of
//					3 : begin SetCardinalProperty(Arch, 'FB', 6);  SetCardinalProperty(Arch, 'PASS',1); end;
					3 : SetCompressionLevel(Arch,cardinal(3));  // faster than the above line
					5 : begin SetCardinalProperty(Arch, 'FB', 8); SetCardinalProperty(Arch, 'PASS',1); end;
					7 : begin SetCardinalProperty(Arch, 'FB', 32); SetCardinalProperty(Arch, 'PASS',1); end;
					9 : begin SetCardinalProperty(Arch, 'FB', 64); SetCardinalProperty(Arch, 'PASS',2); end;
				end;
			end;
			1: begin											// deflate64
//				SetCompressionMethod(Arch,mzDeflate64);
				SetStringProperty(arch,'M', 'DEFLATE64');
//				SetCompressionLevel(Arch,cardinal(level));
				case level of
//					3 : begin SetCardinalProperty(Arch, 'FB', 4); SetCardinalProperty(Arch, 'PASS',1); end;
					3 : SetCompressionLevel(Arch,cardinal(3));
					5 : begin SetCardinalProperty(Arch, 'FB', 8); SetCardinalProperty(Arch, 'PASS',1); end;
					7 : begin SetCardinalProperty(Arch, 'FB', 32); SetCardinalProperty(Arch, 'PASS',1); end;
					9 : begin SetCardinalProperty(Arch, 'FB', 64); SetCardinalProperty(Arch, 'PASS',2); end;
				end;
			end;
			5: begin											// BZip2
//				SetCompressionMethod(Arch,mzBZip2);
				SetStringProperty(arch,'M', 'BZIP2');
//				SetCompressionLevel(Arch,cardinal(level));
				case level of
					3 : begin SetStringProperty(Arch, 'D', '100k'); SetCardinalProperty(Arch, 'PASS',1); end;
					5 : begin SetStringProperty(Arch, 'D', '500k'); SetCardinalProperty(Arch, 'PASS',1); end;
					7 : begin SetStringProperty(Arch, 'D', '700k'); SetCardinalProperty(Arch, 'PASS',1); end;
					9 : begin SetStringProperty(Arch, 'D', '900k'); SetCardinalProperty(Arch, 'PASS',2); end;
				end;
			end;
		end;
		application.ProcessMessages;
		Arch.AddFile(dir+filename,filename);		// no path
		st:=dir+edNewName.text+TextCompressMethod[method]+'_'+inttostr(level)+'.zip';
		t:=gettickcount;
		Arch.SaveToFile(st);
		t:=gettickcount-t;
		memo1.lines.Add('target filename = '+st);
	except
		memo1.lines.Add('--> error, CompressZip');
	end;
	finally
		Arch.ClearBatch;								// Is it useful?
		memo1.lines.Add('duration = '+inttostr(t));
		memo1.Lines.Add('size = '+inttostr(TFile.GetSize(st))+' - '+floattostr(TFile.GetSize(st)/1024)+' Kb');
		memo1.lines.Add('-- CompressZip (end) --------------------------------------------');
	end;
end;

{ -----------------------------------------------------------------------------
 08/06/2026
 7-zip format
----------------------------------------------------------------------------- }
procedure TForm1.compress7Z(const level,method:integer);
var
	Arch:I7zOutArchive;
	dir,filename,st:string;
	t:cardinal;
begin
	memo1.Lines.Add('');
	try
	try
		memo1.lines.Add('-- Compress7z (begin) ------------------------------------------');
		memo1.lines.Add('format = 7z - method = '+inttostr(method)+' ('+TextCompressMethod[method]+') - level='+inttostr(level));
		dir:=IncludeTrailingPathDelimiter(ExtractFileDir(edFilename.Text));
		filename:=ExtractFilename(edFilename.Text);

		// Create archive:
		Arch:=CreateOutArchive(CLSID_CFormat7z);
		Arch.SetProgressCallback(nil,CallBack_ZipProgressZip);
		case method of
			0: begin											// deflate
				SevenZipSetCompressionMethod(Arch,m7Deflate);
//				SetCompressionLevel(Arch,cardinal(level)); // or or use the following "case" for more precision.
				case level of
//					3 : begin SetCardinalProperty(Arch, 'FB', 6);  SetCardinalProperty(Arch, 'PASS',1); end;
					3 : SetCompressionLevel(Arch,cardinal(3));   // faster than the above line
					5 : begin SetCardinalProperty(Arch, 'FB', 8); SetCardinalProperty(Arch, 'PASS',1); end;
					7 : begin SetCardinalProperty(Arch, 'FB', 32); SetCardinalProperty(Arch, 'PASS',1); end;
					9 : begin SetCardinalProperty(Arch, 'FB', 64); SetCardinalProperty(Arch, 'PASS',2); end;
				end;
			end;
			1: begin											// deflate64
				SevenZipSetCompressionMethod(Arch,m7Deflate64);
//				SetCompressionLevel(Arch,cardinal(level));
				case level of
//					3 : begin SetCardinalProperty(Arch, 'FB', 6);  SetCardinalProperty(Arch, 'PASS',1); end;
					3 : SetCompressionLevel(Arch,cardinal(3));
					5 : begin SetCardinalProperty(Arch, 'FB', 8); SetCardinalProperty(Arch, 'PASS',1); end;
					7 : begin SetCardinalProperty(Arch, 'FB', 32); SetCardinalProperty(Arch, 'PASS',1); end;
					9 : begin SetCardinalProperty(Arch, 'FB', 64); SetCardinalProperty(Arch, 'PASS',2); end;
				end;
			end;
			2: begin											// PPMd
				SevenZipSetCompressionMethod(Arch,m7PPmd);
//				SetCompressionLevel(Arch,cardinal(level));
				// MEM=32 (in Mb) is the maximum supported by sevenzip.pas
				case level of
					3 : begin SetCardinalProperty(Arch, 'MEM',32); SetCardinalProperty(Arch, 'O',4);  end;
					5 : begin SetCardinalProperty(Arch, 'MEM',32); SetCardinalProperty(Arch, 'O',6);  end;
					7 : begin SetCardinalProperty(Arch, 'MEM',32); SetCardinalProperty(Arch, 'O',8);  end;
					9 : begin SetCardinalProperty(Arch, 'MEM',32); SetCardinalProperty(Arch, 'O',14); end;
				end;
			end;
			3,4: begin											// LZMA / LZMA2
				SevenZipSetCompressionMethod(Arch,m7LZMA);
//				SetCompressionLevel(Arch,cardinal(level));
				case level of
					3 : begin
						SetStringProperty(Arch, 'D', '1m');			SetCardinalProperty(Arch, 'FB', 32);
						SetStringProperty(Arch, 'MF', 'HC4');		SetCardinalProperty(Arch, 'MC',16);
					end;
					5 : begin
						SetStringProperty(Arch, 'D', '16m');		SetCardinalProperty(Arch, 'FB', 32);
						SetStringProperty(Arch, 'MF', 'BT4');		SetCardinalProperty(Arch, 'MC',32);
					end;
					7 : begin
						SetStringProperty(Arch, 'D', '32m');		SetCardinalProperty(Arch, 'FB', 64);
						SetStringProperty(Arch, 'MF', 'BT4');		SetCardinalProperty(Arch, 'MC',48);
					end;
					9 : begin
						SetStringProperty(Arch, 'D', '64m');		SetCardinalProperty(Arch, 'FB', 64);
						SetStringProperty(Arch, 'MF', 'BT4');		SetCardinalProperty(Arch, 'MC',48);
					end;
				end;
			end;
			5: begin											// BZip2
				SevenZipSetCompressionMethod(Arch,m7BZip2);
//				SetCompressionLevel(Arch,cardinal(level));
				case level of
					3 : begin SetStringProperty(Arch, 'D', '100k'); SetCardinalProperty(Arch, 'PASS',1); end;
					5 : begin SetStringProperty(Arch, 'D', '500k'); SetCardinalProperty(Arch, 'PASS',1); end;
					7 : begin SetStringProperty(Arch, 'D', '700k'); SetCardinalProperty(Arch, 'PASS',1); end;
					9 : begin SetStringProperty(Arch, 'D', '900k'); SetCardinalProperty(Arch, 'PASS',2); end;
				end;
			end;
		end;
		if cbSolid.Checked then
		begin
			SetBooleanProperty(Arch, 'S',True);
			memo1.lines.Add('Solid flag activated');
		end;
		application.ProcessMessages;
		Arch.AddFile(dir+filename,filename);		// no path
		st:=dir+edNewName.text+TextCompressMethod[method]+'_'+inttostr(level)+'.7z';
		t:=gettickcount;
		Arch.SaveToFile(st);
		t:=gettickcount-t;
		memo1.lines.Add('target filename = '+st);
	except
		memo1.lines.Add('--> error, Compress7z');
	end;
	finally
		Arch.ClearBatch;								// Is it useful?
		memo1.lines.Add('duration = '+inttostr(t));
		memo1.Lines.Add('size = '+inttostr(TFile.GetSize(st))+' - '+floattostr(TFile.GetSize(st)/1024)+' Kb');
		memo1.lines.Add('-- Compress7z (end) --------------------------------------------');
	end;
end;

end.
