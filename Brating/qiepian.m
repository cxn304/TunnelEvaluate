% function [jihe,itemsl] = qiepian(result)  jiheΪ����������ݣ�itemslΪ�����������result��������ݿ���ȡ��ԭʼ����
function [jihe,itemsl] = qiepian(result)
    Data = readtable(result); % �ô˷�����ȡcsv�ļ����table��ʽ
    node_id = Data{:,3}; % ע���ǻ�����
    monitor_item = Data{:,4}; % ע���ǻ�����
    monitor_value = Data{:,5};
    monitor_time = Data{:,6};
    % zongsj = length(monitor_item);
    Monitoring = unique(monitor_item(1:500)); % ���Դ���unique�����������һ�������в�ͬԪ��
%     Monitoring(1) = monitor_item(1); % ���������Ŀ�����б�
%     for i = 2:500
%         if sum(strcmp(Monitoring,monitor_item(i))) == 0 % ��������Ŀ����Monitoring�����У����������Ͼ���
%             j = j+1;
%             Monitoring(j) = monitor_item(i);
%         end
%     end
    itemsl = length(Monitoring);
    jihe = cell(4,itemsl); % �������Ŀ��Ƭ��Ԫ������һ�д������ƣ��ڶ�����2�����飬��һ�нڵ��ţ��ڶ��м����ֵ�������б�ʾʱ��
    for i = 1:itemsl
        jihe(1,i) = Monitoring(i);
        zwz = strcmp(monitor_item,Monitoring(i)); % logical array
        ind0 = find(zwz==1); % tempλ��
        itemqp(1:length(ind0),1) = node_id(ind0,:); % ȡ������disp�����м�����ͬ��㣬����Ҫ��ֵ�.
        itemqp(1:length(ind0),2) = monitor_value(ind0,:);
        jihe{2,i} = itemqp;
        jihe{3,i} = monitor_time(ind0,:);
        clear itemqp
    end
    for i = 1:itemsl
        temp2 = unique(jihe{2,i}(:,1)); % �����һ������,���ظ�ֵ�޳�,��i���������͵Ľڵ���,��ʾ���м����ڵ�
        for j = 1:length(temp2) % size�ǿ������С
            weizhi = find(jihe{2,i}(:,1)==temp2(j)); % ������������λ��,ÿ���ڵ㾭ʱ�仯����
            shuju(1,j) = temp2(j);
            shuju(2:length(weizhi)+1,j) = jihe{2,i}(weizhi,2);
        end
%         mingcheng = Monitoring{i}; % ��cell����ת��Ϊstring����
    %     save(mingcheng,'shuju');
        jihe{4,i} = shuju; % ÿ���ڵ㾭ʱ�仯����
        clear shuju
    end
end