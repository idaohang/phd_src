% Copyright (C)
%   2012 Alex Nikiforov  nikiforov.alex@rf-lab.org
%	2012 Alexey Melnikov  melnikov.alexey@rf-lab.org
%
% Solve Duffing attractor with Runge-Kutta
% x'' + kx' - x^3 + x^5 = gamma*cos(wt) + gamma_x*cos(w_x*t) + n
% (gamma_x*cos(w_x*t) + n) - incominf signal
% GPLv3
function runge_kutta()
clc;

global delta_t;
global k;

k = 0.5 ;

delta_t = 0.005;
t = 0:delta_t:500;
x = zeros(length(t) + 1, 2) ;
x(1, 1) = 1;
x(1, 2) = 1;

for iter = 1:length(t)
    x(iter + 1, :) = step(t(iter), x(iter, :));
end % for

clf; figure(1), plot(x(:,1),x(:,2)), 
    xlabel('x'), ylabel('y'),
    grid on; %, hold on, comet(x(:,1),x(:,2));

spectrum = pwelch(x(:, 1));
spectrum = spectrum .* conj(spectrum);
figure(2), plot(spectrum), grid on;
    
    
% Incoming parameters:
%   t - current time
%   x(1) - x
%   x(2) - x'
% Return parameters:
%   y(1) - y
%   y(2) - y'
function y = step(t, x)

global k;
global delta_t;

gamma = 2 * randn(1) ;

% calculate Runge-Kutta step
k1 =    gamma + ...
        x(1)^3 - x(1)^5 - ...
        k*x(2) ;
    
x_tmp = x(1) + x(2) * delta_t / 2 ;
x_der = x(2) + k1 / 2 ;
k2 =    gamma + ...
        x_tmp - x_tmp^3 - ...
        k*x_der ;
    
x_tmp = x(1) + x(2) * delta_t / 2 + k1/4 * delta_t ;
x_der = x(2) + k2 / 2 ;
k3 =    gamma + ...
        x_tmp - x_tmp^3 - ...
        k*x_der;
        
x_tmp = x(1) + x(2) * delta_t + k2/2 * delta_t;
x_der = x(2) + k3 ;
k4 =    gamma + ...
        x_tmp - x_tmp^3 - ...
        k*x_der ;

y(1) = x(1) + delta_t * (x(2) + delta_t/6 * (k1 + k2 + k3)) ;
y(2) = x(2) + delta_t/6 * (k2 + 2*k2 + 2*k3 + k4) ;