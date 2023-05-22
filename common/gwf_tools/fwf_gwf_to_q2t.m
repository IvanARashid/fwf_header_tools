function q2t = fwf_gwf_to_q2t(gwf, rf, dt, nuc)
% function q2t = fwf_gwf_to_q2t(gwf, rf, dt, nuc)

if nargin < 4
    nuc = [];
end

qt = fwf_gwf_to_qt(gwf, rf, dt, nuc);

q2t(:,1) = cumsum( qt(:,1).*qt(:,1), 1 ) * dt;
q2t(:,2) = cumsum( qt(:,2).*qt(:,2), 1 ) * dt;
q2t(:,3) = cumsum( qt(:,3).*qt(:,3), 1 ) * dt;
q2t(:,4) = cumsum( qt(:,1).*qt(:,2), 1 ) * dt;
q2t(:,5) = cumsum( qt(:,1).*qt(:,3), 1 ) * dt;
q2t(:,6) = cumsum( qt(:,2).*qt(:,3), 1 ) * dt;