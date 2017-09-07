function md=ArchiveExp(path, st, expname, samplename, ArcPath, CellLine, Treatment, username, platetype, media, numberofcells, readoutequip, comments)

    %path: (char) directory where tiff image series is stored (NOTE before running
    %this script clean the thumbs from the directory (use: CleanThumbs
    %script)
    %st: (cellstring) describing the initial file name (everything before
    %the 'w'), or a set of initial file names to be concatinated
    %expname: (char) what you want to call the experiment (no spaces by
    %convention)
    %sample name: (char) the description of the sample
    %archive path:  (char) the directory in which the assembled data will be stored
    %CellLine: (vector of cellstrings)description of the cell line used at
    %each position
    %Treatment: (vector of cellstrings) description of what was done to the
    %sample in each position
    %Microscope: (char) which microscope was the acquisiton on
    %lens: (char) lens used
    %comments: (char) description of the experiment

    numpost=0; TPt=0;
    
    if nargin<1;
        path=[];
    end
    if nargin<2;
        st=[];
    end
    if nargin<3;
        expname=[];
    end
    if nargin<4;
        samplename=[];
    end        
    if nargin<5;
        ArcPath=[];
    end
    if nargin<6;
        CellLine=[];
    end
    if nargin<7;
        Treatment=[];
    end
    if nargin<8;
        username=[];
    end
    if nargin<9;
        platetype=[];
    end
    if nargin<10;
        media=[];
    end
    if nargin<10;
        numberofcells=[];
    end
    if nargin<10;
        readoutequip=[];
    end
    if nargin<10;
        comments=[];
    end
    
    [Selection,ok] = listdlg('name','Select Datatype','SelectionMode','single','listsize',[200,100],'liststring',{'TimeLapseMicroscopy','StainingImages','qPCR'});
    if ok~=1; [Selection,ok] = listdlg('name','Select Datatype','SelectionMode','single','listsize',[200,100],'liststring',{'TimeLapseMicroscopy','StainingImages','qPCR'}); end
    
    if isempty(path);
        path = uigetdir('\\research.files.med.harvard.edu\lahav lab','select_data_dir');
    end
    if isempty(ArcPath); 
        ArcPath = uigetdir('\\research.files.med.harvard.edu\lahav lab\Microscopy_Database','select_archive_dir');
    end    
    if isempty(st)
       st=inputdlg('what what are the files titled'); 
    end
    if isempty(expname)
       st=inputdlg('Experiment Folder Title'); 
    end
    if isempty(samplename)
       st=inputdlg('Experiment Title'); 
    end

    
    