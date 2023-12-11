function [xps] = fwf_wav_to_xps(filename_wav_pre_or_post, filename_xps)
% Creates and save an xps-structure from a set of .wav-files

if nargin < 2
    filename_xps = 'xps';
end

% Get the gwf, rf, dt
[gwfl, rfl, dtl] = fwf_wav_to_gwfl(filename_wav_pre_or_post);

% Create the xps
xps = fwf_xps_from_gwfl(gwfl, rfl, dtl);

% Save the xps
save(filename_xps, "xps");
