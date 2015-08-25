%% Read SPM8 data and convert into .mat 
clc;clear all;close all;

[filename, pathname] = uigetfile;
name        = [pathname,filename];

D           = spm_eeg_load(name);
EEG         = D(D.meegchannels,:,:);
hdr         = ft_read_header(name);

trig1       = find(cell2mat({hdr.orig.trials.label})=='1');
trig2       = find(cell2mat({hdr.orig.trials.label})=='3');

trig1       = find(cell2mat({hdr.orig.trials.label})=='1');
trig2       = find(cell2mat({hdr.orig.trials.label})=='3');

channel     = hdr.label(1:128,:);

EEG_std     = EEG(:,:,trig1);
EEG_trg     = EEG(:,:,trig2);

