function event = processEvents(t, accX, accY, accZ, gyroX, gyroY, gyroZ, gt, cut)
% find unique times
% From X-accel
[accX_2, t_unique] = unique(accX);
[t_2, t_unique] = unique(t(t_unique));
accX_2 = accX_2(t_unique);

% From Y-accel
[accY_2, t_unique] = unique(accY);
[t_2Y, t_unique] = unique(t(t_unique));
accY_2 = accY_2(t_unique);

% From Z-accel
[accZ_2, t_unique] = unique(accZ);
[t_2Z, t_unique] = unique(t(t_unique));
accZ_2 = accZ_2(t_unique);

% From X-gyro
[gyroX_2, t_unique] = unique(gyroX);
[t_2gX, t_unique] = unique(t(t_unique));
gyroX_2 = gyroX_2(t_unique);

% From Y-gyro
[gyroY_2, t_unique] = unique(gyroY);
[t_2gY, t_unique] = unique(t(t_unique));
gyroY_2 = gyroY_2(t_unique);

% From Z-gyro
[gyroZ_2, t_unique] = unique(gyroZ);
[t_2gZ, t_unique] = unique(t(t_unique));
gyroZ_2 = gyroZ_2(t_unique);

% resample to 100hz
t_100Hz = round(linspace(0, max(t_2), max(t_2)*100),3);
accX_100Hz = interp1(t_2, accX_2, t_100Hz,'makima');
accY_100Hz = interp1(t_2Y, accY_2, t_100Hz,'makima');
accZ_100Hz = interp1(t_2Z, accZ_2, t_100Hz,'makima');
gyroX_100Hz = interp1(t_2gX, gyroX_2, t_100Hz,'makima');
gyroY_100Hz = interp1(t_2gY, gyroY_2, t_100Hz,'makima');
gyroZ_100Hz = interp1(t_2gZ, gyroZ_2, t_100Hz,'makima');

% cut off start
t_100Hz = t_100Hz(cut:end);
accX_100Hz = accX_100Hz(cut:end);
accY_100Hz = accY_100Hz(cut:end);
accZ_100Hz = accZ_100Hz(cut:end);
gyroX_100Hz = gyroX_100Hz(cut:end);
gyroY_100Hz = gyroY_100Hz(cut:end);
gyroZ_100Hz = gyroZ_100Hz(cut:end);

% detrend
accX_det = detrend(accX_100Hz);
accY_det = detrend(accY_100Hz);
accZ_det = detrend(accZ_100Hz);
gyroX_det = detrend(gyroX_100Hz);
gyroY_det = detrend(gyroY_100Hz);
gyroZ_det = detrend(gyroZ_100Hz);

% filter
fc = 20; % cutoff, Hz
fs = 100; % sampling, Hz
n_order = 2;

[b,a] = butter(n_order, fc/(fs/2));
accX_filt = filtfilt(b, a, accX_det);
accY_filt = filtfilt(b, a, accY_det);
accZ_filt = filtfilt(b, a, accZ_det);
gyroX_filt = filtfilt(b, a, gyroX_det);
gyroY_filt = filtfilt(b, a, gyroY_det);
gyroZ_filt = filtfilt(b, a, gyroZ_det);

% moving mean
M_accX = movmean(accX_filt,21);
M_accY = movmean(accY_filt,21);
M_accZ = movmean(accZ_filt,21);
M_gyroX = movmean(gyroX_filt,21);
M_gyroY = movmean(gyroY_filt,21);
M_gyroZ = movmean(gyroZ_filt,21);

% find events
% peaks
[pks,locs, w, p] = findpeaks(M_gyroZ, MinPeakDistance=10, MinPeakHeight=1.1*mean(abs(M_gyroZ)));

% bounds (indexes)
Zbounds = zeros(length(locs)*2,1);

for i = 1:length(locs)
    Zbounds(2*i-1) = abs(round(locs(i)-w(i)));

    if round(locs(i)+w(i)) < length(M_accX)
        Zbounds(2*i) = abs(round(locs(i)+w(i)));
    else
        Zbounds(2*i) = length(M_accX);
    end
end

% characterize events
dat = [M_accX; M_accY; M_accZ; M_gyroZ; M_gyroX; M_gyroY].';

% mean
means = zeros(length(locs), 6);
% std
stds = zeros(length(locs), 6);
% med
meds = zeros(length(locs), 6);
% iqr
iqrs = zeros(length(locs), 6);
% kurtosis
kurts = zeros(length(locs), 6);
% skewness
skews = zeros(length(locs), 6);

for i = 1:length(locs)
    for j = 1:6
        means(i,j) = mean(dat(Zbounds(2*i-1):Zbounds(2*i),j));
        stds(i,j) = std(dat(Zbounds(2*i-1):Zbounds(2*i),j));
        meds(i,j) = median(dat(Zbounds(2*i-1):Zbounds(2*i),j));
        iqrs(i,j) = iqr(dat(Zbounds(2*i-1):Zbounds(2*i),j));
        kurts(i,j) = kurtosis(dat(Zbounds(2*i-1):Zbounds(2*i),j));
        skews(i,j) = skewness(dat(Zbounds(2*i-1):Zbounds(2*i),j));
    end  
end


% peak freq ?

% output: array with start time (left bound) + characterizations + GT
starts = t_100Hz(Zbounds(1:2:end)).';
gts = ones(length(starts),1)*gt(1);

event = [starts means stds meds iqrs kurts skews gts];

