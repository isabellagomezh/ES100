clc
clear
%%
% emg = readtable("elbow_flex_ext/elbow_flex_from90_Proprioception_Tests_Rep_1.2 - elbow_flex_from90_Proprioception_Tests_Rep_1.2.csv");
imu = readtable("final_tests/jerry_arm_ext_flex_90Hz.csv");

%%

% fs = 1/median(rmmissing(diff(emg.X_s_)));
% fs = 5000; % emg sampling freq
fs = 83; % xiao sampling freq

figure; plotfft(imu.gY, fs);
xlabel('Frequency (Hz)')
ylabel('Magnitude')
title('Magnitude')

%%
% y = fft(imu.aX1);
% fs = 55;
% f = (0:length(y)-1)*fs/length(y);
% plot(f,abs(y))
% xlabel('Frequency (Hz)')
% ylabel('Magnitude')
% title('Magnitude')

%% Helper functions
function plotfft(y, Fs)
L = length(y);    
Y = fft(y);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L;
hold on; plot(f,P1)
title('Single-Sided Amplitude Spectrum of Active Data')
xlabel('f (Hz)')
ylabel('|P1(f)|')
end