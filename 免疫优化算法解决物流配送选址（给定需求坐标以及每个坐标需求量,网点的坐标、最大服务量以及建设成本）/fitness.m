function fit=fitness(individual, FaToDistribution, Chengben)
%计算个体适应度值
%individual    input      个体
%fit           output     适应度值
%城市坐标
city_coordinate=[457,249;459,251;455,247;461,253;350,940;242,82;181,93;794,617;790,573;
804,664;806,711;86,195;132,165;49,153;124,128;39,117;41,95;120,95;305,160;425,160;
310,120;425,120;295,85;375,85;445,85;770,413;690,409;630,410;795,326;688,325;
625,325;787,249;688,247;611,248;772,209;695,209;605,209];
%货物量,前七个是网点的最大服务量
carge=[960,910,860,880,540,600,3720,...
26,39,29,30,65,38,37,37,38,26,26,38,38,36,37,36,39,37,6,4,3,4,3,3,5,2,2,2,3,1];

%找出最近配送点
for i=1:(37-7)
    distance(i,:)=dist(city_coordinate(i+7,:),city_coordinate(individual,:)');
    %city_coordinate(i,:)的行向量与city_coordinate(individual,:)的列向量的欧氏距离
end

[a,b]=min(distance');
[c,d]=sort(distance');
TotalExp=zeros(1,30);

%计算费用
Curr=carge(1:7);
c=c';
d=d';
for i=1:(37-7)
    Tindex=1;
    Cindex=d(i,Tindex);
    Len=c(i,Tindex);
    %Qindex=b(i);
    qq=find(d(i,:)==b(i));
    flag=0;
    while flag==0
        if Curr(Cindex)>=carge(i+7)
            Curr(Cindex)=Curr(Cindex)-carge(i+7);
            Len=c(i,Tindex);
            b(i)=Cindex;
            a(i)=Len;
            flag=1;
        else
            Tindex=Tindex+1;
            Cindex=d(i,Tindex);
        end
    end
    expense(i)=carge(i+7)*Len*10;
    TotalExp(i)=TotalExp(i);
end

%距离大于3000取一个惩罚值
BuildingCost=sum(Chengben(individual));
fit=sum(expense) + 4.0e+4*length(find(a>3000)) + BuildingCost + sum(TotalExp);

end
