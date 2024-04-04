# Utility functions
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import neurokit2 as nk

import statistics
import pathlib

from scipy.signal import find_peaks
from scipy.ndimage import uniform_filter1d
from scipy.stats import kurtosis,skew
from scipy.interpolate import PchipInterpolator, CubicSpline, Akima1DInterpolator
import scipy.integrate as it

from sklearn.decomposition import PCA
from sklearn.manifold import TSNE

classes = {"walk": 0, "jump": 1, "spin": 2, "stamp": 3}
wfs = ['accel_X', 'accel_Y', 'accel_Z', 'gyro_X', 'gyro_Y', 'gyro_Z']
# artifact_rows = [26, 36] # have file names instead of just numbers
artifact_row_names = ['spin/spin_krithika_50_3_30seconds.csv','spin/spin_aarushi_25_3.csv']
  
# artifact_rows = [39,56,26, 22, 11, 36] #11 is questionable, ends early #36 is a new one


def convertTime(time):
    """
    Convert a timestamp string of the format hh:mm:ss into a float with units of seconds. 
    Note, if the timestamp string is not in military time, there will be information loss after crossing 12 noon. 
    This is because (and also note) the date of the timestamp is not taken into account.
    __________________________
    time: a timestamp string of the format hh:mm:ss
    
    returns ==> float of timestamp converted into seconds
    
    """
    hours, minutes, seconds = time.split(':')
    hours = int(hours)
    minutes = int(minutes)
    seconds = float(seconds)
    return hours * 3600 + minutes*60 + seconds

def find_FS(df):
    """
    For a given dataframe with a column with the name "Time", the number of rows or samples are counted
    Then, it is divided by the total time, as calculated as the difference between the start and end times.
    __________________________
    df: the dataframe with time series data
    
    returns ==> sampling frequency
    
    """
    samples = df.shape[0]
    s = df.Time.iloc[-1] - df.Time.iloc[0]
    return samples / s

def cleanRead(path, printout = False):
    """
    Basic pre-processing & reading csv file:
    
    Read a csv file from a given path, convert timestamp string into (float) seconds format, sort the values by time.
    Deletes first data point.
    Then, drop any rows with duplicate timestamps, and optionally print number of dropped samples
    __________________________
    path: filepath for the csv file to be read
    printout: optional param, true if you want to print number of dropped samples
    
    returns ==> pandas dataframe with info in csv file at given path
    
    """
    df = pd.read_csv(path)
    if type(df.Time.values[0]) is str:
        df["Time"] = df["Time"].apply(convertTime)
    df = df.sort_values("Time", ignore_index=True)
    df = df.iloc[1:]
    initialNumRows = df.shape[0]
    df = df.drop_duplicates(subset=['Time']) #new addition
    df = df.reset_index(drop=True)
    if printout:
        print(f"{initialNumRows - df.shape[0]} value(s) with the same timestamp has been dropped")
    return df

def removeDuplicatePeaks(info):
    """
    Helper function for countPeaks function.
    Designed to work in conjunction with the 'signal_findpeaks' function in the Neurokit2 library. 
    If the Offset of one peak is the same as the onset as another peak, there is assumed to be a duplicate count of peaks.
    The one with the lower height is removed.
    __________________________
    info: info dictionary returned from the 'signal_findpeaks' function in the Neurokit2 library
    
    return ==> dataframe with same information as input dictionary but with the duplicate peaks (rows) removed
    
    """
    
    a = info['Onsets'][1:]
    b = info['Offsets'][:-1]

    duplicate = [list(b).index(n) for m, n in zip(a, b) if n == m]

    deleteThese = [i + np.argmin([info['Height'][i],info['Height'][i+1]]) for i in duplicate]
    newInfo = pd.DataFrame(info).drop(deleteThese).reset_index(drop=True)
    
    return newInfo

def find_outliers_IQR(newInfo, threshold = 0.75, index = True):
    """
    Ignore for now
    
    """
    df = pd.Series([j-i for i, j in zip(newInfo.Peaks.values[:-1], newInfo.Peaks.values[1:])])
    q1 = df.quantile(0.25)
    q3 = df.quantile(0.75)
    IQR = q3-q1
#     print(q1,q3,IQR)
    outliers = df[((df<(q1-threshold*IQR)))]
    idx = np.where(df<(q1-threshold*IQR))[0]
    return idx if index else (outliers, idx)

def removeOutliers(newInfo, threshold = 0.75):
    """
    Ignore for now
    
    """
    idx = find_outliers_IQR(newInfo, threshold)
    deleteThese = [i + np.argmin([newInfo['Height'][i],newInfo['Height'][i+1]]) for i in idx]
    cleanInfo = pd.DataFrame(newInfo).drop(deleteThese).reset_index(drop=True)
    
    return cleanInfo

def countPeaks(filtered, x = None, rel_height_min = None,height_min=None, bounds=False): #maybe rel_height should be changed to .25? or sumn?
    """
    Function that given a filtered waveform, will return the number of peaks (among other stuff) after removing duplicate counts.
    These duplicates are defined by the 'removeDuplicatePeaks' function.
    __________________________
    filtered: filtered waveform
    x: (optional) associated time or x-axis values accompanying filtered waveform
    rel_height_min: (optional) minimum relative height to count peaks in Neurokit2's 'signal_findpeaks' function
    
    returns ==> numPeaks: Number of peaks counted after removing duplicates
                numDuplicates: Number of duplicate peaks removed
                New_peak_x: X-values of all peaks (after duplicates removed)
                New_peak_y: Y-values of all peaks (after duplicates removed)
                peak_x: X-values of all peaks (before duplicates removed)
                peak_y: Y-values of all peaks (before duplicates removed)
    
    """
    info = nk.signal_findpeaks(filtered, relative_height_min = rel_height_min, height_min = height_min)
    
    peak_y = filtered[info["Peaks"]]
    newInfo = removeDuplicatePeaks(info)
    
    New_peak_y = filtered[newInfo.Peaks.values]
    numPeaks = len(New_peak_y)
    numDuplicates = len(peak_y) - numPeaks
    
    if (not x is None):
        peak_x = x[info["Peaks"]]
        New_peak_x = x[newInfo.Peaks.values]
        
        if bounds:
            return numPeaks, numDuplicates, New_peak_x, New_peak_y, peak_x, peak_y, x[info['Onsets']], filtered[info['Onsets']], x[info['Offsets']], filtered[info['Offsets']], info
        else:
            return numPeaks, numDuplicates, New_peak_x, New_peak_y, peak_x, peak_y
    
    
    
    return numPeaks, numDuplicates

def readCSV(drop=True, path = './'):
    files = pd.DataFrame()
    csvList = [str(csv_file) for csv_file in pathlib.Path(path).glob('**/*.csv')]
    files['path'] = csvList
    try:
        # CHANGE: If Mac, use split('/'); if Windows, use split('\\')
        GT = [classes[path.split('/')[0].split('_')[0]] for path in files.path.values]
    except:
        print('NO AVAILABLE GROUND TRUTHS; SETTING VALUE TO -1')
        GT = -1
    files['GT'] = GT
    if drop:
        artifact_rows = [np.where(files.path.values == badfile)[0][0] for badfile in artifact_row_names]
        print(artifact_rows)
        files.drop(artifact_rows, inplace=True, )
        files.reset_index(inplace=True, drop=True)
    return files


def filterBetween(data,met,start,stop, filtering=True):
    reltime = data.Time.values
    wf = data[met].values
    if filtering:
        wf = nk.signal_filter(wf,highcut = 100, method="butterworth",order=2)  
    return wf[np.where((reltime>=start) & (reltime<stop))[0]]

def imuProcess(df, intervalTime = 10, stats = ['med_','std_','mean_','q1_','q3_','kurt_','skew_'], mets = ['accel_X','accel_Y','accel_Z','gyro_X','gyro_Y', 'gyro_Z'], integrate = False):
    feature_names = []
    #ADD A LINE THAT UPDATES MET TO INCLUDE INTEGRATION STUFF IF INTEGRATE IS TRUE 
    for met in mets:
        for stat in stats:
            feature_names.append(stat+met)
    individualTrials = []
    GT = {'GT': []}
    #### File by file analysis ####
    for filepath, groundTruth in zip(df.path.values,df.GT.values):

        data = cleanRead(filepath)
        if integrate:
            data = addIntegralsToData(data)
        time = data.Time.values
        try:
            reltime = time - time[0]
        except:
            print(filepath, time)
        data['Time'] = reltime
        
        endTime, catchTime = (30, 35) if '30seconds' in filepath else (60,65)
        
        
        pairs = subWindowTimes(intervalTime, end = endTime, catch=catchTime)
        for start, stop in pairs:
#             subData = data.iloc[np.where((reltime>=start) & (reltime<stop))[0]]
            ds = {k: [] for k in feature_names}
#             try:
            for met in mets:
                #FILTER
                thing = filterBetween(data,met,start,stop)
                ds['med_' + met].append(np.median(thing))
                ds['std_'+ met].append(np.std(thing))
                ds['mean_'+ met].append(np.mean(thing))
                ds['q1_'+ met].append(np.quantile(thing,.25))
                ds['q3_'+ met].append(np.quantile(thing,.75))
                if ('kurt_' in stats) and ('skew_' in stats):
                    if pd.isna(kurtosis(thing)):
                        print(filepath)
                    ds['kurt_'+ met].append(kurtosis(thing))
                    ds['skew_'+ met].append(skew(thing))
#             except:
#                 print('ERROR: {filepath}, {start},{stop}')
            GT['GT'].append(groundTruth)
            subResult = pd.DataFrame(ds)
            individualTrials.append(subResult)
            
    result = pd.concat(individualTrials)
    result.reset_index(inplace=True, drop=True)
    return result, GT['GT']

def dimReduction(X, y, mode = 'tsne', giveData = False):
    if mode == 'pca':
        method = PCA(n_components=2)
        X_2D = method.fit_transform(X)
    elif mode == 'tsne':
        method = TSNE(n_components=2, random_state=42)
        X_2D = method.fit_transform(X)
    else:
        print('ERROR: mode must be either pca or tsne')
        return
    
    #Walk
    plt.scatter(x=X_2D[np.where(np.array(y) == classes["walk"])[0], 0], y=X_2D[np.where(np.array(y) == classes["walk"])[0], 1], color='r')

    #Jump
    plt.scatter(x=X_2D[np.where(np.array(y) == classes["jump"])[0], 0], y=X_2D[np.where(np.array(y) == classes["jump"])[0], 1], color='g')

    #Spin
    plt.scatter(x=X_2D[np.where(np.array(y) == classes["spin"])[0], 0], y=X_2D[np.where(np.array(y) == classes["spin"])[0], 1], color='b')

    #Stamp
    plt.scatter(x=X_2D[np.where(np.array(y) == classes["stamp"])[0], 0], y=X_2D[np.where(np.array(y) == classes["stamp"])[0], 1], color='k')

    plt.show()
    
    if giveData:
        return X_2D, method
    else:
        return
    
def subWindowTimes(interval, start=0,end=60, catch = 65):
    l = np.arange(start, end , interval)
    l = np.append(l,65)
    pairs = [[first, second] for first, second in zip(l, l[1:])]
    return pairs

def addIntegralsToData(data):
    for thing in ['gyro_X', 'gyro_Y', 'gyro_Z']:
        temp_int1 = it.cumtrapz(data[thing].values,data.Time.values)
        temp_int2 = it.cumtrapz(temp_int1,data.Time.values[1:])
        
        temp_int1 = np.append(temp_int1, temp_int1[-1])
        temp_int2 = np.append(temp_int2, temp_int2[-1])
        temp_int2 = np.append(temp_int2, temp_int2[-1])
        
        data[f'int1_{thing}'] = temp_int1
        data[f'int2_{thing}'] = temp_int2
    return data

def getMovAvg_bare(data_vis, wf, windowSize=3, filtering=True):
    if filtering:
        filtered_vis = nk.signal_filter(data_vis[wf].values,highcut = 100, method="butterworth",order=2)
    else:
        filtered_vis = data_vis[wf].values
    mov_avg_vis = uniform_filter1d(filtered_vis, size=windowSize)
    time_x = data_vis.Time.values - data_vis.Time.values[0]
    return time_x, mov_avg_vis

def rollingSTD(arr,size = 3,xb = None):
    xbar = np.mean(arr) if xb is None else xb
    L = arr
    num = size
    ans = np.array([statistics.stdev(L[i:i+num], xbar) for i in range(0,len(L)-(num-1))])
    for a in range(size-1):
        ans = np.append(ans,ans[-1])
    return ans

def findBounds(df, mode = 'mult', fat_avg = 15, std_window = 5, interp = 'pchip', separate_xy = True, prom = 0.2, peakFinding = 'scipy'):
    time, acc_X = getMovAvg_bare(df, 'accel_X')
    _, acc_Y = getMovAvg_bare(df, 'accel_Y')
    _, acc_Z = getMovAvg_bare(df, 'accel_Z')

    _, gyro_X = getMovAvg_bare(df, 'gyro_X')
    _, gyro_Y = getMovAvg_bare(df, 'gyro_Y')
    _, gyro_Z = getMovAvg_bare(df, 'gyro_Z')
    mult = acc_Z*acc_X*acc_Y*gyro_X*gyro_Y*gyro_Z
    dMult = np.gradient(mult)
    ddMult = np.gradient(dMult)
    prod = dMult * ddMult
    
    options = {'mult': mult,'prod':prod,'acc_X': acc_X,'acc_Y': acc_Y,'acc_Z': acc_Z,'gyro_X': gyro_X,'gyro_Y': gyro_Y,'gyro_Z': gyro_Z}
    
    interest = uniform_filter1d(rollingSTD(nk.standardize(options[mode]),std_window),fat_avg)
    if peakFinding == 'nk':
        arr = nk.signal_findpeaks(interest,relative_height_min=prom)['Peaks']
        arr_trough = nk.signal_findpeaks(-interest,relative_height_min=prom)['Peaks']
    else:
        arr, prop = find_peaks(interest,prominence=prom)
        arr_trough, prop_trough = find_peaks(-interest,prominence=prom)
    
    points_x = np.concatenate([[time[0]],time[arr],time[arr_trough],[time[-1]]])
    points_y = np.concatenate([[interest[0]],interest[arr],interest[arr_trough],[interest[-1]]])
    tup = list(zip(points_x, points_y))
    tup.sort(key = lambda x: x[0])
    points_x, points_y = zip(*tup)
    
    
    xs = np.arange(0, time[-1], 0.01) # maybe the step can be made smaller???
    if interp == 'pchip':
        pchip = PchipInterpolator(points_x,points_y)
        ys = pchip(xs)
    elif interp == 'akima':
        akima = Akima1DInterpolator(points_x,points_y) #seems to work best
        ys = akima(xs)
    elif interp == 'cubicspline':
        cs = CubicSpline(points_x,points_y)
        ys = cs(xs)
    else:
        ys = np.interp(xs,points_x,points_y)

    res = pd.DataFrame(nk.signal_findpeaks(ys))
    res.loc[0,'Onsets'] = 0
    res.loc[res.index.values[-1],'Offsets'] = len(ys)-1
    
    left_x = xs[[int(a) for a in res.Onsets.values]]
    right_x = xs[[int(a) for a in res.Offsets.values]]
    return (left_x,right_x) if separate_xy else list(zip(left_x,right_x))

def findBounds_realtime(df, mode = 'mult', fat_avg = 15, std_window = 5, interp = 'pchip', separate_xy = True, prom = 0.2, peakFinding = 'nk'):
    time, acc_X = getMovAvg_bare(df, 'accel_X', filtering=False)
    _, acc_Y = getMovAvg_bare(df, 'accel_Y', filtering=False)
    _, acc_Z = getMovAvg_bare(df, 'accel_Z', filtering=False)

    _, gyro_X = getMovAvg_bare(df, 'gyro_X', filtering=False)
    _, gyro_Y = getMovAvg_bare(df, 'gyro_Y', filtering=False)
    _, gyro_Z = getMovAvg_bare(df, 'gyro_Z', filtering=False)
    mult = acc_Z*acc_X*acc_Y
    dMult = np.gradient(mult)
    ddMult = np.gradient(dMult)
    prod = dMult * ddMult
    
    options = {'mult': mult,'prod':prod,'acc_X': acc_X,'acc_Y': acc_Y,'acc_Z': acc_Z,'gyro_X': gyro_X,'gyro_Y': gyro_Y,'gyro_Z': gyro_Z}
    
#     interest = uniform_filter1d(rollingSTD(nk.standardize(options[mode]),std_window),fat_avg)
    interest = mult
    if peakFinding == 'nk':
        arr = nk.signal_findpeaks(interest,relative_height_min=prom)['Peaks']
        arr_trough = nk.signal_findpeaks(-interest,relative_height_min=prom)['Peaks']
    else:
        arr, prop = find_peaks(interest,prominence=prom)
        arr_trough, prop_trough = find_peaks(-interest,prominence=prom)
    
    points_x = np.concatenate([[time[0]],time[arr],time[arr_trough],[time[-1]]])
    points_y = np.concatenate([[interest[0]],interest[arr],interest[arr_trough],[interest[-1]]])
    tup = list(zip(points_x, points_y))
    tup.sort(key = lambda x: x[0])
    points_x, points_y = zip(*tup)
    
    
    xs = np.arange(0, time[-1], 0.01) # maybe the step can be made smaller???
    if interp == 'pchip':
        pchip = PchipInterpolator(points_x,points_y)
        ys = pchip(xs)
    elif interp == 'akima':
        akima = Akima1DInterpolator(points_x,points_y) #seems to work best
        ys = akima(xs)
    elif interp == 'cubicspline':
        cs = CubicSpline(points_x,points_y)
        ys = cs(xs)
    else:
        ys = np.interp(xs,points_x,points_y)

    res = pd.DataFrame(nk.signal_findpeaks(ys))
    res.loc[0,'Onsets'] = 0
    res.loc[res.index.values[-1],'Offsets'] = len(ys)-1
    
    left_x = xs[[int(a) for a in res.Onsets.values]]
    right_x = xs[[int(a) for a in res.Offsets.values]]
    return (left_x,right_x) if separate_xy else list(zip(left_x,right_x))

def tightBounds(df, step_size = 0.01,int_size = 2.5,mode = 'mult', fat_avg = 15, std_window = 5, interp = 'pchip', prom = 0.2, peakFinding = 'nk', separate_lr = True, realtime=False):
    if realtime:
        coords = findBounds_realtime(df, mode, fat_avg, std_window, interp, False, prom, peakFinding)
    else:
        coords = findBounds(df, mode, fat_avg, std_window, interp, False, prom, peakFinding)

    temp = []
    step = step_size
    interval_size = int_size
    for start, stop in coords:


        if (stop - start) > interval_size:
            L = df.accel_X.values
            time = df.Time.values - df.Time.values[0]

            l = np.arange(start, stop , step)
            intervals = np.array(list(zip(l,l+interval_size)))
            intervals = intervals[np.where(l+interval_size <stop)]
            intervals = np.append(intervals,np.array([[stop-interval_size,stop]]), axis=0)


            stds = [np.std(L[np.where((time >= left) & (time<=right))]) for left,right in intervals]
            max_idx = np.argmax(stds)
            temp.append(intervals[max_idx])
    #         print(intervals[max_idx])
        else:
            temp.append(np.array([start,stop]))
    #         print(f'start:{start}, stop:{stop}')
    lef, rig = zip(*temp)
    return (lef, rig) if separate_lr else temp

def imuProcess_event(df, intervalTime = 1, stats = ['med_','std_','mean_','q1_','q3_','kurt_','skew_'], mets = ['accel_X','accel_Y','accel_Z','gyro_X','gyro_Y', 'gyro_Z'], integrate = False, partial = 1):
    feature_names = []
    individualTrials = []
    GT = {'GT': []}
    for met in mets:
        for stat in stats:
            feature_names.append(stat+met)       
    
    #### File by file analysis ####
    for filepath, groundTruth in zip(df.path.values,df.GT.values):
        data = cleanRead(filepath)
        time = data.Time.values
        try:
            reltime = time - time[0]
        except:
            print(filepath, time)
        data['Time'] = reltime
        try:
            pairs = tightBounds(data,mode='mult',fat_avg = 15, prom=.2, peakFinding='scipy', int_size=intervalTime, step_size=0.05, separate_lr=False)
        except:
            print(filepath)
        for start, stop in pairs:
            stop = start + partial
            ds = {k: [] for k in feature_names}
            for met in mets:
                #FILTER
                thing = filterBetween(data,met,start,stop)
                ds['med_' + met].append(np.median(thing))
                ds['std_'+ met].append(np.std(thing))
                ds['mean_'+ met].append(np.mean(thing))
                ds['q1_'+ met].append(np.quantile(thing,.25))
                ds['q3_'+ met].append(np.quantile(thing,.75))
                if ('kurt_' in stats) and ('skew_' in stats):
                    if pd.isna(kurtosis(thing)):
                        print(filepath)
                    ds['kurt_'+ met].append(kurtosis(thing))
                    ds['skew_'+ met].append(skew(thing))
            GT['GT'].append(groundTruth)
            subResult = pd.DataFrame(ds)
            individualTrials.append(subResult)
            
    result = pd.concat(individualTrials)
    result.reset_index(inplace=True, drop=True)
    return result, GT['GT']

def imuProcess_event_realtime(data, intervalTime = 1, stats = ['med_','std_','mean_','q1_','q3_','kurt_','skew_'], mets = ['accel_X','accel_Y','accel_Z','gyro_X','gyro_Y', 'gyro_Z'], partial = 1):
    feature_names = []
    individualTrials = []
    for met in mets:
        for stat in stats:
            feature_names.append(stat+met)       

    time = data.Time.values
    try:
        reltime = time - time[0]
    except:
        print('ERROR in time')
    data['Time'] = reltime
    try:
        pairs = tightBounds(data,mode='mult',fat_avg = 15, prom=.2, peakFinding='scipy', int_size=intervalTime, step_size=0.05, separate_lr=False, realtime=False)
    except:
        print('ERROR in bounds')
        
    for start, stop in pairs:
        stop = start + partial
        ds = {k: [] for k in feature_names}

        #HANDLE NO MOVEMENTS:

        time, acc_X = getMovAvg_bare(data, 'accel_X')
        _, acc_Y = getMovAvg_bare(data, 'accel_Y')
        _, acc_Z = getMovAvg_bare(data, 'accel_Z')
        mult = acc_Z*acc_X*acc_Y
        if np.std(mult) < 50:
            continue

        for met in mets:
            #FILTER
            thing = filterBetween(data,met,start,stop, True)
            ds['med_' + met].append(np.median(thing))
            ds['std_'+ met].append(np.std(thing))
            ds['mean_'+ met].append(np.mean(thing))
            ds['q1_'+ met].append(np.quantile(thing,.25))
            ds['q3_'+ met].append(np.quantile(thing,.75))
            if ('kurt_' in stats) and ('skew_' in stats):
                if pd.isna(kurtosis(thing)):
                    print('ERROR KURTOSIS')
                ds['kurt_'+ met].append(kurtosis(thing))
                ds['skew_'+ met].append(skew(thing))
        subResult = pd.DataFrame(ds)
        individualTrials.append(subResult)
    result = pd.DataFrame() if len(individualTrials) == 0 else pd.concat(individualTrials)
    result.reset_index(inplace=True, drop=True)
    # print(data)
    return result

def lowFS_interpolate(df_segment, step=1/30):
    xs = np.arange(df_segment.Time.values[0], df_segment.Time.values[-1], step) # maybe the step can be made smaller???
    df_segment_interp = pd.DataFrame({'Time':xs})

    for wf in df_segment.columns.values[-6:]:
        akima = Akima1DInterpolator(df_segment.Time.values,df_segment[wf].values)
        ys = akima(xs)
        df_segment_interp[wf] = ys

    return df_segment_interp

def calcDelays(df):
    left_x, right_x = tightBounds(df,mode='mult',fat_avg = 15, prom=.2, peakFinding='scipy', int_size=1, step_size=0.05)
    lx = [int(1000*x) for x in left_x]
    diffs = [t - s for s, t in zip(lx, lx[1:])]
    diffs = np.insert(diffs, 0, lx[0], axis=None)
    return diffs