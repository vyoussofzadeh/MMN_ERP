clc;clear all;close all;

freq = 1:100;
fs = 500;

disp('1: Linear');
disp('2: Nonlinear-sigmoidal');
disp('3: Nonlinear-exponential');
in = input('Model?');
disp('   ');
disp('1: zero noise');
disp('2: high noise');
disp('3: strong noise');
disp('4: a realistic condition');
in2 = input('Noise level?');

%% Data generation
if in==1
    Data_linear;
elseif in==2
    Data_nonlinear_sig;
elseif in==3
    Data_nonlinear_exp;
end

%% Model order
disp('finding best model order ...');
[bic,aic] = cca_find_model_order(X,2,12);
nlags = max(aic,bic);
disp(['best model order by Bayesian Information Criterion = ',num2str(bic)]);
disp(['best model order by Aikaike Information Criterion = ',num2str(aic)]);

N = length(X);  % length of data
Nr = 1;         % number of realizations (trials)
Nl = N/Nr;      % length of each realization

nBoot = 10;
nBwin = 5;
pval = 0.05;
CORRTYPE = 1;   % Bonferroni

%% Time-domain-GC: Partial/conditional Granger Causality
ret3 = cca_partialgc_doi_bstrap(X,Nr,Nl,nlags,nBoot,nBwin,pval,CORRTYPE,1);

% Spectral-GC
ret4 = cca_pwcausal_bstrap(X,Nr,Nl,nlags,nBoot,nBwin,fs,freq,pval,CORRTYPE);
M1 = ret3.fg; M2 = ret3.gc;

M1=(M1+abs(min(M1(:))))/(max(M1(:))+abs(min(M1(:))));
M1(eye(size(M1))~=0)=0;
M2=(M2+abs(min(M2(:))))/(max(M2(:))+abs(min(M2(:))));
M2(eye(size(M2))~=0)=0;

M11 = M1; M22 = M2;

figure(2),
subplot (2,3,1)
imshow(imread('Ex2.png'));title('Expected Connectivity Structure');
subplot (2,3,2:3)
plot(X','LineWidth',2),legend(['X1';'X2';'X3';'X4';'X5']);
xlabel('Samples')
ylabel('Amplitude' )

subplot(2,3,4)
imagesc(M11);
title('PGC');
colormap(jet); colorbar;
subplot(2,3,5)
imagesc(M22);
title('CGC');
colormap(jet); colorbar;
colormap(flipud(pink));


%% freq
GW1 = ret4.GW;
M3 = mean(GW1,3);
M3(logical(eye(size(M3)))) = NaN;
M3 = (M3+abs(min(M3(:))))/(max(M3(:))+abs(min(M3(:))))';
subplot(2,3,6)
imagesc(M3);

title('Spectral-GC');
colormap(jet); colorbar;
colormap(flipud(pink));
set(gcf, 'Position', [200   300   1200   500]);
