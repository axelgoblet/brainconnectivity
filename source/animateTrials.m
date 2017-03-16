close all, clear all

DRIVE='../data'; %% set where the data is stored
     
SPEEDUP = 2; % (integer) time increment per iteration, 1 = realtime, 2 = twice as fast etc
CONTRAST=11;
ATTENTION_CND=1;

filename=[DRIVE '/MK_S_Pen117_timelock_Con' num2str(CONTRAST) '_att' num2str(ATTENTION_CND)];
load(filename)

NUMBER_OF_TRIALS=size(timelock.trial,1);
NUMBER_OF_ELECTRODES=size(timelock.trial,2);
NUMBER_OF_TIME_SAMPLES=size(timelock.trial,3);

% setup
gcf = figure;
set(gcf,'color','w');
ELECTRODE_RECTS=[];
AREA=0;
TOPTEXT = text(1.5, 1, '');
for ELECTRODEAREA=1:48%V4=1:16,V1=17:32,V2=33:48
    AREACODE=floor((ELECTRODEAREA-1)/16);
    if AREACODE == 0
        AREA=4;%V4
    else
        AREA = AREACODE;%V1 or V2
    end
    
    ELECTRODE=mod(ELECTRODEAREA,16);
    if ELECTRODE == 0
        ELECTRODE = 16;
    end
    
    ELECTRODE_RECTS = [ELECTRODE_RECTS; rectangle('Position',[ (2*AREA) (-(ELECTRODE)) 1 1]')];
    text(2*AREA+0.35, -17, ['V' num2str(AREA)]);
end
axis([2 9 -18 1])
axis off;

% run
for TRIAL=1:NUMBER_OF_TRIALS
    MAXVAL = 1e-10;
    MINVAL = -1e-10;
    for TIME=1:SPEEDUP:NUMBER_OF_TIME_SAMPLES
        for ELECTRODEAREA=1:48
            % apparently we have NaNs in the dataset...
            if isnan(timelock.trial(TRIAL,ELECTRODEAREA,TIME))
                continue
            end

            ELVAL = timelock.trial(TRIAL,ELECTRODEAREA,TIME);
            
            % bookkeping for display
            if ELVAL > MAXVAL
                MAXVAL = ELVAL;
            elseif ELVAL < MINVAL
                MINVAL = ELVAL;
            end
              
            % pos colors red, neg colors blue
            if ELVAL >= 0
                ELECTRODE_RECTS(ELECTRODEAREA).FaceColor = [ ELVAL/MAXVAL 0 0 ];
            else
                ELECTRODE_RECTS(ELECTRODEAREA).FaceColor = [ 0 0 ELVAL/MINVAL ];                
            end
        end 
        
        
        TOPTEXT.String = ['File: MK\_S\_Pen117\_timelock\_Con' num2str(CONTRAST) '\_att' num2str(ATTENTION_CND) '   |   Trial: ' num2str(TRIAL) '   |   Time: ' num2str(timelock.time(TIME))];
        drawnow
    end
end
