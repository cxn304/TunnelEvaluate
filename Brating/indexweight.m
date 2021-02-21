% ����ָ��Ȩ�ؼ���
function [rweight]=indexweight(a)  % a�������ָ�����Ҫ�Գ̶�����1��n��
cd=length(a);
C=zeros(cd,cd);
O=zeros(cd,cd);
A=zeros(cd,cd);
for i=1:cd
    for j=1:cd
        if a(i)>a(j)
            C(i,j)=1;
        elseif a(i)<a(j)
            C(i,j)=-1;
        end
    end
end
for i=1:cd
    for j=1:cd
        O(i,j)=(sum(C(i,:))+sum(C(:,j)))/cd;
        A(i,j)=exp(O(i,j));
    end
end
[x,y]=eig(A);%����������ֵ������������xΪ������������yΪ����ֵ����
eigenvalue=diag(y);%��Խ�������
lamda=max(eigenvalue);%���������ֵ
for i=1:length(A)%���������ֵ��Ӧ������
    if lamda==eigenvalue(i)
        break;
    end
end
y_lamda=x(:,i);%������������ֵ��Ӧ����������
rweight = y_lamda/sum(y_lamda); %��һ��Ȩ�غ���,�����,����Ȩ����W
end
