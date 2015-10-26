function ShowImage(color)
    if color==-0.5
        img = imread('color_cards\pure_black.png');
    else
        img = imread('color_cards\pure_white.png');
    end;
    
    Screensize=get(0,'Screensize');
    hFig = figure('Name','APP',...
    'Numbertitle','off',...
    'Position', [1 1 Screensize(3) Screensize(4)] ,...
    'WindowStyle','modal',...
    'Toolbar','none',...
    'Visible','on');
    drawnow; pause(0.1);
    jFig = get(handle(hFig), 'JavaFrame'); 
    jFig.setMaximized(true);
    fpos = get(hFig,'Position');
    axOffset = (fpos(3:4)-[size(img,2) size(img,1)])/2;
    ha = axes('Parent',hFig,'Units','pixels','Position',[axOffset size(img,2) size(img,1)]);
    imshow(img,'Parent',ha);pause(0.2);
    


