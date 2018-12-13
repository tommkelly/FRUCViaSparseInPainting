imgs = dir('frames/*.png');
vidWriter = VideoWriter('foreman');
vidWriterHalf = VideoWriter('half');
vidWriterQuarter = VideoWriter('quarter');
open(vidWriter);
open(vidWriterHalf);
open(vidWriterQuarter);
for i = 1:numel(imgs)
    img = imgs(i);
    imgOpen = imread(strcat(img.folder,'/',img.name));
    writeVideo(vidWriter,imgOpen);
    if (mod(i,2) == 0)
        writeVideo(vidWriterHalf,imgOpen);
    end
    if (mod(i,4) == 0)
        writeVideo(vidWriterQuarter,imgOpen);
    end
end
close(vidWriter);
close(vidWriterHalf);
close(vidWriterQuarter);