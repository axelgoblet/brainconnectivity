close all;
%Make sure real data is loaded in
data(isnan(data)) = 0;
%data on contrast =1 and attention =1 
V4 = mean(data(1:900,6:end),1,'omitnan');
V1 = mean(data(901:1860,6:end),1,'omitnan');
V2 = mean(data(1861:2820,6:end),1,'omitnan');
V3 = mean(data(2821:2880,6:end),1,'omitnan');
figure
plot(t,V4);
hold on;
plot(t,V1);
hold on;
plot(t,V2);
hold on;
plot(t,V3);
%V4 and V1
[causality1,xR2_1,isSignificant1,sensitivity1] = CNPMR(V4,V1,[],1,3,1,1,[],false);
[causality2,xR2_2,isSignificant2,sensitivity2] = CNPMR(V1,V4,[],1,3,1,1,[],false);
%V4 and V2
[causality3,xR2_3,isSignificant3,sensitivity3] = CNPMR(V4,V2,[],1,3,1,1,[],false);
[causality4,xR2_4,isSignificant4,sensitivity4] = CNPMR(V2,V4,[],1,3,1,1,[],false);
%V4 and V3
[causality5,xR2_5,isSignificant5,sensitivity5] = CNPMR(V4,V3,[],1,3,1,1,[],false);
[causality6,xR2_6,isSignificant6,sensitivity6] = CNPMR(V3,V4,[],1,3,1,1,[],false);

%V1 and V2
[causality7,xR2_7,isSignificant7,sensitivity7] = CNPMR(V1,V2,[],1,3,1,1,[],false);
[causality8,xR2_8,isSignificant8,sensitivity8] = CNPMR(V2,V1,[],1,3,1,1,[],false);
%V1 and V3
[causality9,xR2_9,isSignificant9,sensitivity9] = CNPMR(V1,V3,[],1,3,1,1,[],false);
[causality10,xR2_10,isSignificant10,sensitivity10] = CNPMR(V3,V1,[],1,3,1,1,[],false);

%V2 and V3
[causality11,xR2_11,isSignificant11,sensitivity11] = CNPMR(V2,V3,[],1,3,1,1,[],false);
[causality12,xR2_12,isSignificant12,sensitivity12] = CNPMR(V3,V2,[],1,3,1,1,[],false);

