function [x1tox2FreqCausality, x2tox1FreqCausality] = bandPassCNPMR(x1,x2)

order = 50;
minFreq = 1;
maxFreq = 40;
x2tox1=zeros(1,6);
x1tox2=zeros(1,3);
x1tox2FreqCausality = zeros(1, maxFreq - minFreq);
x2tox1FreqCausality = zeros(1, maxFreq - minFreq);


for freq = minFreq:maxFreq
    bpf = fir1(order, [freq/1000, freq/1000]);
    bpx1 = filter(bpf,0.5,x1);
    bpx2 = filter(bpf,0.5,x2);
    [causality,xR2,isSignificant,sensitivity] = CNPMR(bpx1,bpx2,[],1,3,1,1,[],true)
    x2tox1 = x2tox1 + [causality,xR2,isSignificant,sensitivity];
    [causality,xR2,isSignificant,sensitivity] = CNPMR(bpx2,bpx1,[],1,3,1,1,[],false)
    x1tox2 = x1tox2 + [causality,xR2,isSignificant,sensitivity];
    x1tox2FreqCausality(freq) = x1tox2(1);
    x2tox1FreqCausality(freq) = x2tox1(1);
    x2tox1=zeros(1,6);
    x1tox2=zeros(1,3);
end

end