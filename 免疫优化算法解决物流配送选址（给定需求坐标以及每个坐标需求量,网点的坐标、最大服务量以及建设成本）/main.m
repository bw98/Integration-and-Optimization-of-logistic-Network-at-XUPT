%% 免疫优化算法在物流配送中心选址中的应用
%% 清空环境
clc
clear
close all
%% 算法基本参数
sizepop=50;           % 种群规模
overbest=10;          % 记忆库容量
MAXGEN=100;            % 迭代次数
pcross=0.5;           % 交叉概率
pmutation=0.4;        % 变异概率
ps=0.95;              % 多样性评价参数
length=38;             % 配送中心(网点)最大数量
available=length;
M=sizepop+overbest;

%城市坐标
%假设配送中心的坐标是前7个
city_coordinate=[2000,2200;1300,2100;1000,1700;6843,4063;6838,4063;6400,4012;7145,4008;6912,4063;6405,3931;4800,3500;
4100,3200;4700,3100;4200,3500;4821,3418;7300,4700;7000,4500;7300,4700;8100,5000;8500,5000;8450,4820;
8450,4825;10500,1900;10200,1900;9930,1200;9900,946;10065,1140;9880,942;10305,1200;10700,323;10197,2800;
10107,2740;9650,2740;9647,2698;10227,3370;10230,2370;10200,2600;10200,2340;10150,2370;
865,2203;1200,2130;450,1210;853,828;6087,4398;6511,4403;6195,4050;6200,4200;6405,3950;6395,4020;
4630,3560;4760,3590;4910,3560;4915,3630;4280,3140;4370,3144;4460,3142;4760,3150;4690,3140;7012,4403;
7318,4394;7700,4600;8040,4903;8020,4780;8090,4850;8010,4920;10150,2700;10010,2760;10010,2680;10360,2710;
10360,2800;10520,2800;10520,2710;10100,2440;10115,2530;10540,2420;10460,2420;10510,2540;10880,438;10775,395;
10640,373;10150,1380;9950,1355;9900,1025;9900,925;9900,800;10020,1500;10030,1420;10300,1800;10500,1800];

carge=[1000,700,800,300,300,600,1000,500,600,1000, ...
1000,400,700,600,300,1000,400,1000,500,600, ...
600,1000,600,1000,1000,1000,500,500,1000,300, ...
300,300,300,600,500,1000,300,600, ...
440,430,120,130,380,390,110,120,180,190, ...
170,140,140,150,190,180,170,180,180,270, ...
260,130,260,220,110,200,110,110,100,160, ...
110,110,160,60,70,170,160,330,100,170, ...
70,150,150,80,150,220,260,260,220,220];

[qqq, ppp]=size(city_coordinate);
FaToDistribution=[]; %配送中心到客户点的距离;
Chengben=[60000, 60000, 60000, 60000, 60000, 60000, 60000, ...
    60000, 60000, 60000, 60000, 60000, 60000, 60000, ...
    60000, 60000, 60000, 60000, 60000, 60000, 60000, ...
    60000, 60000, 60000, 60000, 60000, 60000, 60000, ...
    60000, 60000, 60000, 60000, 60000, 60000, 60000, ...
    60000, 60000, 60000]; %建立配送中心需要的成本

trace=[]; %记录每代最个体优适应度和平均适应度
RecordBest=[]; %迭代寻优
row=1;
bestChromValue=zeros(row,length);
minCargo=2;%待选配送中心的最少个数
maxCargo=38;%待选配送中心的最多个数
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
for i=1:(qqq-38)
    distance(i,:)=dist(city_coordinate(i+38,:),city_coordinate(bestchrom,:)');
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

for i=1:(qqq-38)
    x=[city_coordinate(i+38,1),city_coordinate(bestchrom(b(i)),1)];
    y=[city_coordinate(i+38,2),city_coordinate(bestchrom(b(i)),2)];
    plot(x,y,'c');hold on
end
for i=1:qqq
    text(city_coordinate(i,1)+100,city_coordinate(i,2)+100, num2str(i),'color',[1, 0, 0]);
end

