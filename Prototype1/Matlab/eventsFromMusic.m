% This code identifies beats from an audio file

% Load the data
filename = "cymbal_tracks/thillana_p1_2.mp3";
[y,Fs] = audioread(filename);
t_audio = linspace(0, size(y,1)/Fs, size(y,1));

% file2 = "piece2.m4a";
% [y2,Fs2] = audioread(file2);
% t_audio2 = linspace(0, size(y2,1)/Fs2, size(y2,1));

%% Filter data - doesn't seem to help
fcutoff_LP = Fs/10;
[Bf, Af]=butter(2,fcutoff_LP/(Fs/2),'low');
y_filt = filtfilt(Bf, Af, y(:,1));

y_det = detrend(y);

%% Find peaks (easier to do this with the delta to find rising edges
min_peak_dist = 0.2*Fs;
% [pks,locs] = findpeaks(abs(y_filt),'MinPeakHeight', 0.5, 'MinPeakDistance', min_peak_dist);
[pks,locs] = findpeaks(y(:,1), 'MinpeakHeight', 0.5,'MinPeakDistance', min_peak_dist); % Using raw data
% [pks2,locs2] = findpeaks(diff(y2(:,1)),'MinPeakHeight', 0.5, 'MinPeakDistance', min_peak_dist); % Using raw data

%% Plot to check
figure; plot(t_audio, y(:,1),'LineWidth', 1)
% hold on; plot(t_audio, y_filt)
% hold on; plot(t_audio2, y2(:,1),'LineWidth', 1)
hold on; xline(t_audio(locs), 'r', 'LineWidth', 0.5)
% hold on; scatter(t_audio(locs), 0.5*ones(length(pks),1))
legend('Orig', 'Events')

% legend('1', '2')
xlabel('Time (s)');

%% Export as csv
writematrix([t_audio(locs)].','cymbal_tracks/bahudari_p2.csv')

