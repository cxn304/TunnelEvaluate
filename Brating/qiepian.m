% function [jihe,itemsl] = qiepian(result)  jihe为输出的总数据，itemsl为监测项数量，result代表从数据库提取的原始数据
function [jihe,itemsl] = qiepian(result)
    Data = readtable(result); % 用此方法读取csv文件变成table格式
    node_id = Data{:,3}; % 注意是花括号
    monitor_item = Data{:,4}; % 注意是花括号
    monitor_value = Data{:,5};
    monitor_time = Data{:,6};
    % zongsj = length(monitor_item);
    Monitoring = unique(monitor_item(1:500)); % 用自带的unique函数可以求得一个数列中不同元素
%     Monitoring(1) = monitor_item(1); % 监测数据项目名称列表
%     for i = 2:500
%         if sum(strcmp(Monitoring,monitor_item(i))) == 0 % 如果监测项目不在Monitoring矩阵中，则把其加入上矩阵
%             j = j+1;
%             Monitoring(j) = monitor_item(i);
%         end
%     end
    itemsl = length(Monitoring);
    jihe = cell(4,itemsl); % 按监测项目切片后元胞；第一行代表名称，第二行是2列数组，第一列节点编号，第二列监测数值；第三行表示时间
    for i = 1:itemsl
        jihe(1,i) = Monitoring(i);
        zwz = strcmp(monitor_item,Monitoring(i)); % logical array
        ind0 = find(zwz==1); % temp位置
        itemqp(1:length(ind0),1) = node_id(ind0,:); % 取出来的disp数据有几个不同测点，这是要拆分的.
        itemqp(1:length(ind0),2) = monitor_value(ind0,:);
        jihe{2,i} = itemqp;
        jihe{3,i} = monitor_time(ind0,:);
        clear itemqp
    end
    for i = 1:itemsl
        temp2 = unique(jihe{2,i}(:,1)); % 结果是一个数列,把重复值剔除,第i个数据类型的节点编号,表示共有几个节点
        for j = 1:length(temp2) % size是看数组大小
            weizhi = find(jihe{2,i}(:,1)==temp2(j)); % 监测点在数组中位置,每个节点经时变化数据
            shuju(1,j) = temp2(j);
            shuju(2:length(weizhi)+1,j) = jihe{2,i}(weizhi,2);
        end
%         mingcheng = Monitoring{i}; % 把cell类型转换为string类型
    %     save(mingcheng,'shuju');
        jihe{4,i} = shuju; % 每个节点经时变化数据
        clear shuju
    end
end