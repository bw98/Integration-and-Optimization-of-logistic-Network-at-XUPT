function fit=fitness(individual, FaToDistribution, Chengben)
%计算个体适应度值
%individual    input      个体
%fit           output     适应度值
%城市坐标
city_coordinate=[2000,2200;1300,2100;1000,1700;6843,4063;6838,4063;6400,4012;7145,4008;6912,4063;6405,3931;4800,3500;
4100,3200;4700,3100;4200,3500;4821,3418;7300,4700;7000,4500;7300,4700;8100,5000;8500,5000;8450,4820;
8450,4825;10500,1900;10200,1900;9930,1200;9900,946;10065,1140;9880,942;10305,1200;10700,323;10197,2800;
10107,2740;9650,2740;9647,2698;10227,3370;10230,2370;10200,2600;10200,2340;10150,2370;
865,2203;1200,2130;450,1210;853,828;6087,4398;6511,4403;6195,4050;6200,4200;6405,3950;6395,4020;
4630,3560;4760,3590;4910,3560;4915,3630;4280,3140;4370,3144;4460,3142;4760,3150;4690,3140;7012,4403;
7318,4394;7700,4600;8040,4903;8020,4780;8090,4850;8010,4920;10150,2700;10010,2760;10010,2680;10360,2710;
10360,2800;10520,2800;10520,2710;10100,2440;10115,2530;10540,2420;10460,2420;10510,2540;10880,438;10775,395;
10640,373;10150,1380;9950,1355;9900,1025;9900,925;9900,800;10020,1500;10030,1420;10300,1800;10500,1800];
%货物量,前七个是网点的最大服务量
carge=[1000,700,800,300,300,600,1000,500,600,1000, ...
1000,400,700,600,300,1000,400,1000,500,600, ...
600,1000,600,1000,1000,1000,500,500,1000,300, ...
300,300,300,600,500,1000,300,600, ...
440,430,120,130,380,390,110,120,180,190, ...
170,140,140,150,190,180,170,180,180,270, ...
260,130,260,220,110,200,110,110,100,160, ...
110,110,160,60,70,170,160,330,100,170, ...
70,150,150,80,150,220,260,260,220,220];

%找出最近配送点
for i=1:(88-38)
    distance(i,:)=dist(city_coordinate(i+38,:),city_coordinate(individual,:)');
    %city_coordinate(i,:)的行向量与city_coordinate(individual,:)的列向量的欧氏距离
end

[a,b]=min(distance');
[c,d]=sort(distance');
TotalExp=zeros(1,50);

%计算费用
Curr=carge(1:38);
c=c';
d=d';
for i=1:(88-38)
    Tindex=1;
    Cindex=d(i,Tindex);
    Len=c(i,Tindex);
    %Qindex=b(i);
    qq=find(d(i,:)==b(i));
    flag=0;
    while flag==0
        if Curr(Cindex)>=carge(i+38)
            Curr(Cindex)=Curr(Cindex)-carge(i+38);
            Len=c(i,Tindex);
            b(i)=Cindex;
            a(i)=Len;
            flag=1;
        else
            Tindex=Tindex+1;
            if Tindex > 2
                Tindex = 2;
                break;
            end           
            Cindex=d(i,Tindex);
        end
    end
    expense(i)=carge(i+38)*Len*10;
    TotalExp(i)=TotalExp(i);
end

%距离大于3000取一个惩罚值
BuildingCost=sum(Chengben(individual));
fit=sum(expense) + 4.0e+4*length(find(a>3000)) + BuildingCost + sum(TotalExp);

end
