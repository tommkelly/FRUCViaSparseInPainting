vidReader8 = VideoReader('Downsample8.m4v','CurrentTime',0);
vidReader16 = VideoReader('Downsample16.m4v','CurrentTime',0);

readFrame(vidReader8);
frameRGB = readFrame(vidReader8);
frameGray = rgb2gray(frameRGB);
doubleRGB = im2double(frameRGB);
tween = zeros(size(frameRGB));
mask = zeros(size(frameGray));
inpaintedTween = zeros(size(frameRGB));

flow = estimateFlow(opticFlow,frameGray); 

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

readFrame(vidReader16);
readFrame(vidReader16);
readFrame(vidReader16);
groundRGB = readFrame(vidReader16);
display(num2str(vidReader8.CurrentTime));
display(num2str(vidReader16.CurrentTime));
display(num2str(snr(inpaintedTween,inpaintedTween-im2double(groundRGB))));
