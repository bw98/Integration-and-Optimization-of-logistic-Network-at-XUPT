function ret=Mutation(pmutation,chrom,sizepop,length1,available,num)
% 变异操作
% pmutation        input  : 变异概率
% chrom            input  : 抗体群
% sizepop          input  : 种群规模
% iii              input  : 进化代数
% MAXGEN           input  : 最大进化代数
% length1          input  : 抗体长度
% ret              output : 变异得到的抗体群
% 每一轮for循环中，可能会进行一次变异操作，染色体是随机选择的，变异位置也是随机选择的
for i=1:sizepop   
    
    % 变异概率
    pick=rand;
    while pick==0
        pick=rand;
    end
    index=unidrnd(sizepop);

   % 判断是否变异
    if pick>pmutation
        continue;
    end
    
    pos=unidrnd(length1);
    while pos==1
        pos=unidrnd(length1);
    end
    
    nchrom=chrom(index,:);
    %% 随机数不可与已有的数相同
    nchrom(pos)=unidrnd(available);
    while length(unique(nchrom))==(num-1)
        nchrom(pos)=unidrnd(available);
    end
    
    flag=test(nchrom);
    if flag==1
        chrom(index,:)=nchrom;
    end
    
end

ret=chrom;
end
 
