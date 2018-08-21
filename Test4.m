%%%
clear all;
close all;
clc;
%% image insertion
im = imread('football.jpg');
figure, imshow(im), title('input image')
hsv=rgb2hsv(im);
val=hsv(:,:,3);
[row,col]=size(val);
figure, imshow(val),title('image based on the val matrix')
%% finding the overall noise level
[a2,h2,v2,d2] = haart2(val,2);
m=median(median(abs(d2{1})));
Ln=m/0.6745;
%% computing B matrix
for x=2:row-1
    for y=2:col-1
        i=0;
        for j=-1:1
            for k=-1:1
                i=i+val(x+j,y+k);
            end
        end
        i=i/9;
        b(x,y)=i;
    end
end
figure, imshow(b), title('background image');
%% computing G matrix
hx=-fspecial('sobel');
hy=hx';
gx=imfilter(val,hx);
gy=imfilter(val,hy);
g=zeros(row,col);
for x=2:row-1
    for y=2:col-1
        g(x,y)=sqrt((gx(x,y)*gx(x,y))+(gy(x,y)*gy(x,y)));
    end
end
figure, imshow(g), title('sobel gradient image');
%% comparing the noise levels and generate alpha and beta matrix
b1=zeros(row,col);
g1=zeros(row,col);
alpha=zeros(row,col);
beta=zeros(row,col);
for x=2:row-1
    for y=2:col-1
        if g(x,y)>(3*Ln)
            b1(x,y)=-73.7723*b(x,y)*b(x,y)*b(x,y)+66.9325*b(x,y)*b(x,y)-18.4725*b(x,y)+1.80844;
            g1(x,y)=8.33425*g(x,y)*g(x,y)*g(x,y)-5.54801*g(x,y)*g(x,y)+1.79868*g(x,y)-0.028277;
        else
            b1(x,y)=b(x,y);
            g1(x,y)=g(x,y);
        end
        alpha(x,y)=g(x,y)/g1(x,y);
        beta(x,y)=b1(x,y)-alpha(x,y)*b(x,y);
    end
end
%% computing alpha1 and beta1 matrix
alpha1=zeros(row,col);
beta1=zeros(row,col);
z= zeros(row,col);
for x=2:row-1
    for y=2:col-1
        c=0;
        d=0;
        t=0;
        for j=-1:1
            for k=-1:1
                t=t+(exp(-(((j*j)+(k*k))/200)-(((val(x+j,y+k)-val(x,y))*(val(x+j,y+k)-val(x,y)))/450)));             
            end
        end
        z(x,y)=t;
        for j=-1:1
            for k=-1:1
                c=c+alpha(x+j,y+k)*(exp(-(((j*j)+(k*k))/200)-(((val(x+j,y+k)-val(x,y))*(val(x+j,y+k)-val(x,y)))/450)))/t;
                d=d+beta(x+j,y+k)*(exp(-(((j*j)+(k*k))/200)-(((val(x+j,y+k)-val(x,y))*(val(x+j,y+k)-val(x,y)))/450)))/t;
            end
        end
        alpha1(x,y)=c;
        beta1(x,y)=d;
    end
end
%% computing the new value matrix
val1=zeros(row,col);
for x=1:row
    for y=1:col
        val1(x,y)=alpha1(x,y)*val(x,y)+beta1(x,y);
    end
end
figure, imshow(val1), title('modified value image'); 
%% computing the modififed image from the modified value image
hsv(:,:,3)=val1;
modim=hsv2rgb(hsv);
figure, imshow(modim), title('modified rgb image');
        
        
        