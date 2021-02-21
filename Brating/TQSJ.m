%% 相关性分析
clear
[jihe,itemsl] = qiepian('Result.csv');
tpt=jihe{4,3}(floor(2:(length(jihe{4,3})-1)/(length(jihe{4,2})-1):length(jihe{4,3}))); % 用于拟合的x数据,原始数据
sl=jihe{4,2}(2:length(jihe{4,2}),1); % 用于拟合的y数据，原始数据
figure
cdfplot(tpt); % 画累积分布函数
[hh,pp] = kstest(tpt); % KS检验,hh=0代表满足正态分布，hh=1代表不满足正态分布。pp表示p值，越大越满足正态分布
X = [ones(size(sl)),tpt];
[b,bint,r,rint,stats] = regress(sl,X,0.05); % regress先y，后x，再后置信区间
%b 回归系数
%bint 回归系数的区间估计
%r 残差
%rint 残差置信区间
%stats 用于检验回归模型的统计量，有四个数值：相关系数R2、F值、与F对应的概率p，
%误差方差。相关系数R2越接近1，说明回归方程越显著；F > F1-α（k，n-k-1）时拒绝H0，F越大，说明回归方程越显著；
%与F对应的概率p 时拒绝H0，回归模型成立。p值在0.01-0.05之间，越小越好。
ycy = b(2:length(b)).*tpt+b(1); % 预测模型
figure
plot(ycy)
hold on
plot(sl)
%% 画图
for i = 1:itemsl
    figure
    plot(jihe{2,i}(:,2))
    title(jihe{1,i})
    xlabel('t')
    ylabel('value')
end
%% 概率密度分布weibull分布
junz = mean(jihe{2,3}(:,2)); % 均值
bzcha = sqrt(var(jihe{2,3}(:,2))); % 标准差
xc = (bzcha/junz)^-1.086; % 形状参数
cc = junz/gamma(1+1/xc); % 尺度参数
h = histogram(jihe{2,3}(:,2),16); % 做直方图概率密度分布柱状图
nhcs = makedist('Weibull', 'a', cc, 'b', xc); % 做weibull分布
x = 0:0.1:30; % 量取值区间
y = pdf(nhcs,x); % 做概率密度拟合曲线
figure
plot(x,y)
T = 10:10:100; % 重现周期
xmax = cc*(log(T)).^(1/xc); % 重现周期变量可能出现的最大值
%% 功效系数法
myzhbyxz(1,:)=[200,10,1,1,0.5,100]; % 满意值
myzhbyxz(2,:)=[5,2,0,0,0,5]; % 不允许值
x=zeros(12,length(myzhbyxz)); % 监测数据
for i=1:12
    x(i,:)=rand(1,length(myzhbyxz)).*myzhbyxz(1,:);
end
e=zeros(12,length(myzhbyxz));
for i=1:12
    for j=1:length(myzhbyxz)
    e(i,j)=(x(i,j)-myzhbyxz(2,j))/(myzhbyxz(1,j)-myzhbyxz(2,j))*40+60; % efficiency_coefficient
    end
end
%% 主成分分析
% x：为要输入的n维原始数据。带入这个matlab自带函数，将会生成新的n维加工后的数据（即score）。
% 此数据与之前的n维原始数据一一对应。
% score：生成的n维加工后的数据存在score里。它是对原始数据进行的解析，进而在新的坐标系下获得的数据。
% 他将这n维数据按供献率由大到小分列。（即在改变坐标系的景象下，又对n维数据排序）
% latent：是一维列向量，每一个数据是对应score里响应维的供献率，因为数占领n维所以列向量有n个数据。
% 由大到小分列（因为score也是按供献率由大到小分列）。
% coef：是系数矩阵。经由过程coef可以知道x是如何转换成score的。可以看到各个成分的权重，原始矩阵*coef矩阵
% 就是几个原始数据，分别乘以coef矩阵中各个原始数据对应的权重值相乘，coef中权重以列表示。
% 用你的原矩阵x*coeff(:,1:n)才是你要的的新数据，其中的n是你想降到多少维。?而n的取值取决于对特征值的累计贡献率的计算。
[coef,score,latent,t2] = princomp(x); %#ok<PRINCOMP>
jg=x*coef(:,1:2); % 想降到2维，用这个，以列表示