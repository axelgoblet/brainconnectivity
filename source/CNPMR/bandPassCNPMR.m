function [x1tox2FreqCausality, x2tox1FreqCausality] = bandPassCNPMR(x1,x2,order,range,samplingFrequency)
%This function computes causalities at each frequency within the range,
%using a bandpass filter

%frequency range
minFreq = range(1);
maxFreq = range(2);

%initialization
x2tox1=zeros(1,6);
x1tox2=zeros(1,3);
x1tox2FreqCausality = zeros(1, maxFreq - minFreq);
x2tox1FreqCausality = zeros(1, maxFreq - minFreq);

%iterate through frequency range
for freq = minFreq:maxFreq
    %create filter
    bpf = fir1(order, [freq/samplingFrequency, freq/samplingFrequency]);
    
    %apply filter to data
    bpx1 = filter(bpf,0.5,x1);
    bpx2 = filter(bpf,0.5,x2);
    
    %compute causaility
    [causality,xR2,isSignificant,sensitivity] = CNPMR(bpx1,bpx2,[],1,3,1,1,[],true)
    x2tox1 = x2tox1 + [causality,xR2,isSignificant,sensitivity];
    [causality,xR2,isSignificant,sensitivity] = CNPMR(bpx2,bpx1,[],1,3,1,1,[],false)
    x1tox2 = x1tox2 + [causality,xR2,isSignificant,sensitivity];
    
    % fill frequency causaility array
    x1tox2FreqCausality(freq) = x1tox2(1);
    x2tox1FreqCausality(freq) = x2tox1(1);
    
    %reset
    x2tox1=zeros(1,6);
    x1tox2=zeros(1,3);
end

end