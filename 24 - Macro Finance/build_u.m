function u = build_u(v, M, rho)
    % Compute the utility function u(v) based on the valuation equation
    % Inputs:
    %   v - vector of vartheta values at each grid point
    %   M - M matrix from build_M
    %   rho - discount rate

    % Compute the matrix-vector product M*v
    Mv = M * v;

    % Compute u(v) as per the rearranged money valuation equation
    u = rho * v - Mv;
end