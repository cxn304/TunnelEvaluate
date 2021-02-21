%% ����Է���
clear
[jihe,itemsl] = qiepian('Result.csv');
tpt=jihe{4,3}(floor(2:(length(jihe{4,3})-1)/(length(jihe{4,2})-1):length(jihe{4,3}))); % ������ϵ�x����,ԭʼ����
sl=jihe{4,2}(2:length(jihe{4,2}),1); % ������ϵ�y���ݣ�ԭʼ����
figure
cdfplot(tpt); % ���ۻ��ֲ�����
[hh,pp] = kstest(tpt); % KS����,hh=0����������̬�ֲ���hh=1����������̬�ֲ���pp��ʾpֵ��Խ��Խ������̬�ֲ�
X = [ones(size(sl)),tpt];
[b,bint,r,rint,stats] = regress(sl,X,0.05); % regress��y����x���ٺ���������
%b �ع�ϵ��
%bint �ع�ϵ�����������
%r �в�
%rint �в���������
%stats ���ڼ���ع�ģ�͵�ͳ���������ĸ���ֵ�����ϵ��R2��Fֵ����F��Ӧ�ĸ���p��
%������ϵ��R2Խ�ӽ�1��˵���ع鷽��Խ������F > F1-����k��n-k-1��ʱ�ܾ�H0��FԽ��˵���ع鷽��Խ������
%��F��Ӧ�ĸ���p ʱ�ܾ�H0���ع�ģ�ͳ�����pֵ��0.01-0.05֮�䣬ԽСԽ�á�
ycy = b(2:length(b)).*tpt+b(1); % Ԥ��ģ��
figure
plot(ycy)
hold on
plot(sl)
%% ��ͼ
for i = 1:itemsl
    figure
    plot(jihe{2,i}(:,2))
    title(jihe{1,i})
    xlabel('t')
    ylabel('value')
end
%% �����ܶȷֲ�weibull�ֲ�
junz = mean(jihe{2,3}(:,2)); % ��ֵ
bzcha = sqrt(var(jihe{2,3}(:,2))); % ��׼��
xc = (bzcha/junz)^-1.086; % ��״����
cc = junz/gamma(1+1/xc); % �߶Ȳ���
h = histogram(jihe{2,3}(:,2),16); % ��ֱ��ͼ�����ܶȷֲ���״ͼ
nhcs = makedist('Weibull', 'a', cc, 'b', xc); % ��weibull�ֲ�
x = 0:0.1:30; % ��ȡֵ����
y = pdf(nhcs,x); % �������ܶ��������
figure
plot(x,y)
T = 10:10:100; % ��������
xmax = cc*(log(T)).^(1/xc); % �������ڱ������ܳ��ֵ����ֵ
%% ��Чϵ����
myzhbyxz(1,:)=[200,10,1,1,0.5,100]; % ����ֵ
myzhbyxz(2,:)=[5,2,0,0,0,5]; % ������ֵ
x=zeros(12,length(myzhbyxz)); % �������
for i=1:12
    x(i,:)=rand(1,length(myzhbyxz)).*myzhbyxz(1,:);
end
e=zeros(12,length(myzhbyxz));
for i=1:12
    for j=1:length(myzhbyxz)
    e(i,j)=(x(i,j)-myzhbyxz(2,j))/(myzhbyxz(1,j)-myzhbyxz(2,j))*40+60; % efficiency_coefficient
    end
end
%% ���ɷַ���
% x��ΪҪ�����nάԭʼ���ݡ��������matlab�Դ����������������µ�nά�ӹ�������ݣ���score����
% ��������֮ǰ��nάԭʼ����һһ��Ӧ��
% score�����ɵ�nά�ӹ�������ݴ���score����Ƕ�ԭʼ���ݽ��еĽ������������µ�����ϵ�»�õ����ݡ�
% ������nά���ݰ��������ɴ�С���С������ڸı�����ϵ�ľ����£��ֶ�nά��������
% latent����һά��������ÿһ�������Ƕ�Ӧscore����Ӧά�Ĺ����ʣ���Ϊ��ռ��nά������������n�����ݡ�
% �ɴ�С���У���ΪscoreҲ�ǰ��������ɴ�С���У���
% coef����ϵ�����󡣾��ɹ���coef����֪��x�����ת����score�ġ����Կ��������ɷֵ�Ȩ�أ�ԭʼ����*coef����
% ���Ǽ���ԭʼ���ݣ��ֱ����coef�����и���ԭʼ���ݶ�Ӧ��Ȩ��ֵ��ˣ�coef��Ȩ�����б�ʾ��
% �����ԭ����x*coeff(:,1:n)������Ҫ�ĵ������ݣ����е�n�����뽵������ά��?��n��ȡֵȡ���ڶ�����ֵ���ۼƹ����ʵļ��㡣
[coef,score,latent,t2] = princomp(x); %#ok<PRINCOMP>
jg=x*coef(:,1:2); % �뽵��2ά������������б�ʾ