clc, clear all ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters for define
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n2 = 10 ; % !!! in SNR dB
A = 1 ;     % sine amplitude
times = 1 ;% number of simulation times
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N = 16368 ;
fsig = 3000 ;

% storage for variance
w_delta = zeros(numel(n2), 1) ;
A_delta = zeros(numel(n2), 1) ;

tau1 = 1 ;
tau2 = 2 ;

Nnw = 15 ;
z2 = zeros(Nnw, 1) ;

for i=1:numel(n2)
    fprintf('Stage %d dB\n', n2) ;
    for j=1:times
        x = A*cos(2*pi*fsig/16368*(0:N-1));
        signoise = 10^(-n2(i)/10)*var(x) ;
        x = x + randn(1,N)*sqrt(signoise) ;
        rxx = [x*circshift(x',tau1) ; x*circshift(x',tau2)] ;
        
        % Utilize Newton iterations to compute 
        % Signal Energy, Noise Energy and Frequency        
        
        % for 1 term
         z2(1) = [1000/16368*2*pi] ;
        %z2 = [1] ;
        
        tau = 1 ;
        for n=2:Nnw
            num = rxx(1)*cos(z2(n-1)*tau2) - rxx(2)*cos(z2(n-1)*tau1) ;
            denom = -tau2*rxx(1)*sin(z2(n-1)*tau2) + tau1*rxx(2)*sin(z2(n-1)*tau1);
            
            z2(n) = z2(n-1) - num/denom ;
        end

        freq = mod(z2(end)*16368/2/pi,16368/2);
        fprintf('Frequency: %.2f E=%.2f\n', freq, rxx(1) / cos(z2(end)*tau1) / N) ;        
        
        w_delta(i) = w_delta(i) + (fsig - mod(z2(end)*16368/2/pi,16368/2))^2 ;
        A_delta(i) = A_delta(i) + (rxx(1) / cos(z2(end)*tau1) / N - A^2/2)^2;
    end
    
    % normalie
    w_delta(i) = w_delta(i) / times ;
    A_delta(i) = A_delta(i) / times ;

end % for i=n(1):n(end)

r1 = A*cos(tau1*2*pi*fsig/16368) ;
r2 = A*cos(tau2*2*pi*fsig/16368) ;

alpha0 = tau1*2*pi*0/16368 ;
alpha1 = tau2*2*pi*16368/16368 ;
alpha = alpha0 : 0.01 : alpha1 ;

gamma1 = r1./cos(alpha) ; gamma1(abs(gamma1)>6) = NaN ;
gamma2 = r2./cos(tau2/tau1*alpha) ; gamma2(abs(gamma2)>6) = NaN ;

% FIXME - hack bcoz A^2 / 2 for A = 1 => Energy * 2
A_vals = rxx(1) ./ cos(z2(:)*tau1) ./ N .* 2 ;

hold off, plot( alpha/2/pi*16368/tau1, gamma1, 'LineWidth', 2 ) ;
hold on, plot( alpha/2/pi*16368/tau1, gamma2, 'm-', 'LineWidth', 2,'Color',[0 0.7 0.6] ) ;
hold on, plot(fsig,A,'^','Color',[.3 0.5 0.3],'MarkerSize',10,'LineWidth',2) ;
hold on, plot(z2(:)/2/pi*16368/tau1, A_vals, 'g-+','Color',[.8 0.1 0.1],'LineWidth',1) ;
xlim([0 8000]) ;
grid on ;

% dont want to plot a point
if numel(n2) == 1
    return;
end


if A>0
    figure(1), grid on,
        subplot(2,1,1),
            plot(n2, w_delta, '-mo'),
            title('freq estimation variance with signal 1 equation'),
            grid on, xlabel('SNR'), ylabel('Variance')
        subplot(2,1,2),
            plot(n2, A_delta, '-mo'),
            title('Energy estimation variance with signal 1 equation'),
            grid on, xlabel('SNR'), ylabel('Variance')
else
    figure(1)
        subplot(2,1,1),
            plot(n2, w_delta, '-mo'),
            title('freq estimation variance withOUT signal 1 equation'),
            grid on, xlabel('SNR'), ylabel('Variance'),
        subplot(2,1,2),
            plot(n2, A_delta, '-mo'),
            title('Energy estimation variance withOUT signal 1 equation'),
            grid on, xlabel('SNR'), ylabel('Variance'),
end