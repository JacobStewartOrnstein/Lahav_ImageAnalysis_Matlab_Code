function [vs,lin]=AnalyzeCellTracks_LS(fi,w,s)
    
    %fi is a vector of cellstrings giving the location of the cell tracking
    %files
    %w is an integer which gives the channel on which to preform the
    %analysis
    %s is an optional vector of integers from 1:n with a length equal to the
    %number of elements in fi, this gives the groupings of cell tracks

    if iscell(fi);
        n=length(fi);
    else
        n=1;
    end
    
    if ~exist('s')
       s(1:n)=1; 
    end
    
    
    orgs=0; mitosiss=0; dauts=0;
    k=0; kr=0; tflag=0;
    for j=1:n
        
        if n>1
            fic=fi{j};
        else
            fic=fi;  
        end
        load(fic);  
        
        if ~exist('tim') | tflag==1; tflag=1; clear tim; for i=1:size(xpu,1); tim(i,:)=[1:size(xpu,2)]; end; end

        %find tif stack corresponding to traces
        t=regexpi(fic,'(_s\d+).mat','tokens'); t=t{1};
        fis=[fic(1:regexpi(fic,'_s\d+.mat','start')-1), '_w',num2str(w)  ,t{1},'.tif'];

        if sum(xpu(size(xpu,1),:)>0)<5
            xpu=xpu(1:(size(xpu,1)-1),:); 
            ypu=ypu(1:(size(ypu,1)-1),:);
        end
        
        
        for i=1:size(xpu,1);
        ss=0; kk=0;
            for jj=1:size(xpu,1);
                if ss>0 & kk<9 & sum(xpu(i,jj:size(xpu,2)))>0 & (isnan(xpu(i,jj)) | xpu(i,jj)==0)
                    xpu(i,jj)=lcxpu;
                    ypu(i,jj)=lcypu;
                end
                
                if xpu(i,jj)>0
                    ss=1;
                    kk=0;
                    lcxpu=xpu(i,jj); lcypu=ypu(i,jj);
                else
                    kk=kk+1;
                end
            end
        end
        
        %loop through the cell traces and compute the traces as required
%         for i=1:size(xpu,1);
%             a=find(xpu(i,:)>0);
%             [val,med]=TraceToXFP_stack(fis,xpu(i,:),ypu(i,:),1,tim(i,:));
%             %store each trace in the vs array
%             vs(k+i,1:max(a))=val;
%             type(i+k)=s(j);
%         end
        [val,med]=MultTraceToXFP_stack_LS(fis,xpu,ypu,1,max(tim));
        vs(k+1:k+size(val,1),1:size(val,2))=val;
        type(k+1:k+size(val,1))=s(j);
        
        if daut~=0
            %make sure daut, org, and mitosis all line up properly
            m=min([length(daut),length(org),length(mitosis)]);
            daut=daut(1:m); org=org(1:m); mitosis=mitosis(1:m);

            %add pre-mitosis data to each daugther cell
            for i=1:length(daut);
               vs(k+daut(i),1:mitosis(i))=vs(k+org(i),1:mitosis(i));
            end

            %store orgin, mitosis, and daut data
            orgs(kr+1:kr+length(org))=org+k;
            mitosiss(kr+1:kr+length(mitosis))=mitosis;
            dauts(kr+1:kr+length(daut))=daut+k;
        end
        
        %save fate information
        fates(k+1:k+size(xpu,1))=fate(1:size(xpu,1));
        
        %update number of cells
        k=k+size(xpu,1);

        
        %check for empty rows
        if sum(xpu(size(xpu,1),:)~=0)<5; k=k-1; end
        
        %update number of division events
        kr=kr+length(org);
        
        %update number of frames
        nf=size(xpu,2);
        
        clear tim
    end
    
    %load file describing acquisition
    mdl=[fic(1:regexpi(fic,'_s\d+.mat','start')-1), '.mat'];
    load(mdl);
    lin.MD=MD;
        
    lin.vs=vs;
    lin.nc=k;
    lin.nf=nf;
    lin.org=orgs;
    lin.mitosis=mitosiss;
    lin.daut=dauts;
    lin.type=type;
    lin.fate=fates;

    
    try
    %run ploting function
        plotCellTracks(lin)
    catch
        
    end
end
