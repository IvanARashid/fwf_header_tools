function [gwf, rf, dt] = fwf_gwf_force_dur(gwf, rf, dt, dur, post_only)
% function [gwf, rf, dt] = fwf_gwf_force_dur(gwf, rf, dt, dur)
% By FSz
%
% Function forces a total duration of the gradient waveform (including
% padding by zeros) without rescaling the input (just padding).
%
% Modification by Ivan A. Rashid 27 Dec 2023
% post_only : 0 if padding is to be applied symmetrically
%           : 1 if padding is only to be applied on the post-180 pulse

if nargin < 5
    post_only = 0;
end

n1 = sum(rf>0);
n2 = sum(rf<0);

n = round(dur/dt/2);

p1 = n-n1;
p2 = n-n2;

if p1 < 0 && post_only == 0
    error
end
if p2 < 0 && post_only == 0
    error
end

% Only pad post-180 pulse
if post_only == 1
    n = round(dur/dt);
    p1 = 0;
    p2 = n;
end

gwf = [zeros(p1, 3); gwf];
rf  = [rf(1) * ones(p1,1); rf];

gwf = [gwf; zeros(p2,3)];
rf  = [rf;  rf(end)*ones(p2,1)];


if sum(rf) && post_only == 0
    error
end

