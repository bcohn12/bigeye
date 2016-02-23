%%

clear all
close all

%% Read in data

[~,txt,~]=xlsread('bigEye_data.xlsx',3,'A1:A150');

indtf=strcmp('Tetrapodomorph Fish',txt);
tfind=strcmp('Elpistostege',txt);
indst=strcmp('Stem Tetrapods',txt);
stind=strcmp('Megalocephalus',txt);

starttf=find(indtf)+1;
startst=find(indst)+1;
endtf=find(tfind);
endst=find(stind);

starttft1=['K' num2str(starttf)];
endtft1=['K' num2str(endtf)];
starttft2=['M' num2str(starttf)];
endtft2=['M' num2str(endtf)];
starttft3=['O' num2str(starttf)];
endtft3=['O' num2str(endtf)];
starttft4=['Q' num2str(starttf)];
endtft4=['Q' num2str(endtf)];
startstt1=['K' num2str(startst)];
endstt1=['K' num2str(endst)];
startstt2=['M' num2str(startst)];
endstt2=['M' num2str(endst)];
startstt3=['O' num2str(startst)];
endstt3=['O' num2str(endst)];
startstt4=['Q' num2str(startst)];
endstt4=['Q' num2str(endst)];

TFwidth=xlsread('bigEye_data.xlsx',3,[starttft1 ':' endtft1]);
TFlen=xlsread('bigEye_data.xlsx',3,[starttft2 ':' endtft2]);
TFeye=xlsread('bigEye_data.xlsx',3,[starttft3 ':' endtft3]);
TFnum=xlsread('bigEye_data.xlsx',3,[starttft4 ':' endtft4]);
STwidth=xlsread('bigEye_data.xlsx',3,[startstt1 ':' endstt1]);
STlen=xlsread('bigEye_data.xlsx',3,[startstt2 ':' endstt2]);
STeye=xlsread('bigEye_data.xlsx',3,[startstt3 ':' endstt3]);
STnum=xlsread('bigEye_data.xlsx',3,[startstt4 ':' endstt4]);

TFind=find(~isnan(TFlen));
STind=find(~isnan(STlen));

TFeye=TFeye(TFind);
STeye=STeye(STind);
TFwidth=TFwidth(TFind);
STwidth=STwidth(STind);
TFlen=TFlen(TFind);
STlen=STlen(STind);
TFnum=TFnum(TFind);
STnum=STnum(STind);

%% Calc ratios

stem_eye = log(STeye);
tet_eye = log(TFeye);

stem_len = log(STlen);
tet_len = log(TFlen);

stem_rat = stem_eye - stem_len;
tet_rat = tet_eye - tet_len;

%% Plot?

figure(1)
clf
hold on
plot(stem_len,stem_eye,'x')
plot(tet_len,tet_eye,'o')
hold off

figure(2)
clf
hold on
histogram(stem_rat, 7)
histogram(tet_rat, 7)
hold off
legend('stem', 'tetropodomorph')
xlabel('log(eye/skull length)')

figure(3)
clf
hold on
histogram(stem_len, 7)
histogram(tet_len, 7)
hold off

figure(4)
clf
hold on
plot(stem_len,stem_rat,'x')
plot(tet_len,tet_rat,'o')
hold off

%% T test
disp('T Test:')
[h, p, ci, stats] = ttest2(stem_rat, tet_rat, 'Vartype', 'unequal')

%% Rank Sum?
disp('Rank Sum:')
[p,h,stats] = ranksum(stem_rat, tet_rat)

%% ks test on skull length
disp('KS Test')
[h,p,ks2stat] = kstest2(stem_len,tet_len)