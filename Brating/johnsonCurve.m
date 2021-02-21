% function johnsonCurve(sr)
clear
x = -5:0.01:5;
pzt = normcdf(x); % 生成标准正态分布表
plot(x,pzt)
hold on
z = 0.68; % 变换参数  允许位数0.01
sz = [-3*z,-z,z,3*z];  % 变换参数的几个点
weizhi = int16((sz+5)./0.01+1); % 分位数
pz = pzt(weizhi); % 分位数的累积分布概率
[jihe,itemsl] = qiepian('Result.csv');
s1=jihe{4,3}(2:length(jihe{4,3}),1); % 用于测试转换效果的数据，原始数据
s2 = sort(s1);
dd = cdfplot(s2); % 为了得到s2的累积分布概率
xsz = zeros(1,4);
for i = 1:4
    bj(1:length(dd.YData)) = pz(i); % 样本从大到小重新排列后z的几个分布概率
    jl = bj-dd.YData; % 此分布概率对应的原始数据累积分布概率的距离
    Min = min(abs(bj-dd.YData)); % 距离的最小值
    wzwz = find(abs(jl) == Min); % 找到最接近的概率的位置
    xsz(i) = dd.XData(wzwz(1)); % 找出对应于分布概率的分位数。 xsz（1:4）分别代表，x-sz，x-z，xz，xsz
end
%% 接下来计算m，n，p及分位数比率QR=mn/p^2
m = xsz(4)-xsz(3);
n = xsz(2)-xsz(1);
p = xsz(3)-xsz(2);
QR = m*n/(p^2);
if QR<1
    [y]=sbcs(z,m,n,p,xsz,s2);
elseif QR==1
    [y]=slcs(z,m,p,xsz,s2);
else
    [y]=sucs(z,m,n,p,xsz,s2);
end
figure
cdfplot(y);
%% 计算曲线参数并完成变换
function [y] = sbcs(z,m,n,p,xsz,x)
    b1 = z/(acosh(0.5*((1+p/m)*(1+p/n))^0.5));
    b2 = b1*asinh((p/m-p/n)*((1+p/m)*(1+p/n)-4)^0.5/(2*(p^2/m/n-1)));
    b3 = p*(((1+p/m)*(1+p/n)-2)^2-4)^0.5/(p^2/m/n-1);
    b4 = (xsz(3)+xsz(2))/2-b3/2+p*(p/n-p/m)/2/(p^2/m/n-1);
    y = b2+b1*log((x-b4)./(b3+b4-x));
end

function [y] = slcs(z,m,p,xsz,x)
    b1 = 2*z/log(m/p);
    b2 = b1*log((m/p-1)/p/(m/p)^0.5);
    b4 = (xsz(3)+xsz(2))/2-p/2*((m/p+1)/((m/p)-1));
    y = b2+b1*log(x-b4);
end

function [y] = sucs(z,m,n,p,xsz,x)
    b1 = 2*z/(acosh(0.5*(m/p+n/p)));
    b2 = b1*asinh((n/p-m/p)/2/(m*n/p/p-1)^0.5);
    b3 = 2*p*(m*n/p-1)^0.5*((m/p+n/p-2)*(m/p+n/p+2))^0.5;
    b4 = (xsz(3)+xsz(2))/2+p*(n/p-m/p)/2/(m/p+n/p-2);
    y = b2+b1*asinh((x-b4)./b3);
end
    

% dd = cumsum(s2/length(s2));
% figure; plot(s2,dd);

