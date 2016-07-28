clear all;

experimentalPupilVals=[0.002,0.003,0.0038,0.0048,0.0058,0.0066];

twoMilli=csvread('2mmMl.csv');
x2=twoMilli(:,1); y2=twoMilli(:,2);
temp=fit(x2,y2,'exp1');
s2=coeffvalues(temp);

threeMilli=csvread('3mmMl.csv');
x3=threeMilli(:,1); y3=threeMilli(:,2);
temp=fit(x3,y3,'exp1');
s3=coeffvalues(temp);

threeEightMilli=csvread('38mmMl.csv');
x38=threeEightMilli(:,1); y38=threeEightMilli(:,2);
temp=fit(x38,y38,'exp1');
s38=coeffvalues(temp);

fourEightMilli=csvread('48mmMl.csv');
x48=fourEightMilli(:,1); y48=fourEightMilli(:,2);
temp=fit(x48,y48,'exp1');
s48=coeffvalues(temp);

fiveEightMilli=csvread('58mmMl.csv');
x58=fiveEightMilli(:,1); y58=fiveEightMilli(:,2);
temp=fit(x58,y58,'exp1');
s58=coeffvalues(temp);

sixSixMilli=csvread('66mmMl.csv');
x66=sixSixMilli(:,1); y66=sixSixMilli(:,2);
temp=fit(x66,y66,'exp1');
s66=coeffvalues(temp);

spreadConstant=-[s2(2) s3(2) s38(2) s48(2) s58(2) s66(2)];
queryPoints=linspace(0.001,0.006,1000);

s=@(A) interp1(experimentalPupilVals,spreadConstant,A,'pchip');

save('spreadInfo','experimentalPupilVals','spreadConstant','s');

sInterp=interp1(experimentalPupilVals,spreadConstant,queryPoints,'pchip');
M=[queryPoints',sInterp'];
csvwrite('spreadFunction.csv',M)