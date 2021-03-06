clc, clear all ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters for define
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n2 = -5:15 ; % !!! in SNR dB
A = 1 ;     % sine amplitude
times = 100 ;% number of simulation times
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N = 16368 ;
fsig = 3000 ;

% storage for variance
w_delta = zeros(numel(n2), 1) ;
A_delta = zeros(numel(n2), 1) ;

% analitycal data storage
wa_delta = zeros(numel(n2), 1) ;
Aa_delta = zeros(numel(n2), 1) ;

tau1 = 1 ;
tau2 = 2 ;

Nnw = 5 ;
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
         z2(1) = [2000/16368*2*pi] ;
        %z2 = [1] ;
        
        tau = 1 ;
        for n=2:Nnw
            num = rxx(1)*cos(z2(n-1)*tau2) - rxx(2)*cos(z2(n-1)*tau1) ;
            denom = -tau2*rxx(1)*sin(z2(n-1)*tau2) + tau1*rxx(2)*sin(z2(n-1)*tau1);
            
            z2(n) = z2(n-1) - num/denom ;
        end

        freq = mod(z2(end)*16368/2/pi,16368/2);
        fprintf('Frequency newton: %.2f E=%.2f\n', freq, rxx(1) / cos(z2(end)*tau1) / N) ;        
        
        w_delta(i) = w_delta(i) + (fsig - mod(z2(end)*16368/2/pi,16368/2))^2 ;
        A_delta(i) = A_delta(i) + (rxx(1) / cos(z2(end)*tau1) / N - A^2/2)^2;
        
        % analitycal solve
        D = rxx(2)^2 + 8*rxx(1)^2 ;
        y1 = (rxx(2) + sqrt(D)) / (4*rxx(1)) ;
        y2 = (rxx(2) - sqrt(D)) / (4*rxx(1)) ;

        %2*rxx(1)*y1^2 - rxx(2)*y1 - rxx(1) ;
        %2*rxx(1)*y2^2 - rxx(2)*y2 - rxx(1) ;

        freq11 = 0;
        freq12 = 0;
        if tau1 == 1
            if (y1>1)
                y1 = y2 ;
            end
            freq11 = mod(acos(y1)*16368/2/pi,16368/2) ;
        else
            freq11 = mod(acos(y1)*16368/2/pi,16368/2) ;
            freq12 = mod(acos(y2)*16368/2/pi,16368/2) ;
        end

        fprintf('Frequency analytic: %.2f %.2f E=%.2f\n', freq11, freq12, rxx(1) / y1 / N) ;
        
        wa_delta(i) = wa_delta(i) + (fsig - mod(acos(y1)*16368/2/pi,16368/2))^2 ;
        Aa_delta(i) = Aa_delta(i) + (rxx(1) / y1 / N - A^2/2)^2 ;

    end %    for j=1:times
    
    % normalie
    w_delta(i) = w_delta(i) / times ;
    A_delta(i) = A_delta(i) / times ;
    
    wa_delta(i) = wa_delta(i) / times ;
    Aa_delta(i) = Aa_delta(i) / times ;

end % for i=n(1):n(end)


% dont want to plot a point
if numel(n2) == 1
    r1 = A*cos(tau1*2*pi*fsig/16368) ;
    r2 = A*cos(tau2*2*pi*fsig/16368) ;

    alpha0 = 0 ;
    alpha1 = pi ;
    alpha = alpha0 : 0.01 : alpha1 ;

    gamma1 = r1*cos(tau2*alpha) - r2*cos(tau1*alpha) ; %gamma1(abs(gamma1)>7) = NaN ;

    % FIXME - hack bcoz A^2 / 2 for A = 1 => Energy * 2
    A_vals = rxx(1) ./ cos(z2(:)*tau1) ./ N .* 2 ;

    hold off, plot(alpha/2/pi*16368, gamma1, 'LineWidth', 2) ;
    hold on, plot(fsig, 0, '^','Color',[.3 0.5 0.3],'MarkerSize',10,'LineWidth',2) ;
    hold on, plot([freq11; freq12], 0, '*','Color',[1 0.0 0.0],'MarkerSize',10,'LineWidth',2) ;
    hold on, plot(z2(:)/2/pi*16368, zeros(numel(z2), 1), 'g-+','Color',[.8 0.1 0.1],'LineWidth',1) ;
    xlim([0 8000]), xlabel('�������, ��', 'Fontsize', 14), ylabel('A', 'Fontsize', 14) ; 
    title(sprintf('�������� ������ ������� ����������� ��������� 14, �������� %d � %d', tau1, tau2), ...
            'Fontsize', 14);
    legend('�������', '������� �������', ...
            '������ ������� ������������� �������', ...
            '������ ������� ������������� �������', ...
            '������ ������� ������� �������')
    grid on ;

    return;
end


if A>0
    figure(1), grid on,
        subplot(2,1,1),
            plot(n2, w_delta, '-mo', n2, wa_delta, '-rx'),
            title('������ ������� ������� ��� ��� ����������� ��� ��������� 12', 'Fontsize', 14),
            grid on, xlabel('���', 'Fontsize', 14), ylabel('���', 'Fontsize', 14)
            legend('������', '������������� �������');
        subplot(2,1,2),
            plot(n2, A_delta, '-mo', n2, Aa_delta, '-rx'),
            title('������ ������� ������� ��� ��� ����������� ��� ��������� 12', 'Fontsize', 14),
            grid on, xlabel('���', 'Fontsize', 14), ylabel('���', 'Fontsize', 14),
            legend('������', '������������� �������');
else
    figure(1)
        subplot(2,1,1),
            plot(n2, w_delta, '-mo'),
            title('freq estimation variance withOUT signal 1 equation'),
            grid on, xlabel('SNR'), ylabel('���'),
        subplot(2,1,2),
            plot(n2, A_delta, '-mo'),
            title('Energy estimation variance withOUT signal 1 equation'),
            grid on, xlabel('���'), ylabel('���'),
end