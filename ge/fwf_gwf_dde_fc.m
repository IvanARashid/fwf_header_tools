function [] = fwf_gwf_dde_fc(wf_num, encoding_time, NOW_txt_path, bvalues_array, no_of_directions_array, wf_idx_array, plot)

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
% Lund University, 25th Aug 2023

if nargin < 7
    plot = 0;
end



% Read NOW.txt files
time_pre180 = (encoding_time-6)/2*1e-3; % [s]
time_180 = 6e-3; % [s]
time_post180 = time_pre180;

% Calculate the diffusion time
diffusion_time = encoding_time*1e-3;

% Read the data in the NOW.txt file
fileID = fopen(NOW_txt_path, "r");
data = fscanf(fileID, "%f");
rows = data(1);
GWF_FC = readtable(NOW_txt_path);
GWF_FC = table2array(GWF_FC);

% Determine the discrete time steps
DT = diffusion_time/rows;

% Create the RF array, pre180 = 1, post180 = -1
n_pre180 = round((time_pre180 + time_180/2)/DT);
n_post180 = round((time_post180 + time_180/2)/DT);
RF_pre180 = ones([n_pre180 1]);
RF_post180 = ones([n_post180 1])*(-1);
RF = cat(1, RF_pre180, RF_post180);

% Create the NC waveform by multiplying with RF. Where RF is -1, the
% gradients are inverted, removing the flow-compensation
GWF_NC = GWF_FC.*[RF RF RF];

% Stitch the FC and NC together
GWF = cat(3,GWF_FC, GWF_NC);






%b_l = [.05 .05]; % b-values
%n_l = [18 18];    % Number of directions
%c_i = [1 2];    % Index

% Create the waveforms
% Uses mddGE_make_waveforms, a script from Emil Ljungbers library
% mddGE_matlab library
[AA, BB, g_normalize] = mddGE_make_waveforms(GWF,RF,DT,bvalues_array, no_of_directions_array, wf_idx_array);

% The filename must be of the type wfgXXXpre180.wav and wfgXXXpost180.wav
%wf_num = 900+(time_pre180+time_180+time_post180)*1e3;
fname_pre = sprintf('wfg%03dpre180.wav', wf_num);
fname_post = sprintf('wfg%03dpost180.wav', wf_num);

% Write waveforms
% mddGE_write_wav, a script from Emil Ljungbergs library
desc = '';
out_AA = mddGE_write_wav(fname_pre, AA, g_normalize, desc);
out_BB = mddGE_write_wav(fname_post, BB, g_normalize, desc);

%[grad,N,params,desc] = mddGE_read_wav('wfg999post180.wav');

% Plot waveform (sanity check)
% Uses mddGE_plot_wav, a script from Emil Ljungbergs library
if plot == 1
    [grad_wf, grad_rf, grad_dt] = mddGE_plot_wav(fname_post, 1, time_180);
end




grad_dt = 4e-6; % Default for GE system

% The time used for the 180 RF pulse
n_grad_wait = round(time_180/grad_dt);
grad_wait = zeros(n_grad_wait,3);

% Extract gradient waveform information. b-value, alpha, etc.
xps = [];
for i=1:sum(no_of_directions_array)
    grad_wf1 = cat(1, squeeze(AA(:,i,:)), grad_wait, squeeze(BB(:,i,:)));
    
    n_pre = size(AA);
    grad_rf = ones(size(grad_wf1,1), 1);
    grad_rf(n_pre(1)+round(n_grad_wait/2):end, 1) = -1;
    
    wf_xps = gwf_to_pars(grad_wf1, grad_rf, grad_dt);
    xps = [xps wf_xps];
end
 

% Write xps to json file
xps_json = jsonencode(xps);

fname_output = sprintf("wfnum%03d.json", wf_num);
fid = fopen(fname_output, "w");
fprintf(fid, "%s", xps_json);
fclose(fid);







