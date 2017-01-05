function [bugContrast,fishContrast,baseFileNames]=getBugContrast 
global BIGEYEROOT
    close all;	% Close all figure windows except those created by imtool.
    imtool close all;	% Close all figure windows created by imtool.

    baseFileNames={'Giant Centipede.jpeg','brownCentipede.jpg','centipedes.jpg','maxresdefault.jpg','maxresdefault2.jpg',...
        'maxresdefault3.jpg','millipede.jpg','millipedeWood.jpg','redBlackMillipede.jpg','ScolonpendraPolymorp.jpg',...
        'blackCentipede.png','VietnameseCentipede.jpg',...
        '002.jpg','amazon_cichlid.png','amazon_fish.png','arowanawild.jpg','fishContrast.png'};

    for i=17:length(baseFileNames)
        baseFileName=baseFileNames{i};
        fullFileName=fullfile(baseFileName);

        if~exist(fullFileName,'file')
            fullFileName=baseFileName;
            if~exist(fullFileName,'file')
                errorMessage=sprintf('Error: %s does not exist in the search path.',fullFileName);
                uiwait(warndlg(errorMessage));
                return;
            end
        end

        figure();

        I=imread(fullFileName);
        imshow(I,[]);
        axis on;
        title('Original Image');
        set(gcf,'Position',get(0,'Screensize'));

        hFHObject=imfreehand();

        binaryImage=hFHObject.createMask();
        grayImage=rgb2gray(I);
        labeledImage=bwlabel(binaryImage);
        blackMaskedImage=grayImage;
        blackMaskedImage(~binaryImage)=0;
        measurements=regionprops(binaryImage,grayImage,'area','Perimeter');
        area=measurements.Area;
        perimeter=measurements.Perimeter;

        structBoundaries=bwboundaries(binaryImage);
        xy=structBoundaries{1};
        x=xy(:,2);
        y=xy(:,1);

        subplot(2,2,1);
        imshow(grayImage,[]); axis on; title('Original Image')
        drawnow;
        subplot(2,2,2)
        imshow(binaryImage); axis on; title('Binary Masked Image');
        drawnow;
        subplot(2,2,1)
        hold on; plot(x,y,'LineWidth',2); title('Superimposed Perimeter')
        drawnow;

        topLine=min(x); bottomLine=max(x);
        leftColumn=min(y); rightColumn=max(y);
        width=bottomLine-topLine+1; height=rightColumn-leftColumn+1;
        croppedImage=imcrop(blackMaskedImage,[topLine,leftColumn,width,height]);

        subplot(2,2,3);
        imshow(croppedImage); axis on; title('Cropped Image to Selection')
        drawnow;

        LObject=croppedImage(croppedImage~=0);
        LmaxObject=max(LObject); LmeanObject=mean(LObject);

        insideMasked=grayImage;
        insideMasked(binaryImage)=0;

        subplot(2,2,4);
        imshow(insideMasked); axis on; title('Background Image, Removed Selection')
        drawnow;

        LBackground=insideMasked(insideMasked~=0);
        LmaxBackground=max(LBackground); LmeanBackground=mean(LBackground);

        if i<13
            bugContrast(i)=(LmeanObject-LmeanBackground)/LmeanBackground;
        else
            fishContrast(i-12)=(LmeanObject-LmeanBackground)/LmeanBackground;
        end

        close all;
    end

save([BIGEYEROOT 'figExt07_contrast/image_contrast/imageContrastValues'],'bugContrast','fishContrast','baseFileNames');


