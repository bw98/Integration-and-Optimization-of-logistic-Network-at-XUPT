%% 免疫优化算法在物流配送中心选址中的应用
%% 清空环境
clc
clear

%% 算法基本参数
sizepop=50;           % 种群规模
overbest=10;          % 记忆库容量
MAXGEN=100;            % 迭代次数
pcross=0.5;           % 交叉概率
pmutation=0.4;        % 变异概率
ps=0.95;              % 多样性评价参数
length=7;             % 配送中心(网点)最大数量
available=length;
M=sizepop+overbest;

%城市坐标
%假设配送中心的坐标是前7个
city_coordinate=[457,249;459,251;455,247;461,253;350,940;242,82;181,93;
794,617;790,573;804,664;806,711;86,195;132,165;49,153;124,128;39,117;41,95;120,95;305,160;
425,160;310,120;425,120;295,85;375,85;445,85;770,413;690,409;630,410;795,326;688,325;625,325;
787,249;688,247;611,248;772,209;695,209;605,209];

carge=[960,910,860,880,540,600,3720,...
26,39,29,30,65,38,37,37,38,26,26,38,38,36,37,36,39,37,6,4,3,4,3,3,5,2,2,2,3,1];

[qqq, ppp]=size(city_coordinate);
FaToDistribution=[]; %配送中心到客户点的距离;
Chengben=[60000, 60000, 60000, 60000, 60000, 60000, 60000]; %建立配送中心需要的成本

trace=[]; %记录每代最个体优适应度和平均适应度
RecordBest=[]; %迭代寻优
row=1;
bestChromValue=zeros(row,length);
minCargo=2;%待选配送中心的最少个数
maxCargo=7;%待选配送中心的最多个数
maxlenmin=minCargo-1;
to=maxCargo-minCargo+1;

%% step1 识别抗原,将种群信息定义为一个结构体
individuals = struct('fitness',zeros(1,M), 'concentration',zeros(1,M),'excellence',zeros(1,M),'chrom',[]);

h=waitbar(0, '请稍等，正在准备计算...');
for num=minCargo:maxCargo
    %% step2 产生初始抗体群
    individuals.chrom = popinit(M,length,num);
    qwe=num-maxlenmin;
    for iii=1:MAXGEN
        q=(qwe-1)*MAXGEN+iii;
        %% step3 抗体群多样性评价
        for i=1:M
            individuals.fitness(i) = fitness(individuals.chrom(i,:),FaToDistribution, Chengben);      % 抗体与抗原亲和度(适应度值）计算
            individuals.concentration(i) = concentration(i,M,individuals); % 抗体浓度计算
        end
        % 综合亲和度和浓度评价抗体优秀程度，得出繁殖概率
        individuals.excellence = excellence(individuals,M,ps);
          
        % 记录当代最佳个体和种群平均适应度
        [best,index] = min(individuals.fitness);   % 找出最优适应度 
        bestchrom = individuals.chrom(index,:);    % 找出最优个体
        average = mean(individuals.fitness);       % 计算平均适应度
        trace = [trace;best,average];              % 记录
     
        %% step4 根据excellence，形成父代群，更新记忆库（加入精英保留策略，可由s控制）
        bestindividuals = bestselect(individuals,M,overbest);   % 更新记忆库
        individuals = bestselect(individuals,M,sizepop);        % 形成父代群

        %% step5 选择，交叉，变异操作，再加入记忆库中抗体，产生新种群
        individuals = Select(individuals,sizepop);                                  % 选择
        individuals.chrom = Cross(pcross,individuals.chrom,sizepop,num);            % 交叉
        individuals.chrom = Mutation(pmutation,individuals.chrom,sizepop,num,available,num);      % 变异
        individuals = incorporate(individuals,sizepop,bestindividuals,overbest);    % 加入记忆库中抗体
        waitbar(q/(to*MAXGEN), h, '请等待...');
    end
    bestChromValue(num,1:num)=bestchrom;
    RecordBest=[RecordBest,best];

    %% 画出免疫遗传算法收敛曲线
    text1=['使用',num2str(num),'个网点的进化图'];
    figure('NumberTitle','off','Name',text1)
    plot(trace(:,1));
    hold on
    plot(trace(:,2),'--');
    legend('最优适应度值','平均适应度值')
    title('免疫遗传算法收敛曲线','fontsize',12)
    xlabel('迭代次数','fontsize',12)
    ylabel('适应度值','fontsize',12)
    mintrace=min(trace(:,1));
    text2=['使用',num2str(num),'个网点的最小成本为'];
    disp(text2);
    disp([mintrace]);
    trace=[];
end
waitbar(1,h,'已完成');
pause(1);
delete(h);
[bestDist,bestIndex]=min(RecordBest);
num=bestIndex+minCargo-1;
Origbestchrom=bestChromValue(num,:);
bestchromindex=find(Origbestchrom~=0);
bestchrom=Origbestchrom(bestchromindex);

%% 画出配送中心选址图
%找出最近配送点
for i=1:(qqq-7)
    distance(i,:)=dist(city_coordinate(i+7,:),city_coordinate(bestchrom,:)');
end
[a,b]=min(distance');

index=cell(1,length);

for i=1:num
    %计算各个派送点的地址
    index{i}=find(b==i);
end
figure('NumberTitle','off','Name','最优分配方案')
title('最优规划派送路线')
cargox=city_coordinate(bestchrom,1);
cargoy=city_coordinate(bestchrom,2);
loc=[cargox,cargoy]
plot(cargox,cargoy,'rs','LineWidth',2,...
    'MarkerEdgeColor','r',...
    'MarkerFaceColor','b',...
    'MarkerSize',20)
hold on

plot(city_coordinate(:,1),city_coordinate(:,2),'o','LineWidth',2,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor','g',...
    'MarkerSize',10)

for i=1:(qqq-7)
    x=[city_coordinate(i+7,1),city_coordinate(bestchrom(b(i)),1)];
    y=[city_coordinate(i+7,2),city_coordinate(bestchrom(b(i)),2)];
    plot(x,y,'c');hold on
end
for i=1:qqq
    text(city_coordinate(i,1)+100,city_coordinate(i,2)+100, num2str(i),'color',[1, 0, 0]);
end

