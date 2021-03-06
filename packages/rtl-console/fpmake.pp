{$ifndef ALLPACKAGES}
{$mode objfpc}{$H+}
program fpmake;

uses fpmkunit;
{$endif ALLPACKAGES}

procedure add_rtl_console(const ADirectory: string);

Const 
  // All Unices have full set of KVM+Crt in unix/ except QNX which is not
  // in workable state atm.
  UnixLikes = AllUnixOSes -[QNX];
 
  WinEventOSes = [win32,win64];
  KVMAll       = [emx,go32v2,MorphOS,netware,netwlibc,os2,win32,win64]+UnixLikes;
  
  // all full KVMers have crt too, except MorphOS
  CrtOSes      = KVMALL+[msdos,WatCom]-[MorphOS];
  KbdOSes      = KVMALL+[msdos];
  VideoOSes    = KVMALL;
  MouseOSes    = KVMALL;

// Amiga has a crt in its RTL dir, but it is commented in the makefile

Var
  P : TPackage;
  T : TTarget;

begin
  With Installer do
    begin
    P:=AddPackage('rtl-console');
    P.Directory:=ADirectory;
    P.Version:='2.7.1';
    P.Author := 'FPC core team, Pierre Mueller, Peter Vreman';
    P.License := 'LGPL with modification, ';
    P.HomepageURL := 'www.freepascal.org';
    P.OSes:=KVMALL+CrtOSes;
    P.Email := '';
    P.Description := 'Rtl-console, console abstraction';
    P.NeedLibC:= false;
    P.Dependencies.Add('rtl-extra'); // linux,android gpm.

    P.SourcePath.Add('src/inc');
    P.SourcePath.Add('src/$(OS)');
    P.SourcePath.Add('src/darwin',[iphonesim]);
    P.SourcePath.Add('src/unix',AllUnixOSes);
    P.SourcePath.Add('src/os2commn',[os2,emx]);
    P.SourcePath.Add('src/win',WinEventOSes);

    P.IncludePath.Add('src/inc');
    P.IncludePath.Add('src/unix',AllUnixOSes);
    P.IncludePath.Add('src/$(OS)');
    P.IncludePath.Add('src/darwin',[iphonesim]);

    T:=P.Targets.AddUnit('winevent.pp',WinEventOSes);

    T:=P.Targets.AddUnit('keyboard.pp',KbdOSes);
    with T.Dependencies do
      begin
        AddInclude('keybrdh.inc');
        AddInclude('keyboard.inc');
        AddInclude('keyscan.inc',AllUnixOSes);
        AddUnit   ('winevent',[win32,win64]);
        AddInclude('nwsys.inc',[netware]);
      end;

    T:=P.Targets.AddUnit('mouse.pp',MouseOSes);
    with T.Dependencies do
     begin
       AddInclude('mouseh.inc');
       AddInclude('mouse.inc');
       AddUnit   ('winevent',[win32,win64]);
     end;

    T:=P.Targets.AddUnit('video.pp',VideoOSes);
    with T.Dependencies do
     begin
       AddInclude('videoh.inc');
       AddInclude('video.inc');
       AddInclude('videodata.inc',[MorphOS]);
       AddInclude('convert.inc',AllUnixOSes);
       AddInclude('nwsys.inc',[netware]);
     end;

    T:=P.Targets.AddUnit('crt.pp',CrtOSes);
    with T.Dependencies do
     begin
       AddInclude('crth.inc');
       AddInclude('crt.inc');
       AddInclude('nwsys.inc',[netware]);
     end;

    T:=P.Targets.AddUnit('vesamode.pp',[go32v2]);
    with T.Dependencies do
     AddUnit('video');
  end
end;
 
{$ifndef ALLPACKAGES}
begin
  add_rtl_console('');
  Installer.Run;
end.
{$endif ALLPACKAGES}

