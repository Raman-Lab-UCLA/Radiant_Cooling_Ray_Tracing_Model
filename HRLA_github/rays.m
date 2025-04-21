function [X,Y,Z] = rays(N)
%N is the number of points spread across the entire surface area of the sphere
%   updated this function with improvements from ChatGPT

% Golden ratio
phi = (1 + sqrt(5)) / 2;

% Indices
i = 1:N;

% Spherical coordinates
theta = 2 * pi * i / phi;
z = 1 - (2 * i - 1) / N;
r = sqrt(1 - z.^2);

% Cartesian coordinates
X = r .* cos(theta);
Y = r .* sin(theta);
Z = z;



end