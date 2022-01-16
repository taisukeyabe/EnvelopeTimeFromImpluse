%参照中のファイル内の.matを一つのセルに読み込む％
MATFiles = dir('*.MAT');
numfiles = length(MATFiles);
mydata = cell(numfiles,1);
valueL= cell(numfiles,1);
valueR= cell(numfiles,1);
for k = 1:numfiles
mydata{k} = load(MATFiles(k).name,'-regexp','^h');
names= fieldnames(mydata{k});
valueL{k} = getfield(mydata{k}, names{1});
valueR{k} = getfield(mydata{k}, names{2});
end

[y,fs] = audioread('white_-06_30.wav');



%たみこみ%
audioL1=cell(numfiles,1);
audioR1=cell(numfiles,1);
WAV=cell(numfiles,1);
for k=1:numfiles
audioL1{k}=conv(y,valueL{k});
audioR1{k}=conv(y,valueR{k});
WAV{k}=horzcat(audioL1{k},audioR1{k});
end


%WAVファイルに書き込み、出力％

for i = 1:numfiles
filename = sprintf('%d.wav',i);
audiowrite(filename,WAV{i},fs)
end



%7秒の走行音のデータを66等分して、一つのセルデータに％
[data,fs] = audioread('white_-06_30.wav');
ms=18;
p=floor(ms/1000*fs);
n = numfiles;
a=floor((length(data)+(n-1)*p)/n);
audiodata = cell(n,1);
audiodata{1}=data(1:a);
for i = 1:n-1
audiodata{i+1}=data(i*(a-p)+1:(i+1)*a-i*p);
end


%インパルス応答の畳み込み％
ZR=cell(n,1);
for i=1:n
ZR{i}=conv(audiodata{i},valueR{i});
end
ZL=cell(n,1);
for i=1:n
ZL{i}=conv(audiodata{i},valueL{i});
end


%0を消す％
for i=1:n
ZR{i}(ZR{i}==0) = [];
end
for i=1:n
ZL{i}(ZL{i}==0) = [];
end


%セルのcut％
ZR2=cell(n,1);
for i=1:n
ZR2{i}=ZR{i}(1,1:a);
end
ZL2=cell(n,1);
for i=1:n
ZL2{i}=ZL{i}(1,1:a);
end


%つなげる％
for i=1:n
XX{i}=fadein(ms,fadeout(ms,ZR2{i},fs),fs);
end
ANSR=XX{1};
for i=2:n
L=length(XX{i});
x=length(ANSR);
AND=(ANSR(x-p+1:x)+XX{i}(1:p));
ANSR=vertcat(ANSR(1:x-p),AND,XX{i}(p+1:L));
end

for i=1:n
YY{i}=fadein(ms,fadeout(ms,ZL2{i},fs),fs);
end
ANSL=YY{1};
for i=2:n
L=length(YY{i});
x=length(ANSL);
AND=(ANSL(x-p+1:x)+YY{i}(1:p));
ANSL=vertcat(ANSL(1:x-p),AND,YY{i}(p+1:L));
end


G=horzcat(ANSL,ANSR);
audiowrite('G.wav',G,fs)
