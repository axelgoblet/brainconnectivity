load('..\data\fullDataSet.mat')

touse = data(data(:,1) == 1 & data(:,2) == 1 & data(:,3) == 1 & data(:,4) == 2,:);
total = 60
amount= 60;
distance = zeros(amount);

for i=1:amount
   for j=1:amount
       distance(i,j) = sum(abs(touse(i+(total-amount),6:length(touse(1:1394)))-touse(j+(total-amount),6:length(touse(1:1394)))));
   end
end

figure(2)
imagesc(distance)
colorbar

figure(1)
y1 = touse(1,6:length(touse(1,:)));
subplot(2,2,1)
plot(t,y1)
title('V1, Contrast 1, Attention 1, electrode 1, trial 1')
xlabel('time') % x-axis label
ylabel('LFP') % y-axis label

y2 = touse(2,6:length(touse(2,:)));
subplot(2,2,2)
plot(t,y2)
title('V1, Contrast 1, Attention 1, electrode 1, trial 2')
xlabel('time') % x-axis label
ylabel('LFP') % y-axis label

y3 = touse(3,6:length(touse(3,:)));
subplot(2,2,3)
plot(t,y3)
title('V1, Contrast 1, Attention 1, electrode 1, trial 3')
xlabel('time') % x-axis label
ylabel('LFP') % y-axis label

y4 = touse(60,6:length(touse(60,:)));
subplot(2,2,4)
plot(t,y4)
title('V1, Contrast 1, Attention 1, electrode 1, trial 4')
xlabel('time') % x-axis label
ylabel('LFP') % y-axis label