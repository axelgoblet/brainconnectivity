
function [ rlOut ] = RosslerLorenz( initialConditions, C )
%RosslerLorenz Evaluates a coupled RosslerLorenz system for various coupling strengths
%   This function evaluates a coupled Rossler-Lorenz system as outlined in
%   the paper "Information-based detection of nonlinear Granger causality 
%   in multivariate processes via a nonuniform embedding technique" by Faes
%   et al (2011, section IIIa, p4). 
%
%   It evaluates the systems with the parameters specificed in the paper 
%   and the initial conditions passed as a parameter (to allow for the
%   variations described in the paper). The first 10^5 iterations are
%   discareded to avoid transients and the result is cropped to 10^5
%   iterations. For each coupling strength a 10^5 x 6 matrix is returned,
%   comprising 6 time series with 10^ samples for each of the variables
%   (z1,z2,z3,y1,y2,y3) respectively. The paper uses x1=z2 as driving
%   variable and x2=y2 as driven variable to evaluate causality.

    if (nargin < 1)
       initialConditions = [1 1 1 1 1 1];
    end
    
    % Various coupling strengths as per paper
    if (nargin < 2)
        C = [ 0, 0.5, 1.5, 2, 2.5, 3];
    end

    % Rossler parameters
    para = 0.2;
    parb = 0.2;
    pard = 5.7;
    
    % These values are used to create a 'Funnel atrractor' for a more complex
    % topological structure, as per the Faes paper reference above, page 5
    %para = 0.25; parb = 0.1; pardd = -8.5;
    
    % Lorenz parameters
    sigma = 10;
    beta = 8/3;
    rho = 28;
        
    rlOut = zeros(numel(C), 10000, 6);

    for i=1:numel(C)
        SysRolled = @(t, a) [ -6 * (a(2) + a(3));
            6*(a(1) + para*a(2));
            6*(parb + a(1)*a(3) - pard*a(3));

            -sigma*a(4) + sigma*a(5); 
            rho*a(4) - a(5) - a(4)*a(6) + C(i) * a(2)^2; 
            -beta*a(6) + a(4)*a(5)

            ];
        
        % discarding the first 10^5 iterations
        [~, aRolled] = ode45(SysRolled, (0:0.01:199.99), initialConditions);
        % we'll keep the full results, paper uses indices 2 and 5
        rlOut(i,:,:) = aRolled(10001:end,:);
    end

end
