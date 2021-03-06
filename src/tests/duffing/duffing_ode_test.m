function s_ode_3()
clc ;

savefile = 'ode_h.mat' ;
load(savefile, 'h') ;

h

x0=[1;1];

tspan=[0:0.01:150];
[t,x]=ode45(@eq1,tspan,x0);

clf; figure(1), plot(x(:,1),x(:,2)), grid on; % hold on, comet(x(:,1),x(:,2)) ;
fprintf('Variance duff %f\n', var(x(:,1)));

gamma = 1 ;

f = gamma * cos(1*tspan) ;
f = f(50:2500) ;
y = x(50:2500,1) ;

r = zeros(size(y)) ;
for n=26:length(y)
    r(n) = h(1) + h(2)*f(n) + h(3)*f(n)*f(n) + h(4)*f(n)*f(n)*f(n) + h(5)*f(n-1) + h(6)*f(n-1)*f(n-1) + h(7)*f(n-1)*f(n-1)*f(n-1) + ...
        h(8)*f(n)*f(n-1) + h(9)*f(n)*f(n-1)*f(n-1) + h(10)*f(n)*f(n)*f(n-1) + ...
        h(11)*f(n-2) + h(12)*f(n-3) + h(13)*f(n-4) + h(14)*f(n-5) + h(15)*f(n-6) + h(16)*f(n-7) + h(17)*f(n-8) + h(18)*f(n-9) + ...
        h(19)*f(n-10) + h(20)*f(n-11) + h(21)*f(n-12) + h(22)*f(n-13) + h(23)*f(n-14) + h(24)*f(n-15) + h(25)*f(n-16) + h(26)*f(n-17) + ...
        h(27)*f(n-18) + h(28)*f(n-19) + h(29)*f(n-20) + h(30)*f(n-21) + h(31)*f(n-22) + h(32)*f(n-23) + h(33)*f(n-24) + h(34)*f(n-25) ;
end
fprintf('Variance volterra %f\n', var(r));

figure(2), hold off,plot(y), hold on,plot(r,'r-'), legend('duffing', 'volterra');

function f = eq1(t,x)
%fprintf('t:%f\n',t);
gamma = 1 ;
w = 1 ;
k = 0.5 ;
f=[x(2); -k*x(2) + x(1) - x(1)^3 + gamma*cos(w*t)] ;