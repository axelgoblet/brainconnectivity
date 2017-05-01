function [x1tox2FreqCausality, x2tox1FreqCausality] = bandPassCNPMR(x1, x2, order, range, samplingFrequency, resolution, bandwidth)
    %This function computes causalities at each frequency within the range,
    %using a bandpass filter

    %frequency range
    minFreq = range(1);
    maxFreq = range(2);

    %initialization
    x2tox1=zeros(1,6);
    x1tox2=zeros(1,3);
    x1tox2FreqCausality = zeros(1, (maxFreq - minFreq)/resolution);
    x2tox1FreqCausality = zeros(1, (maxFreq - minFreq)/resolution);

    %iterate through frequency range with resolution
    freq = minFreq
    count = 1;
    while freq <= maxFreq
        %create filter
        lowBound = (2*(freq-bandwidth/2))/samplingFrequency;
        upBound = (2*(freq+bandwidth/2))/samplingFrequency;
        if lowBound <= 0
            bpf = fir1(order, [0.000001 0.000001]);
        elseif upBound >= 1
            bpf = fir1(order, [0.000001 0.000001]);
        else
            bpf = fir1(order, [lowBound upBound]);
        end

        %apply filter to data
        bpx1 = filter(bpf,0.5,x1);
        bpx2 = filter(bpf,0.5,x2);

        %compute causaility
        [causality,xR2,isSignificant,sensitivity] = CNPMR(bpx1,bpx2,[],1,3,1,1,[],true);
        x2tox1 = x2tox1 + [causality,xR2,isSignificant,sensitivity];
        [causality,xR2,isSignificant,sensitivity] = CNPMR(bpx2,bpx1,[],1,3,1,1,[],false);
        x1tox2 = x1tox2 + [causality,xR2,isSignificant,sensitivity];

        % fill frequency causaility array
        x1tox2FreqCausality(count) = x1tox2(1);
        x2tox1FreqCausality(count) = x2tox1(1);

        %reset
        x2tox1=zeros(1,6);
        x1tox2=zeros(1,3);
        freq = freq + resolution
        count = count + 1;
    end
end