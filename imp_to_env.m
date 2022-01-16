%https://note.com/kimurataro23/n/ne75536b645e2

rootname = 'imp-'; % ファイル名に使用する文字列
extension = '.wav'; % 拡張子
Files = dir('1-*.wav');
[v,fs2] = audioread('17dwswp.wav');

for n=1:length(Files)
    [name, ext] = fileparts(Files(n).name);
    [y,fs] = audioread(Files(n).name);
    w = conv(y,v);
    w = w(100000:end);%wの範囲を指定
    filename = [rootname, num2str(n), extension]; % ファイル名の作成
    w = w / max(abs(w));
    audiowrite(filename,w,fs) % ファイルへの保存
    
    %intlist = [hz125, hz250, hz500, hz1k, hz2k, hz4k];
    %for i=1:lenth(intlist)
        %intlist(i) =  bandpass(w, [125/2*sqrt(2) 125*sqrt(2)],fs);
    
    %バンドパスフィルタ(各々の帯域毎に分ける)
    hz125 = bandpass(w, [125/2*sqrt(2) 125*sqrt(2)],fs);
    hz250 = bandpass(w, [250/2*sqrt(2) 250*sqrt(2)],fs);
    hz500 = bandpass(w, [500/2*sqrt(2) 500*sqrt(2)],fs);
    hz1k = bandpass(w, [1000/2*sqrt(2) 1000*sqrt(2)],fs);
    hz2k = bandpass(w, [2000/2*sqrt(2) 2000*sqrt(2)],fs);
    hz4k = bandpass(w, [4000/2*sqrt(2) 4000*sqrt(2)],fs);
    
    %各帯域ごとにインパルス応答を書き出す
    filename125 = [rootname, num2str(n),'-125', extension]; % ファイル名の作成
    filename250 = [rootname, num2str(n),'-250', extension];
    filename500 = [rootname, num2str(n),'-500', extension];
    filename1k = [rootname, num2str(n),'-1k', extension];
    filename2k = [rootname, num2str(n),'-2k', extension];
    filename4k = [rootname, num2str(n),'-4k', extension];
    
    audiowrite(filename125,hz125,fs)
    audiowrite(filename250,hz250,fs)
    audiowrite(filename500,hz500,fs)
    audiowrite(filename1k,hz1k,fs)
    audiowrite(filename2k,hz2k,fs)
    audiowrite(filename4k,hz4k,fs)
    
    %各Hzごとに減衰時間を測定
    intlist = [hz125,hz250, hz500, hz1k, hz2k, hz4k];
    T1 = -5;
    T2 = -35;
    reverb_time = [];
    reverb_time_add = [];
    sz=size(intlist);
    for j=1:sz(1,2)
        for i=1:sz(1,1)
            intlist1(i,j)= intlist(i,j).^2;
        end
        y3 = flipud(intlist1(:,j));%y2を上下方向、すなわち水平軸回りに反転
        y4 = cumsum(y3);%y3の各列の累積和を含む行列を返します(前から各要素を足していく)
        y5 = flipud(y4);%y4を上下方向、すなわち水平軸回りに反転した結果
        %デシベル表示(減衰曲線Y)
        mm = max(10*log10(y5));%curve_offset
        t = ((0:length(y5)-1)/fs)';%x軸の時間座標,ファイル先頭からの時刻
        z = 10*log10(y5)-mm;%decay_curve,y軸のdB座標
        % linear fit (-5dB ~ -35dB) and find the time of being -60dB
        ind = [sum(z >= T1)  sum(z >= T2)];%-5から-35dB,t(ind)が残響時間,何サンプル目がマイナス～dBか
        p = polyfit(z(ind(1):ind(2)), t(ind(1):ind(2)), 1);%近似曲線polyfit（y、x、N）
        rtT1 = polyval(p, T1);
        rtT2 = polyval(p, T2);
        rt_sec = (rtT2 - rtT1) *2;
        %reverb_time_add =  append(re_sec);
        reverb_time_add = horzcat(reverb_time_add,rt_sec);
    end
    reverb_time = cat(1,reverb_time,reverb_time_add);
    filename_time = ['reverb_time', num2str(n), '.txt'];
    writematrix(reverb_time,filename_time);
end
