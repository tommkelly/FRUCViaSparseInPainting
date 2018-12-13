vidReader = VideoReader('Downsample8.m4v','CurrentTime',0);
vidWriter = VideoWriter('Upsample.avi');
open(vidWriter);

while (hasFrame(vidReader) && vidReader.CurrentTime < 5.000)
    frameRGB = readFrame(vidReader);
    frameGray = rgb2gray(frameRGB);
    doubleRGB = im2double(frameRGB);
    tween = zeros(size(frameRGB));
    mask = zeros(size(frameGray));
    inpaintedTween = zeros(size(frameRGB));
  
    flow = estimateFlow(opticFlow,frameGray); 

    writeVideo(vidWriter,frameRGB);  
    
    [xc,yc] = meshgrid(1:size(frameRGB,2),1:size(frameRGB,1));
    xc = round(xc + 0.5*flow.Vx);
    xc = min(size(frameRGB,2), max(1, xc));
    
    yc = round(yc + 0.5*flow.Vy);
    yc = min(size(frameRGB,1), max(1, yc));
    
    for i = 1:size(tween,1)
        for j = 1:size(tween,2)
            tween(yc(i,j),xc(i,j),1:3) = doubleRGB(i,j,1:3);
            mask(yc(i,j),xc(i,j)) = 1;
        end
    end
    
    %imshow(tween);
    imshow(frameRGB);
    hold on
    plot(flow,'DecimationFactor',[5 5],'ScaleFactor',2)
    hold off
    w = waitforbuttonpress;
    
    %%%%%%%%%%%
    method = 'TV';
    
    lambda = 0.01;
    
    opts.rho     = 1;
    opts.gamma   = 1;
    opts.max_itr = 20;
    opts.print   = false;
    
    inpaintedTween(:,:,1) = PlugPlayADMM_inpaint(tween(:,:,1), mask, lambda, method, opts);
    inpaintedTween(:,:,2) = PlugPlayADMM_inpaint(tween(:,:,2), mask, lambda, method, opts);
    inpaintedTween(:,:,3) = PlugPlayADMM_inpaint(tween(:,:,3), mask, lambda, method, opts);
    %%%%%%%%%%%
    
    writeVideo(vidWriter,max(0,min(1,inpaintedTween)));
    display(strcat('Progress: ',num2str(vidReader.CurrentTime),'/',num2str(vidReader.Duration)));
end

close(vidWriter);