function [grad_wfl, grad_rfl, grad_dtl] = fwf_wav_to_gwfl2(fname, delay)

if nargin < 2
    delay = 7e-3;
end

% Parse the filename, can be either pre or post
[path, fname, ext] = fileparts(fname);
if isempty(path)
    path = '.';
end

if ~strcmp(ext, ".wav")
    error('File should be of .wav type')
end

[~, base_name] = regexp(fname, 'wfg\d\d\d', 'tokens', 'match');
base_name = base_name{1};
pre_fname = sprintf("%s\\%spre180.wav", path, base_name);
post_fname = sprintf("%s\\%spost180.wav", path, base_name);

% Default for the GE system
grad_dt = 4E-6;


n_grad_wait = round(delay/grad_dt);

%[grad_pre,~,~,~,~,params] = read_ak_wav(pre_fname);
[grad_pre,~,params,~] = mddGE_read_wav(pre_fname);
if params(6)*1E-6 ~= grad_dt
    error('Gradient update rate does not match');
end

%[grad_post,~,~,~,~,params] = read_ak_wav(post_fname);
[grad_post,~,params,~] = mddGE_read_wav(post_fname);
if params(6)*1E-6 ~= grad_dt
    error('Gradient update rate does not match');
end

n_pre = size(grad_pre,1);
grad_wait = zeros(n_grad_wait,3, size(grad_post, 2));

grad_wfl = cat(1, squeeze(permute(grad_pre(:,:,:), [1 3 2])), grad_wait, squeeze(permute(grad_post(:,:,:), [1 3 2])));
grad_wfl = num2cell(grad_wfl, [1 2]);

n_wfs = numel(grad_wfl);
grad_rf = ones(size(grad_wfl,1),1);
grad_rf(n_pre+round(n_grad_wait/2):end,1) = -1;
grad_rfl = repelem(grad_rf, 1, 1, n_wfs);
grad_rfl = num2cell(grad_rfl, [1 2]);

grad_dtl = repelem(grad_dt, 1, n_wfs);
grad_dtl = num2cell(grad_dtl, 1);