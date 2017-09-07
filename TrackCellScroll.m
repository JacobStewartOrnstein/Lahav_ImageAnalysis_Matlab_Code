function [xpu,ypu,org,fate,mitosis,daut,frames]=TrackCellScroll(di,mn,emn,st);


%di a string giving the file location of the stack of interest
%mn is the number of frames to track
%emn is an optional second channel to display


    k=0;
    stop=0;
    m=0; mk=0; org=0; mitosis=0; fate=0; daut=0;
    
    dis=strrep(di,'.tif','.mat');
    dis=dis([1:regexpi(dis,'w\d+_','start')-1,regexpi(dis,'w\d+_','end')+1:length(dis)]);
    
    if exist(dis,'file');
       load(dis); 
       k=size(xpu,1); m=length(mitosis); mk=m;
    end
    
    
    if nargin>2; 
        di2=di;
        t=regexpi(di,'w\d+_','start');
        t2=regexpi(di,'w\d+_','end');
        di2(t+1:t2-1)=num2str(emn);
    end
    
    
    if exist('st')
        cm=getcolormap('qual', 'Pastel2', size(st.cellx,1));
    end
    
    
    if length(mn)==1; mn=1:mn; end
    frames=mn;
    
    fi=figure('WindowScrollWheelFcn',@figScroll,'KeyPressFcn',@figKey,'WindowButtonDownFcn', @figBut,'WindowButtonMotionFcn',@figMot);
    ax=axes;
        
    k=k+1;
        f=mn(1);
        fate(k)=0; 
        xpu(k,1:length(mn))=0;
        ypu(k,1:length(mn))=0;
        tim(k,1:length(mn))=0;
        smk=0;

    
    im=imread(di,f); s=size(im); im=imresize(im,0.5);
    imageset=zeros(s(1)/2,s(2)/2,length(frames));
    if nargin>2; imageset2=zeros(s(1)/2,s(2)/2,length(frames)); end
    for i=1:length(frames);
        imageset(:,:,i)=imresize(imread(di,frames(i)),0.5);
        if nargin>2
            imageset2(:,:,i)=imtophat(imresize(medfilt2(imread(di2,frames(i)),[3,3]),0.5),strel('disk',50));
        end
    end
    
    re_eval(f)
    
    function FateEval(r,x,y)
            if r==1;
                xpu(k,f-min(mn)+1)=x;
                ypu(k,f-min(mn)+1)=y;
                tim(k,f-min(mn)+1)=f;
                f=f+1;
            elseif r==3
                f=f-1;
                if f<min(mn); f=min(mn); end
            elseif r==100 %dead cell, type d
                f=1000;
                fate(k)=2;
            elseif r==111 %cell leaves field, type 0
                f=1000;   
                fate(k)=3;
            elseif r==109 %cell mitoses, type m 
                m=m+1;
                mitosis(m)=f-min(mn)+1;
                org(m)=k;
            elseif r==115
                stop=1;
            end
        if stop~=1 & f~=1000
            fate(k)=1;
        end


        
        if f<=max(mn) & stop==0
          

        else
            k=k+1;
            f=mn(1);
            fate(k)=0; 
            xpu(k,1:length(mn))=0;
            ypu(k,1:length(mn))=0;
            tim(k,1:length(mn))=0;

            if smk; mk=mk+1; end
            
            if k>1 & m>mk
               f=mitosis(mk+1)+min(mn)-1;
               smk=1;
               daut(mk+1)=k;
            else
               smk=0; 
            end
            
            
        end
        
        if stop==1;
            savef
            
        else
            re_eval(f)
        end
        
    end


    
    
   function figScroll(src,callbackdata)
      if callbackdata.VerticalScrollCount > 0 
          r=1;
          xy=get(get(src,'CurrentAxes'),'CurrentPoint');
          x=xy(1); y=xy(3);
      elseif callbackdata.VerticalScrollCount < 0 
          r=3;
          xy=get(get(src,'CurrentAxes'),'CurrentPoint');
          x=xy(1); y=xy(3);
      end
      FateEval(r,x,y)
   end % figScroll

    function figBut(src,callbackdata)
        if strcmp(get(src,'SelectionType'),'normal')
              r=1;
        else
              r=3;
        end
        xy=get(get(src,'CurrentAxes'),'CurrentPoint');
        x=xy(1); y=xy(3);
        FateEval(r,x,y)
    end
    
    function figKey(src,callbackdata)
        if callbackdata.Key=='d';
            r=100;
        elseif callbackdata.Key=='s';
            r=115;
        elseif callbackdata.Key=='o';
            r=111;
        elseif callbackdata.Key=='m';
            r=109;
        end
        xy=get(get(src,'CurrentAxes'),'CurrentPoint');
          x=xy(1); y=xy(3);
        FateEval(r,x,y)
    end
    
    
    function figMot(src,callbackdata)
    
    end

   function re_eval(f)
            %im=imread(di,f);
            
            im(:,:)=imageset(:,:,find(frames==f));
            imD=imresize(im,2);
            cla
            
            if exist('imageset2'); 
                im2(:,:)=imageset2(:,:,find(frames==f)); 
                im3=GreyPlusColor(im,im2); 
                imshow((im3));
            else
                imshow(autoscale(imD));
            end

            
            hold on
            for i=1:(k-1);
               scatter(xpu(i,f-min(mn)+1),ypu(i,f-min(mn)+1),'b'); 
            end
            if smk; 
                scatter(xpu(org(mk+1),f-min(mn)+1),ypu(org(mk+1),f-min(mn)+1),'m'); 
            end
            if f>min(mn); scatter(xpu(k,f-min(mn)),ypu(k,f-min(mn)),'r'); end
            if exist('st')
                scatter(2*st.cellx(:,f-min(mn)+1),2*st.celly(:,f-min(mn)+1),40,cm);
            end
            
            
            title(num2str(f))
            drawnow
   end % re_eval   

    function savef
        if f<5; 
            k=k-1; 
            xpu=xpu(1:k,:); 
            ypu=ypu(1:k,:);
        end
%         xpu=xpu*2; ypu=ypu*2;
        save(dis, 'xpu', 'ypu', 'org', 'mitosis', 'fate', 'di','daut','frames','tim')  
    end

end