function pop = popinit(n,length,num)
%种群初始化函数(记忆库库为空，全部随机产生)
% n       input    种群数量
% length  input    抗体长度
% pop     output   初始种群
for i=1:n
    flag=0;
    while flag==0
        pop(i,:)=sort(randperm(length,num)); %有疑问，用法不对
        flag=1;
    end
end
