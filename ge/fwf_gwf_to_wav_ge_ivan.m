function [] = fwf_gwf_to_wav_ge_ivan(GWF, RF, DT, wf_num, bvalues_array, no_of_directions_array, wf_idx_array, system_ID, plot, padded)

% Script that creates a set of diffusion encoding shells based on inputs of
% gradient waveform array, rf array, and time resolution.
%
% The script is aimed at GE implementation of a free waveform sequence
% distributed by Tim Sprenger.
%
% The script requires read/write functions of .wav, which are not openly
% distributed. Contact Tim Sprenger @ GE to obtain them.

% Inputs:
% - GWF                     : Gradient waveform array. Should be in units 
%                             of T/m.
% - RF                      : RF array. 1 pre-180, -1 post-180
% - DT                      : Time resolution of the GWF array
% - wf_num                  : The number to be assigned to the waveform 
%                             files. Should be between 1 and 999.
% - bvalues_array           : Array of b-values for the shell
% - no_of_directions_array  : The number of directions to be distributed
%                             for the shell
% - wf_idx_array            : The waveform index, for when multiple
%                             different waveforms are used.
% - system_ID               : System ID for safety check of gradient
%                             limits. See the prompt for definitions.
% - plot                    : 0 to skip plotting. > 0 to plot the waveform
%                             with that index in the file. Note that it is
%                             better to use the plot-function to plot
%                             specific waveforms rather than to re-run
%                             this script every time.
% - padded                  : 0 if waveforms are not padded, 1 if waveforms
%                             are padded with zeros. Important as zeros are
%                             a disregarded in one of the functions

% Outputs:
% Saves xps containing waveform information as .mat-file
% Saves wav-files that can be executed on a GE system with the right
% sequence

% Dependencies:
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
    padded = 0;
end

% Get the system limits
system = fwf_ge_systems(system_ID);

% Work-around to create extended/padded waveforms
if padded == 1
    GWF(end-1,1,:) = 1e-14; % As end of waveform is detected as the last 0
    % we move it by changing the next-to-last element to above the zero
    % threshold of 1e-15.
end

% Create the waveforms
% Uses mddGE_make_waveforms, a script from Emil Ljungbers library
% mddGE_matlab library
[AA, BB, g_normalize] = mddGE_make_waveforms(GWF,RF,DT,bvalues_array, no_of_directions_array, wf_idx_array);

% Continuation of work-around to create extended/padded waveforms
if padded == 1
    % Reverts the change we did earlier
    BB(end-1,:,:) = 0;
    BB(end-1,:,:) = 0;
    BB(end-1,:,:) = 0;
end

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
if plot > 0
    [grad_wf, grad_rf, grad_dt] = mddGE_plot_wav(fname_post, plot, 7e-3);
end

% Create the xps
[gwfl, rfl, dtl] = fwf_wav_to_gwfl(fname_pre);
xps = fwf_xps_from_gwfl(gwfl, rfl, dtl);

% Save the xps
fname_xps = sprintf('wfnum%03d_xps', wf_num);
save(fname_xps, "xps");






