function [b, u, n] = fwf_bvluvc_from_siemens_hdr(hdr)
% function [b, u, n] = fwf_bvluvc_from_siemens_hdr(hdr)

% Try to find user defined dvs first
csa        = fwf_csa_from_siemens_hdr(hdr);
[dvs, nrm] = fwf_dvs_from_siemens_csa(csa);
seq        = fwf_seq_from_siemens_csa(csa);

if ~isempty(dvs)

    b_list = fwf_blist_from_seq_siemens(seq);

    b = [];
    u = [];
    n = [];

    for i = 1:numel(b_list)
        if b_list(i) == 0 % add a single zero
            b = [b; 0];
            u = [u; [0 0 0]];
            n = [n; 0];

        else
            b = [b; nrm.^2 * b_list(i) * 1e6];
            u = [u; dvs];
            n = [n; nrm];

        end
    end

    % normalize the direction vectors
    u = u ./ sqrt(sum(u.^2, 2));
    u(isnan(u)) = 0;

    % WIP: This is still not the correct rotation for u (dvs is not rotated with the FOV).

    % Check that we are in the ballpark
    worst_diff = max(abs(b/1e6-hdr.bval));

    if worst_diff > 50
        error(['Large differences in b-values detected! (' num2str(worst_diff) ' s/mm^2)']);
    elseif worst_diff > 5
        warning(['Slight differences in b-values detected! (' num2str(worst_diff) ' s/mm^2)']);
    end


else % Use bval and bvec exported by the system, which may be slightly wrong! Use bvec_original??

    warning('Using fallback method for determining encoding direction! Please check!')
    try
        b = hdr.bval * 1e6; % s/m2
        u = hdr.bvec;
    catch
        b = hdr.B_value * 1e6; % s/m2
        u = hdr.DiffusionGradientDirection';
    end

    n = sqrt(b/max(b));

end








