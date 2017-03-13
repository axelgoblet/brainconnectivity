close all, clear all

DRIVE='../data'; %% set where the data is stored

data=NaN(39984,2577);

i=1;

for CONTRAST=1:2:20%%% we change the lumninance contrast of the stimulus
    for ATTENTION_CND=1:2 %there are two attention conditions 1) the stimulus is task-relevant, 2) the stimulus is ignored
        
        
        filename=[DRIVE '/MK_S_Pen117_timelock_Con' num2str(CONTRAST) '_att' num2str(ATTENTION_CND)];
        load(filename)
        NUMBER_OF_TRIALS=size(timelock.trial,1);
                       
        for ELECTRODEAREA=1:48%V4=1:16,V1=17:32,V2=33:48
            for TRIAL=1:NUMBER_OF_TRIALS
                
                AREACODE=floor(ELECTRODEAREA/16);
                if AREACODE == 0
                    AREA=4;%V4
                else
                    AREA = AREACODE;%V1 or V2
                end
                
                ELECTRODE=mod(ELECTRODEAREA,16);
                if ELECTRODE == 0
                    ELECTRODE = 16;
                end
                
                ROWINFO = [CONTRAST,ATTENTION_CND,AREA,ELECTRODE,TRIAL]
                lfp = squeeze(timelock.trial(TRIAL,ELECTRODEAREA,:))';
                                
                data(i,1:length(lfp)+length(ROWINFO))=[ROWINFO,lfp];
                
                i=i+1;
            end
        end
    end
end

headers = {'CONTRAST','ATTENTION_CND','AREA','ELECTRODE','TRIAL', strcat('t', strtrim(cellstr(num2str((0:2571)'))'))};
headers = [headers{:}];

t = -0.5+0.001*(0:2571);

save('../data/fullDataSet.mat', 'data', 'headers', 't')

clear