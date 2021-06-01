function [b, u, n] = fwf_bvluvc_from_siemens_hdr(h)
% function [b, u, n] = fwf_bvluvc_from_siemens_hdr(h)

% Try to find user defined dvs first
csa           = fwf_csa_from_siemens_hdr(h);
[dvs, nrm]    = fwf_dvs_from_siemens_csa(csa);

if ~isempty(dvs)
    
    b = [];
    u = [];
    n = [];
    
    for i = 1:numel(seq.bval_req)
        if seq.bval_req(i) <= 1
            b = [b; 0];
            u = [u; [0 0 0]];
            n = [n; 0];
        else
            b = [b; nrm.^2 * seq.bval_req(i) * 1e6 ];
            u = [u; dvs];
            n = [n; nrm];
        end
    end
    
    u = u ./ sqrt(sum(u.^2, 2));
    u(isnan(u)) = 0;
    
    % WIP: This is still not the correct rotation for u (dvs is not rotated with the FOV).
    
    
else % Use bval and bvec exported by the system, which may be slightly wrong!
    
    try
        b = h.bval * 1e6; % s/m2
        u = h.bvec;
    catch
        b = h.B_value * 1e6; % s/m2
        u = h.DiffusionGradientDirection';
    end
    
    n = sqrt(b/max(b));
    
end