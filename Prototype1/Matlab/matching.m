%% import files
filename = "thillana/thillana.mp3";
[y,Fs] = audioread(filename);
t_audio = linspace(0, size(y,1)/Fs, size(y,1));

song = readtable('thillana/thillana1.csv');

rleg = readtable('thillana/d1_rleg.csv');
lleg = readtable('thillana/d1_lleg.csv');

%% plot
tiledlayout(4,1)
nexttile; plot(t_audio, y(:,1),'LineWidth', 1);
nexttile; xline(table2array(song(:,1)));
nexttile; xline(table2array(lleg(:,1)));
nexttile; xline(table2array(rleg(:,1)));



