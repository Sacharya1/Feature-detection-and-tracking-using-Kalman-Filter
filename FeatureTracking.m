clc; clear all;
Image= imread('frame_00022.jpg');
Image=rgb2gray(Image);
Image1= imread('frame_00023.jpg');
Image1=rgb2gray(Image1);
Th= 75;

% ImageNo=input(prompt);
% Test = sprintf('TestImage%d.jpg',ImageNo);

Image=double(Image);
Image1=double(Image1);

Image = padarray(Image, [1 1], 0, 'both');
Sx= [-1 0 1; -2 0 2; -1 0 1];
Sy= Sx';
[rows cols]= size(Image);

for r= 1:rows-2
    for c= 1:cols-2
        Ix(r,c)= sum(sum(Sx.*Image(r:r+2,c:c+2)));
        Iy(r,c)= sum(sum(Sy.*Image(r:r+2,c:c+2)));
    end
end

Ix= uint8(Ix);
Iy= uint8(Iy);

Component1 = Ix.^2;
Component2 = Ix.*Iy;
Component3 = Iy.^2;


Component1=imgaussfilt(Component1, 2);
Component2=imgaussfilt(Component2, 2);
Component3=imgaussfilt(Component3, 2);

for r= 1: rows-2
    for c= 1:cols-2

ACorr=[Component1(r,c) Component2(r,c); Component2(r,c) Component3(r,c)];
ACorr= double(ACorr);
EigenValues= eig(ACorr);
AllEigenValues{r,c}=EigenValues;
SmallEigenVal=min(EigenValues);
EigenVal(r,c)=SmallEigenVal;
    end 
end
 i=0;
EigenVal = padarray(EigenVal, [2 2], 0, 'both');
[R C]= size(EigenVal);

for r= 1:R-4
    for c =1:C-4
       LocalMatrix= EigenVal(r:r+4,c:c+4); 
        [Val Index]= max(LocalMatrix(:));
       
        
        if Index==13 && Val>Th
            i=i+1;
            FeaturePoints{i}=[r,c];
        end
    end
end
Features= cell2mat(FeaturePoints')

Sall=padarray(Features, [0 2], 0, 'post');
Sall=Sall';

% Sall= padarray(Features, [0 2], -1, 'post');
% Sall=Sall';
P_0= [9 0 0 0; 0 9 0 0; 0 0 25 0; 0 0 0 25];

A= [1 0 1 0; 0 1 0 1; 0 0 1 0; 0 0 0 1];

H= [1 0 0 0; 0 1 0 0];

Q= [0.25 0 0 0; 0 0.25 0 0; 0 0 0.25 0; 0 0 0 0.25];

R= [1 0; 0 1];

for FP=1:i
    FP;
S= Sall(:,FP);
m_0= S(1:2,:);
S_int= A*S;
m_int= S_int(1:2,:);
P_int= A*P_0*A' + Q;
K = P_int*H'*(inv(H*P_int*H' + R));
Std= round(sqrt(max(P_int(1,1), P_int(2,2))));
% Std=5

I_0= Image(m_0(1)-2:m_0(1)+2,m_0(2)-2:m_0(2)+2);
PadImage1= padarray(Image1, [r c], 0, 'both');

I_1= PadImage1(r+m_int(1)-(2*Std)-2:r+m_int(1)+(2*Std)+2,c+m_int(2)-(2*Std)-2:c+m_int(2)+(2*Std)+2);

[rI_1 cI_1]= size(I_1);

for r=1:rI_1-4
    for c=1:cI_1-4
        
        WSSD(r,c)= sum(sum((I_1(r:r+4,c:c+4)-I_0).^2));
    end
end

[newVal newIndex]= min(WSSD(:));

    if rem(newIndex,((4*Std)+1))==0
    First = floor(newIndex/((4*Std)+1));
   Second=(4*Std)+1;
     else
    First = floor(newIndex/((4*Std)+1))+1;
   Second=rem(newIndex,((4*Std)+1));
     
    end


    newM= [First Second];
 m_1=  [m_int(1)-(2*Std)-1+newM(1);m_int(2)-(2*Std)-1+newM(2)];
m_1=round(m_1);
S_1{FP} = S_int + K*(m_1-(H*S_int));
I=eye(4);
P_1{FP}= (I- K*H)*P_int;
end

% S_1=cell2mat(S_1);
% P_1=cell2mat(P_1);
% 

 for fps =1:30
     for FP=1:i
         if fps==1
             S=S_1;
         else
             S=S;
         end 
   
         if fps==1
             P=P_1;
         else
             P=P;
         end 
         
S= cell2mat(S(FP));
m= round(S(1:2,:));
S_int= A*S;
P=cell2mat(P(FP));
m_int= round(S_int(1:2,:));
P_int= A*P*A' + Q;
K = P_int*H'*(inv(H*P_int*H' + R));
Std= round(sqrt(max(P_int(1,1), P_int(2,2))));

ImageNo=22+fps;
ImageNo1=ImageNo+1;
Test = sprintf('frame_000%d.jpg',ImageNo);
Image= imread(Test);
Image=rgb2gray(Image);


Test1 = sprintf('frame_000%d.jpg',ImageNo1);
Image1= imread(Test1);
Image1=rgb2gray(Image1);


Image=double(Image);
Image1=double(Image1);


I_0= Image(m_0(1)-2:m_0(1)+2,m_0(2)-2:m_0(2)+2);
PadImage1= padarray(Image1, [120 160], 0, 'both');

I_1= PadImage1(120+m_int(1)-(2*Std)-2:120+m_int(1)+(2*Std)+2,160+m_int(2)-(2*Std)-2:160+m_int(2)+(2*Std)+2);

[rI_1 cI_1]= size(I_1);
ii=0;

Low=100000000000;
for rr=1:rI_1-4
    for cc=1:cI_1-4
        MM=(I_1(rr:rr+4,cc:cc+4)-I_0).^2;
         ii=ii+1;
%         Test11 = sprintf('%d',ii);
        Sum=sum(sum(MM));
%         Sum(Test11)= Sum
%         
%         
%         AA(ii)=Sum;

if Sum-Low<0
Low=Sum;
Idx=ii;
else 
    Low=Low;
end

% WSSSD(rr,cc)=Sum;

    end
end
% [ala bla]= size(MM)

% [newVal newIndex]= min((WSSSD(:)));
newIndex=Idx;
     if rem(newIndex,((4*Std)+1))==0
    First = floor(newIndex/((4*Std)+1));
   Second=(4*Std)+1;
     else
    First = floor(newIndex/((4*Std)+1))+1;
   Second=rem(newIndex,((4*Std)+1));
     
    end
    
    newM= [First Second];

 m_1=  [m_int(1)-(2*Std)-1+newM(1);m_int(2)-(2*Std)-1+newM(2)]
  m_1=round(m_1);
FPM{FP}=m_1;
allM{fps}=cell2mat(FPM)'; 
Ss{FP}= S_int + K*(m_1-(H*S_int));
I=eye(4);
Ps{FP}= (I- K*H)*P_int;
S=Ss;
P=Ps;




     end
 end
 





Primary= cell2mat(S_1);
Primary=round(Primary(1:2,:)')

Location = [Features,Primary, cell2mat(allM)];

[Row Col]= size(Location);

for rr= 1:Row
    for cc= 1:Col
        if Location(rr,cc)<0
            
Location(rr,cc)=0;
        else
            Location(rr,cc)=Location(rr,cc);


        end
    end
end




mm=0;

 for c=1:1:Col-1
Pos= Location(:,c:c+1);
% Pos=double(Pos);
mm=mm+1;
Num=mm+21;
Image = sprintf('frame_000%d.jpg',Num);
% Image(Pos(1,1),Pos(1,2))
RGB=imread(Image);
% RGB=double(RGB);

for i=1:120
    for j=1:160
        if i==Pos(1,1) && j== Pos(1,2)
        RGB(i,j,1)=255;
        RGB(i,j,2)=0;
        RGB(i,j,3)=0;
        
        elseif i==Pos(2,1) && j== Pos(2,2)
        RGB(i,j,1)=255;
        RGB(i,j,2)=0;
        RGB(i,j,3)=0;
        elseif i==Pos(3,1) && j== Pos(3,2)
        RGB(i,j,1)=255;
        RGB(i,j,2)=0;
        RGB(i,j,3)=0;
        elseif i==Pos(4,1) && j== Pos(4,2)
        RGB(i,j,1)=255;
        RGB(i,j,2)=0;
        RGB(i,j,3)=0;
        elseif i==Pos(5,1) && j== Pos(5,2)
        RGB(i,j,1)=255;
        RGB(i,j,2)=0;
        RGB(i,j,3)=0;
        elseif i==Pos(6,1) && j== Pos(6,2)
        RGB(i,j,1)=255;
        RGB(i,j,2)=0;
        RGB(i,j,3)=0;
        end
end

imshow(RGB);
end
 end





