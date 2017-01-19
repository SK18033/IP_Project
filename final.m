clc;
close all;
clear all;

writeObj = VideoWriter ('Morph.avi');
writeObj.FrameRate = 1;
open(writeObj);


im = imread('2.jpg');
subplot(1,2,1);
imshow(im);

im1= imread('1.jpg');
[A1,B1] =ginput(4);
hold on
plot(A1,B1,'ro','MarkerSize',10);
line([A1],[B1], 'Color' , 'b' , 'LineWidth',2);
hold off

s=length(A1);
S=s/2;
subplot(1,2,2);
imshow(im1);

[a1,b1] = ginput(4);
hold on
plot(a1,b1,'ro','MarkerSize',10);
line([a1],[b1], 'Color' , 'b' , 'LineWidth',2);
hold off

row = length(im(:,1,1));
col = length(im(1,:,1));

morphed = im;



for y = 1:row
    for x = 1:col
        X = [x y];
        Xsource = zeros(1,2);
        dsum = zeros(1,2);
        weightsum = 0;
            for i = 1:S
                i1 = (i-1)*2+1;
                i2 = i1 + 1;

                Pi = [A1(i2), B1(i2)];
                Qi = [A1(i1), B1(i1)];
                QPi = Qi - Pi;
                Pisource = [a1(i2), b1(i2)];
                Qisource = [a1(i1), b1(i1)];
                QPisource = Qisource - Pisource;
                u = dot((X - Pi), QPi) / (QPi(1).^2 + QPi(2).^2);
                per1= [-QPi(2), QPi(1)];
                v = dot((X - Pi), per1) / sqrt(QPi(1).^2 + QPi(2).^2);
                per2= [-QPisource(2), QPisource(1)];
                Xisource = Pisource+u*QPisource+(v*per2 / sqrt(QPisource(1).^2 + QPisource(2).^2));

                Di = Xisource - X;
                if u < 0
                    dist = sqrt((X(1)-Pi(1)).^2+(X(2)-Pi(2)).^2);
                elseif u > 1
                    dist = sqrt((X(1)-Qi(1)).^2+(X(2)-Qi(2)).^2);
                else
                    dist = abs(v);
                end
                length = sqrt(QPi(1).^2 + QPi(2).^2);
                p = 0.5; % Defines strength of lines relative to length. Range: [0,1]. If 0, all lines have same weight, if 1, longer lines carry more weight than shorter ones
                a = 0.1; % Defines strength of line based on distance from point. Lower values = more control, larger value = more smooth warping
                b = 1; % Defines strength fall-off based on distance from point. Good Range: [0.5,2]. If 0, pixel affected by all lines equally, if large, then only affected by nearest lines
                weight = (length.^p / (a + dist)).^b;
                dsum = dsum + (Di * weight);
                weightsum = weightsum + weight;
            end

            Xsource = X + dsum / weightsum;


            [xSize, ySize] = size(im);
            nullCol = false;
            if int32(Xsource(1)) <= 0
                Xsource(1) = 1;
                nullCol = true;
            elseif int32(Xsource(1)) > xSize
                Xsource(1) = xSize;
                nullCol = true;
            end
            if int32(Xsource(2)) <= 0
                Xsource(2) = 1;
                nullCol = true;
            elseif int32(Xsource(2)) > ySize
                Xsource(2) = ySize;
                nullCol = true;
            end

            if nullCol == true
                morphed(X(1), X(2), :) = [0, 255, 255];
            else
                % Set pixel X in dst image
                morphed(X(1), X(2), :) = im(uint8(Xsource(1)), uint8(Xsource(2)), :);
            end
     end
end
figure(2);
subplot(1, 2, 1);
imshow(im);
subplot(1, 2, 2);
imshow(morphed);
pause(2);

for a= 1:10
   a1= 0.1*a
    Z=((1-a1)* morphed) + (a1 * im1);
    figure(3);
    imshow(Z);
    pause(0.3);
    writeVideo(writeObj, getframe(gcf));

end

close(writeObj);

