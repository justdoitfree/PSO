
function [ParSwarm,OptSwarm,MaxV,MinV]=InitSwarm(SwarmSize,ParticleSize,ParticleScope,Integer)
 %[ParSwarm,OptSwarm,BadSwarm]=InitSwarm(SwarmSize,ParticleSize,ParticleScope,AdaptFunc)
 %
 %输入参数：SwarmSize:种群大小的个数
 %输入参数：ParticleSize：一个粒子的维数,其中前Integer个是整数变量，其它为非整数变量；
 %输入参数：ParticleScope:一个粒子在运算中各维的范围；
 %　　ParticleScope格式:
 %　　3维粒子的ParticleScope格式:
 %                               [x1Min,x1Max]
 %　　　　　　　　　　　　　　　　  x2Min,x2Max
 %                                x3Min,x3Max]
 %
 %输入参数：AdaptFunc：适应度函数
 %输入参数：Integer: 变量（粒子维数）中整数变量的个数
 %输出：ParSwarm初始化的粒子群
 %输出：OptSwarm粒子群当前最优解与全局最优解
 %

 %初始化粒子群矩阵
 %初始化粒子群矩阵，全部设为[0-1]随机数
 %rand('state',0);
 %ParSwarm前ParticleSize列为位置参数，ParticleSize~2*ParticleSize列为速度参数，最后为适应度函数
  
  
  %随机生成粒子,构建种群，有下面三种方法，；
  ParSwarm=rand(SwarmSize,2*ParticleSize+1);  
 
  %{
  %1.按种群数量的倍数进行循环，每次寻找一个最优粒子，对与可行域比较小的问题，
    %需要加大倍数才能得到比较好的初始点，需要不断尝试，对计算速度的影响比较大；
  for n=1:SwarmSize
    Swarm=rand(20000*SwarmSize,ParticleSize);
    for i=1:ParticleSize
      Swarm(:,i)=Swarm(:,i)*(ParticleScope(i,2)-ParticleScope(i,1))+ParticleScope(i,1);
    end
     adapt=AdaptFunc(Swarm(:,1:ParticleSize));
    [maxValue,row]=max(adapt);
    ParSwarm(n,1:ParticleSize)=Swarm(row,1:ParticleSize);
  end
  %}
 
  
 
  %2.用while语句筛选出符合不等式约束的粒子，但是筛选因数受主观因素影响较大
  Filter=-100000;       %筛选因数,根据罚函数确定；
 for n=1:SwarmSize
      Swarm=rand(1,ParticleSize);
      for i=1:ParticleSize
                Swarm(1,i)=Swarm(1,i)*(ParticleScope(i,2)-ParticleScope(i,1))+ParticleScope(i,1);
      end
      while (1)
          if AdaptFunc(Swarm(1,:))>Filter   
              break;
          else
              Swarm=rand(1,ParticleSize);
              for i=1:ParticleSize
                Swarm(1,i)=Swarm(1,i)*(ParticleScope(i,2)-ParticleScope(i,1))+ParticleScope(i,1);
             end
          end
      end
      ParSwarm(n,1:ParticleSize)=Swarm(1,:);
 end
  
  %{
  %3.用while语句筛选出符合不等式约束的一个“好的”粒子，以此为中心，可行域为直径，向任意方向生长，形成种群，
     %缺点在于，如果筛选出的粒子不够“好”，容易陷入局部最优解!!!；
     Filter=-100000;       %筛选因数,根据罚函数确定；
     Swarm=rand(1,ParticleSize);
      for i=1:ParticleSize
                Swarm(1,i)=Swarm(1,i)*(ParticleScope(i,2)-ParticleScope(i,1))+ParticleScope(i,1);
      end
      while (1)
          if AdaptFunc(Swarm(1,:))>Filter   
              break;
          else
              Swarm=rand(1,ParticleSize);
              for i=1:ParticleSize
                Swarm(1,i)=Swarm(1,i)*(ParticleScope(i,2)-ParticleScope(i,1))+ParticleScope(i,1);
             end
          end
      end 
      ParSwarm(1,1:ParticleSize)=Swarm(1,:);   %筛选出的“好的”粒子，整个种群的“母代”粒子；
      for n=2:SwarmSize
          for i=1:ParticleSize
               ParSwarm(n,i)=ParSwarm(1,i)+0.5*(2*rand-1)*(ParticleScope(i,2)-ParticleScope(i,1));
              if ParSwarm(n,i)>ParticleScope(i,2)
                  ParSwarm(n,i)=ParticleScope(i,2);
              end
              if ParSwarm(n,i)<ParticleScope(i,1)
              ParSwarm(n,i)=ParticleScope(i,1);
              end
          end
      end
   %}       
          
  %自变量的整数约束，上面的算法有的可以满足要求，不满足的已经在程序中写入；
  %{
  for i=1:SwarmSize
      for j=1:ParticleSize
          if ParSwarm(i,j)>ParticleScope(j,2)
              ParSwarm(i,j)=ParticleScope(j,2);
          end
          if ParSwarm(i,j)<ParticleScope(j,1)
              ParSwarm(i,j)=ParticleScope(j,1);
          end
      end
  end
  %}
              
 
 %初始速度设置
 for i=1:Integer
    ParSwarm(:,i)=floor(ParSwarm(:,i));   %将整数变量整数化
    %调节速度，使速度与位置的范围一致
    ParSwarm(:,ParticleSize+i)=0.2*(ParSwarm(:,ParticleSize+i)*(ParticleScope(i,2)-ParticleScope(i,1))+ParticleScope(i,1));
 end
 for i=Integer+1:ParticleSize
     ParSwarm(:,i)=ParSwarm(:,i);        %保持非整数变量不变
    %调节速度，使速度与位置的范围一致
    ParSwarm(:,ParticleSize+i)=0.2*(ParSwarm(:,ParticleSize+i)*(ParticleScope(i,2)-ParticleScope(i,1))+ParticleScope(i,1));
 end
 
 
 
 %{
  for h=1:SwarmSize
  %初始筛选粒子，借鉴罚函数法思路,判断条件运行缓慢
    Punish=(max((ParSwarm(h,1)+ParSwarm(h,2)+ParSwarm(h,3)+ParSwarm(h,4)+ParSwarm(h,5)-400),0)).^2+(max((ParSwarm(h,1)+2*ParSwarm(h,2)+2*ParSwarm(h,3)+ParSwarm(h,4)+6*ParSwarm(h,5)-800),0))^.2+(max((2*ParSwarm(h,1)+ParSwarm(h,2)+6*ParSwarm(h,3)-200),0)).^2+(max((ParSwarm(h,3)+ParSwarm(h,4)+5*ParSwarm(h,5)-200),0)).^2;
    while(1)
       if Punish==0
           break;
       else
         random=rand;
         for i=1:Integer
              ParSwarm(h,:)=floor(ParSwarm(h,:)*random);
         end
         for i=Integer+1:ParticleSize
             ParSwarm(:,i)=ParSwarm(:,i)*(ParticleScope(i,2)-ParticleScope(i,1))+ParticleScope(i,1);
         end
       end
       Punish=(max((ParSwarm(h,1)+ParSwarm(h,2)+ParSwarm(h,3)+ParSwarm(h,4)+ParSwarm(h,5)-400),0)).^2+(max((ParSwarm(h,1)+2*ParSwarm(h,2)+2*ParSwarm(h,3)+ParSwarm(h,4)+6*ParSwarm(h,5)-800),0))^.2+(max((2*ParSwarm(h,1)+ParSwarm(h,2)+6*ParSwarm(h,3)-200),0)).^2+(max((ParSwarm(h,3)+ParSwarm(h,4)+5*ParSwarm(h,5)-200),0)).^2;
    end
  end
 %}
 MaxV=zeros(1,ParticleSize);
 MinV=zeros(1,ParticleSize);
 for i=1:ParticleSize
     MaxV(1,i)=0.2*(ParticleScope(i,2)-ParticleScope(i,1));
     MinV(1,i)=-0.2*(ParticleScope(i,2)-ParticleScope(i,1));
 end
 
%对每一个粒子计算其适应度函数的值
for i=1:SwarmSize
    ParSwarm(i,2*ParticleSize+1)=AdaptFunc(ParSwarm(i,1:ParticleSize));
end

 %初始化粒子群最优解矩阵
 OptSwarm=zeros(SwarmSize+1,ParticleSize);
 %粒子群最优解矩阵全部设为零
 [maxValue,row]=max(ParSwarm(:,2*ParticleSize+1));
 %寻找适应度函数值最大的解在矩阵中的位置(行数)
 OptSwarm=ParSwarm(1:SwarmSize,1:ParticleSize);
 %粒子最优解位置参数
 OptSwarm(SwarmSize+1,:)=ParSwarm(row,1:ParticleSize);
 %种群最优解位置参数
end




