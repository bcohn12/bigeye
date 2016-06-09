
run ../figXX_compviz/Parameters.m

Wlambdaylambda=csvread('../figXX_compviz/Wlambda.csv');

sigma=@(lambda) ((1.1e-3*lambda.^(-4))+(0.008*lambda.^(-2.09)))/(1e3); %value checked with mathmematica
WlambdaylambdaInterp= @(lambda) interp1(Wlambdaylambda(:,1),Wlambdaylambda(:,2),lambda,'pchip'); %value checked with mathematica

%following Middleton:
lambda1=0.4; lambda2=0.7;
Bh=LMoonlight*integral(WlambdaylambdaInterp,lambda1,lambda2); %value checked with mathematica
Ispace=((1.31e3)/0.89)*Bh*(1e6)^2; %value checked with mathematica


%% RELATE PUPIL SIZE TO RANGE
if T<0.05
    minvisualrange=1; maxvisualrange=500;
else
    minvisualrange=50; maxvisualrange=2500;
end

pupilValuesAir=linspace(minpupil,maxpupil,25);
rangeValuesAir=linspace(minvisualrange,maxvisualrange,1000);
parfor loop1=1:length(pupilValuesAir)
    A=pupilValuesAir(loop1);
    possibleSolM=zeros(length(rangeValuesAir),1);
    for loop2=1:length(rangeValuesAir)
        r=rangeValuesAir(loop2);

        Nspace=(pi/4)^2*(T/r)^2*A^2*Ispace*Dt_moonlight*q*(1-exp(-k*len));
        Xch=((T*f_night*A)/(2*r*d))^2*X_land*Dt;

        %APPARENT RADIANCE OF THE GREY OBJECT
        Bgfunc=@(lambda) WlambdaylambdaInterp(lambda).*(1+(C0_moonlight.*exp(-sigma(lambda).*r)));
        Bg= LMoonlight*integral(Bgfunc,lambda1,lambda2);
        Iobject=((1.31e3)/0.89)*Bg*(1e6)^2;


        %BACKGROUND SPACE-LIGHT RADIANCE
%         Bbfunc=@(lambda) WlambdaylambdaInterp(lambda).*(1-exp(-sigma(lambda).*r));
%         Bb=LMoonlight*integral(Bbfunc,lambda1,lambda2);
%         Iblack=((1.31e3)/0.89)*Bb*(1e6)^2;

        Itarget=Iobject;

        Ntarget=(pi/4)^2*(T/r)^2*A^2*Itarget*Dt_moonlight*q*(1-exp(-k*len));

        eq=(R*sqrt(Ntarget+Nspace+2*Xch))/(abs(Ntarget-Nspace));

        possibleSolM(loop2)=eq;
    end
    IDXDaylight=knnsearch(possibleSolM,1,'distance','euclidean');
    visualRangeMoonlight(:,loop1)=rangeValuesAir(IDXDaylight);

    s=sprintf('iteration: %d', loop1);
    disp(s)
end

save('moonlight','visualRangeMoonlight')        
