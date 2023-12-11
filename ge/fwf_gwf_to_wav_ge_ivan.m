function [] = fwf_gwf_to_wav_ge_ivan(GWF, RF, DT, wf_num, bvalues_array, no_of_directions_array, wf_idx_array, system_ID, plot)

% Script that creates a set of DDE flow-compensated waveforms for use on a
% GE scanner with the MDD pulse sequence. The 

% Inputs:
% - wf_num: 
%       int 0-999 for naming the waveform as used by the GE interfac
% - encoding_time: 
%       Even int, total encoding time in [ms]
% - NOW_txt_path: 
%       Path to a txt-file saved from the NOW GUI, containing the
%       DDE waveforms. It is assumed that these are 1st order motion compensated
%       as the script creates its own non-compensated waveforms from these.
%       This is accomplished by inverting the post-RF waveforms, made
%       possible by the use of DDE.
% - bvalues_array: 
%       Array for b-values expressed in ms/um2
% - no_of_directions_array: 
%       Array of ints, number of direction for each b-value
% - wf_idx_array: 
%       Array of ints (1 or 2). For each bvalue, specify whether
%       1 for flow compensation, 2 for no flow compensation
% - plot:
%       int. 1 if the first waveform is to be plotted. 0 or unspecified if
%       no plot is desired.

% Outputs:
% Saves xps containing waveform information as json
% Saves wav-files that can be executed on a GE system

% Dependencies:
% fwf_header_tools
% mddGE_matlab by Emil Ljungberg (Lund University), not public

% Ivan A. Rashid
% Lund University, 8th Dec 2023
% Contact: ivan.rashid@med.lu.se

if nargin < 8
    system_ID = input("Select GE system.\n" + ...
        "1) Premier\n" + ...
        "2) MR750/MR450\n" + ...
        "3) MR450w/MR750w/Artist/Architect/PETMR\n" + ...
        "Input: ");
end

if nargin < 9
    plot = 0;
end

% Get the system limits
system = fwf_ge_systems(system_ID);

% Create the waveforms
% Uses mddGE_make_waveforms, a script from Emil Ljungbers library
% mddGE_matlab library
[AA, BB, g_normalize] = mddGE_make_waveforms(GWF,RF,DT,bvalues_array, no_of_directions_array, wf_idx_array);

% The filename must be of the type wfgXXXpre180.wav and wfgXXXpost180.wav
fname_pre = sprintf('wfg%03dpre180.wav', wf_num);
fname_post = sprintf('wfg%03dpost180.wav', wf_num);

% Write waveform files
% mddGE_write_wav, a script from Emil Ljungbergs library
desc = '';
out_AA = mddGE_write_wav(fname_pre, AA, g_normalize, desc);
out_BB = mddGE_write_wav(fname_post, BB, g_normalize, desc);

% Gradient amplitude safety check
if out_AA.gmax > system.g_max*.1 || out_BB.gmax > system.g_max*.1
    delete(sprintf(fname_pre));
    delete(sprintf(fname_post));
    error("WARNING: Gradient amplitude exceeds system limits. " + ...
        "Wav-files have been deleted.");
end

% Gradient slew rate safety check
if out_AA.smax > system.slew_max*.1 || out_BB.smax > system.slew_max*.1
    delete(sprintf(fname_pre));
    delete(sprintf(fname_post));
    error("WARNING: Gradient slew rate exceeds system limits. " + ...
        "Wav-files have been deleted.");
end

% Plot waveform (sanity check)
% Uses mddGE_plot_wav, a script from Emil Ljungbergs library
if plot == 1
    [grad_wf, grad_rf, grad_dt] = mddGE_plot_wav(fname_post, 1, 7e-3);
end

% Create the xps
[gwfl, rfl, dtl] = fwf_wav_to_gwfl(fname_pre);
xps = fwf_xps_from_gwfl(gwfl, rfl, dtl);

% Save the xps
fname_xps = sprintf('wfnum%03d_xps', wf_num);
save(fname_xps, "xps");






