%% BLcorr_bfit1.m                                  by:  Edward T Peltzer, MBARI Science
%                                                  revised:  2022 June 29.
%
%%                                                 by:  William J Kirkwood, MBARI Engineering
%                     revised and tested using 2022b with OSX:  2022 November 14.
%
%%                          by:  Olivia O'Laughlin, MBARI Intern - UC Berkeley Junior
%                        tested using 2021b with Windows 10:  2022 July 5 to August 8.
%
%%  NOTE: point selection using Matlab 2022a may not show red circles until entering return
%
% M-file to load 1 Laser Raman Spectra data file and correct for fluorescence in the
%   baseline by using the "Bfit" function to detect and subtract the
%   "broad" Raman shift fluorescence bands.
%
%% Bfit originally a function written by Mirko Hrovat 08/01/2009; (c) 2009 Mirtech, Inc.
%% located at https://www.mathworks.com/matlabcentral/fileexchange/24916-baseline-fit?s_tid=srchtitle
%
% Data file must be in ascii format only with extn = asc.
%
% User can select standard (200-4500 cm-1) or custom Raman shift range.
%
% Figure format = PORTRAIT

%% Clear environment space & set-up plotting window

    clearvars; close all

    scrn = get(groot,'ScreenSize');     % 'Position' = [left bottom width height]

    if scrn(3) == 1920
        POS = [1086 90 742  960];
    elseif scrn(3) == 1536
        POS = [936 65 535 692];
    else
        POS = ceil([scrn(3)-0.9*scrn(4)*8.5/11 0.075*scrn(4) 0.8*scrn(4)*8.5/11 0.8*scrn(4)]);
    end

    set(groot,'DefaultFigurePosition',POS);

%% Prompt for filename

    disp(' ');
    fname = input('   Input complete LRS data filename: ','s');
    disp(' ');

% Check for file extension

    L = length(fname);
    
    if ~strcmp(fname(L-3:L),'.asc')
        
        reply = input('   File must be in ascii text format only. Proceed? (y/n) [n]: ','s');
        disp(' ');
        
        if strcmpi(reply,'y')
            fname = [fname '.asc'];
        else
            return
        end
    end

% Load the file

    DM = load(fname, '-ascii');

% Parse the data into vectors

    RS0 = DM(:,1);
    In0 = DM(:,2);

%% Select RS-window: 200-4500 cm^-1

    LL = 0;
    UL = 5000;

    rsw = input('   Use standard (200-4500 cm^-1) or custom Raman shift window? (s/c) [s]: ','s');
    disp(' ');
    
    if strcmpi(rsw,'')
        rsw = 's';
    end
    
    if strcmpi(rsw,'s')
        LL = 200;
        UL = 4500;
    else
        while LL == 0
            LLi = input('   Input lower limit where 199 < LL < 4001. (200): ','s');
            disp(' ');
            if strcmp(LLi,'')
                LL = 200;
            elseif ((str2double(LLi) > 199) && (str2double(LLi) < 4001))
                LL = str2double(LLi);
            else
                LL = 0;
            end
        end
        while UL == 5000
            ULi = input('   Input upper limit where LL+100 < UL < 4501. (4500): ','s');
            disp(' ');
            if strcmp(ULi,'')
                UL = 4500;
            elseif ((str2double(ULi) > 499) && (str2double(ULi) < 4501))
                UL = str2double(ULi);
            else
                UL = 5000;
            end
        end
    end
    
    if (LL == 200) && (UL == 4500)
        rsw = 's';
    end

    J = find((RS0 >= LL) & (RS0 <= UL));

% Define data limits

    RS1 = RS0(J);
    In1 = In0(J);

    In1min = min(In1);
    In1max = max(In1);
    In1rng = In1max - In1min;

%% Set fitting parameters for Bfit processing

% Default parameters

    % [ycorr,yfit] = Bfit1(data,pts,avgpts,method,confirm);

    pts = [];       % Indices for baseline points to use to define baseline.
                    %   This parameter is not set to force graphical input.
    avgpts = 3;     % Number of points to average around selected baseline points.
                    %   Must be an odd integer.
    method = [];    % "method" controls the algorithm applied for the baseline fit.
                    %   The routine uses Matlab's interp1 command. 
                    %   "method" must be one of the methods supported by interp1.
                    %   Some options are 'linear', 'spline' & 'cubic' or 'pchip'.
                    %   (Default is 'spline').    
    confirm = [];   % If specified as the string 'confirm', it will allow the user
                    %   to see the result and to confirm if it is acceptable. If not
                    %   the user can reselect "pts". (Default = 'confirm'.)
    
% Operator selection of parameters: default vs user defined

    disp('   Default fitting parameters:');
    disp('     pts not set forcing graphical input');
    disp('     avgpts = 3');
    disp('     method = ''spline''');
    disp('     confirm is set to ''confirm''');
    disp(' ');
        
    dfpi = input('   Use default fitting parameters or user input option? (d/u) [d]: ','s');
    disp(' ');
    
    if strcmpi(dfpi,'')
        dfpi = 'd';
    end
    
    if strcmpi(dfpi,'d')
        method = 'spline';
        confirmi = 'y';
    else
        avgpts = 0; method = 0; confirm = 0;
        while avgpts == 0
            avgptsi = input('   Input number of basline points to average [3]: ','s');
            disp(' ');
            if strcmpi(avgptsi,'')
                avgpts = 3;
            else
                avgpts = str2double(avgptsi);
            end
        end
        while method == 0
            methodi = input('   Input baseline interpolation method (linear, spline, or pchip) [spline]: ','s');
            disp(' ');
            if strcmp(methodi,'')
                method = 'spline';
            else
                method = methodi;
            end
        end
        while confirm == 0
            confirmi = input('   Confirm graphical input verification: (y/n) [y] ','s');
            disp(' ');
            if strcmp(confirmi,'')
                confirmi = 'y';
                confirm = 1;
            elseif strcmp(confirmi,'y')
                confirmi = 'y';
                confirm = 1;
            else
                confirmi = 'n';
                confirm = [];
            end
        end
    end

% Call function "Bfit1.m" to baseline correct Raman spectra

    if confirmi == 'y'
        [In1cor,BLfit] = Bfit1(In1,avgpts,method,'confirm');
    else
        [In1cor,BLfit] = Bfit1(In1,avgpts,method);
    end

% Inspect corrected intensity data and correct for I <= 0

    In1cormin = min(In1cor);
    In1cormax = max(In1cor);
    In1corrng = In1cormax - In1cormin;
    
    Incormin1sav = 0;

    if In1cormin <= 0
        In1cormin1sav = In1cormin;
        In1cor = In1cor - In1cormin;
        In1cormin = min(In1cor);
        In1cormax = max(In1cor);
    end

    BLfitmin = min(BLfit);
    BLfitmax = max(BLfit);
    
    ResErrmin = min(In1-In1cor-BLfit-In1cormin1sav);
    ResErrmax = max(In1-In1cor-BLfit-In1cormin1sav);
    
    BLErrmin = min(BLfitmin,ResErrmin);
    BLErrmax = max(BLfitmax,ResErrmax);
    BLErrrng = BLErrmax - BLErrmin;

%% Plot spectra

% Define plotting region

    figure(1); clf;
    set(gcf,'color','w');
    orient tall;

%% Make upper panel plot

    subplot('position', [1.5/8.5 7.75/11 6.0/8.5 3.0/11])

    plot(RS1,In1,'-','Color',[0,0,1],'LineWidth',1)
    hold on
    plot(RS1,BLfit,'--','Color',[1,0,0],'LineWidth',1)

% Define axes

    axis('xy');
    
    if strcmpi(rsw,'s')
        xmin = 0;
        xmax = 4500;
    else
        xmin = LL - 0.02*(UL-LL);
        xmax = UL + 0.02*(UL-LL);
    end

    ymin1 = floor(In1min - 0.05*In1rng);
    ymax1 = ceil(In1max + 0.05*In1rng);
    
    axis([xmin xmax ymin1 ymax1]);

    h=gca;
    set(h,'FontSize',12);
    set(h,'FontWeight','normal');
    set(h,'LineWidth',1);

% Label plot -- Y-Axis

    ylabel('Intensity Counts');
    h=get(gca,'ylabel');
    set(h,'Color',[0 0 0]);
    set(h,'FontSize',14);
    set(h,'FontWeight','normal');

% Label plot -- Legends

    leg0 = ['Filename: ' fname];
    h1 = text(0.04*(xmax-xmin)+xmin,0.85*(ymax1-ymin1)+ymin1,leg0);
    set(h1,'Color',[0,0,0]);
    set(h1,'FontSize',12);
    set(h1,'FontWeight','normal');

    leg1 = '--  Raw Data';
    h1 = text(0.08*(xmax-xmin)+xmin,0.75*(ymax1-ymin1)+ymin1,leg1);
    set(h1,'Color',[0,0,1]);
    set(h1,'FontSize',12);
    set(h1,'FontWeight','normal');

    leg2 = '--  Baseline';
    h1 = text(0.08*(xmax-xmin)+xmin,0.65*(ymax1-ymin1)+ymin1,leg2);
    set(h1,'Color',[1,0,0]);
    set(h1,'FontSize',12);
    set(h1,'FontWeight','normal');

    hold off

%% Make middle panel plot

    subplot('position', [1.5/8.5 4.25/11 6.0/8.5 3.0/11])

    plot(RS1,In1cor,'-','Color',[0.8,0,0.8],'LineWidth',1)
    
    hold on

% Define axes

    axis('xy');

    ymin2 = floor(In1cormin - 0.05*In1corrng);
    ymax2 = ceil(In1cormax + 0.05*In1corrng);
    
    axis([xmin xmax ymin2 ymax2]);

    h=gca;
    set(h,'FontSize',12);
    set(h,'FontWeight','normal');
    set(h,'LineWidth',1);

% Label plot -- Y-Axis

    ylabel('Intensity Counts');
    h=get(gca,'ylabel');
    set(h,'Color',[0 0 0]);
    set(h,'FontSize',14);
    set(h,'FontWeight','normal');

% Label plot -- Legends

    leg3 = ['Fit: ' method];
    h1 = text(0.04*(xmax-xmin)+xmin,0.85*(ymax2-ymin2)+ymin2,leg3);
    set(h1,'Color',[0,0,0]);
    set(h1,'FontSize',12);
    set(h1,'FontWeight','normal');

    leg4 = ['Avgpts: ' num2str(avgpts)];
    h1 = text(0.04*(xmax-xmin)+xmin,0.75*(ymax2-ymin2)+ymin2,leg4);
    set(h1,'Color',[0,0,0]);
    set(h1,'FontSize',12);
    set(h1,'FontWeight','normal');

    leg5 = '--  Corr''d Data';
    h1 = text(0.08*(xmax-xmin)+xmin,0.65*(ymax2-ymin2)+ymin2,leg5);
    set(h1,'Color',[0.8,0,0.8]);
    set(h1,'FontSize',12);
    set(h1,'FontWeight','normal');

    hold off

%% Make lower panel plot

    subplot('position', [1.5/8.5 0.75/11 6.0/8.5 3.0/11])

    plot(RS1,BLfit,'-','Color',[1,0,0],'LineWidth',1)

    hold on

    plot(RS1,In1-In1cor-BLfit-In1cormin1sav,'--','Color',[0,0.6,0],'LineWidth',1)
    
% Define axes

   axis('xy');

    ymin3 = floor(BLErrmin - 0.10*BLErrrng);
    ymax3 = ceil(BLErrmax + 0.10*BLErrrng);

    axis([xmin xmax ymin3 ymax3]);

    h=gca;
    set(h,'FontSize',12);
    set(h,'FontWeight','normal');
    set(h,'LineWidth',1);

% Label plot -- X-Axis

    xlabel('Raman shift [cm^{-1}]');
    h=get(gca,'xlabel');
    set(h,'Color',[0,0,0]);
    set(h,'FontSize',14);
    set(h,'FontWeight','normal');

% Label plot -- Y-Axis

    ylabel('Intensity Counts');
    h=get(gca,'ylabel');
    set(h,'Color',[0 0 0]);
    set(h,'FontSize',14);
    set(h,'FontWeight','normal');

% Label plot -- Legends

    leg6 = '--  Baseline';
    h1 = text(0.08*(xmax-xmin)+xmin,0.80*(ymax3-ymin3)+ymin3,leg6);
    set(h1,'Color',[1,0,0]);
    set(h1,'FontSize',12);
    set(h1,'FontWeight','normal');

    leg7 = '--  Residual Errors';
    h1 = text(0.08*(xmax-xmin)+xmin,0.70*(ymax3-ymin3)+ymin3,leg7);
    set(h1,'Color',[0,0.6,0]);
    set(h1,'FontSize',12);
    set(h1,'FontWeight','normal');

    hold off

    
%% Option to save the difference spectrum to an ascii file
 
%  Saved files are auto-named based upon the input filenames.
 
    savname = fname(1:end-4);

    savname(savname == ' ') = '-';
    savname(savname == '_') = '-';

    savs = input('   Would you like to save the baseline corrected spectrum? (y/n) [n]: ', 's');
    disp(' ');
    
    if strcmpi(savs,'y')
        savsns = input('   Add a serial increment to the filename? (y/n) [n]: ', 's');
        disp(' ');
    else
        savsns = 'n';
    end
    
    if (strcmpi(savs,'y')) && (strcmpi(savsns,'y'))
        serincs = input('   Serial increment = ', 's');
        disp(' ');
    else
        serincs = '';
    end
    
    if strcmpi(savs,'y')
        savname_bcrs = [savname '-bc' serincs '.asc'];
        bcrData = [RS1,In1cor];
        fid = fopen(savname_bcrs,'w');
        for K = 1:length(bcrData)
            fprintf(fid,'%6.1f   %12.3f\n',bcrData(K,:));
        end
        fclose(fid); 
    end
    
%% Option to save the baseline correction to an ascii file
 
 %  Saved files are auto-named based upon the input filenames.
 
    savs = input('   Would you like to save the baseline correction data? (y/n) [n]: ', 's');
    disp(' ');
    
    if strcmpi(savs,'y')
        savsns = input('   Add a serial increment to the filename? (y/n) [n]: ', 's');
        disp(' ');
    else
        savsns = 'n';
    end
    
    if (strcmpi(savs,'y')) && (strcmpi(savsns,'y'))
        serincs = input('   Serial increment = ', 's');
        disp(' ');
    else
        serincs = '';
    end
    
    if strcmpi(savs,'y')
        savname_blcrs = [savname '-bl' serincs '.asc'];
        blcrData = [RS1,BLfit];
        fid = fopen(savname_blcrs,'w');
        for K = 1:length(blcrData)
            fprintf(fid,'%6.1f   %13.3f\n',bcrData(K,:));
        end
        fclose(fid); 
    end
    
%% Option to save Figure 1

%  If yes, figure 1 is saved in the working directory as a png-formated file.
%  Saved files are auto-named based upon the input filenames.

    savs = input('   Would you like to save Figure 1? (y/n) [n]: ', 's');
    disp(' ');

    if strcmpi(savs,'y')
        savsns = input('   Add a serial increment to the filename? (y/n) [n]: ', 's');
        disp(' ');
    else
        savsns = 'n';
    end
    
    if (strcmpi(savs,'y')) && (strcmpi(savsns,'y'))
        serincs = input('   Serial increment = ', 's');
        disp(' ');
    else
        serincs = '';
    end
    
    if strcmpi(savs,'y')
        savnamef1 = [savname '-bc' serincs '.png'];
        % savnamef2 = [savname '-bc' serincs '.ps'];

        hf1 = figure(1);
        hf1.PaperOrientation = 'portrait';
        eval(['print -dpng -r300 ' savnamef1 ';'])
        % eval(['print -dpsc -r300 ' savnamef2 ';'])
    end
