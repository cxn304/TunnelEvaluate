# TunnelEvaluate
Tunnel Evaluate using matlab and python
## dg_degradation.m
rebar degradation 锈蚀盾构管片承载力计算模型，时程变化承载力计算
考虑锈蚀钢筋截面损失率、等效截面面积、钢筋与混凝土协同工作系数，计算钢筋锈蚀与混凝土开裂导致的管片正截面承载力损失。
## efficiency_coefficient_method.m
功效系数法：计算概率密度分布weibull分布并用功效系数法判定监测数据的满意值和不允许值
## fenji.m
b为输出单个因素隶属度矩阵，a为输入监测数据（单个），dd为监测数据类型，参考论文分类评价指标类别。主要用于结构健康分级
## indexweight.m
评价指标权重计算，通过各个指标的重要性程度列阵，指标权重的确定基于层次分析法
## jkpj.m
利用fenji.m里面的隶属度矩阵和indexweight里面的层次分析法的指标权重计算给出最终分级结果
## long_term_stability.m
考虑材料属性，计算时采用水土合算，考虑土的属性，自重，竖向荷载，水平荷载，三角形侧压，地层抗力计算弯矩和轴力。
提取dg_degradation计算出的劣化模型数据，根据公路隧道设计规范计算安全系数，得到考虑碳化深度影响。得到截面最小安全系数经时变化结果
## qiepian.m
数据预处理，读取mysql数据库中时序数据，用Grubbs准则剔除大于临界系数的异常数据，通过数据规整，提取每个节点经时变化数据
## brigeCutModule.py
abaqus python 二次开发前处理，使用abaqus中的python接口，在前处理中自动完成模型的建立(通过读取inp文件)，设置材料和截面特性(此步骤中通过刚度折减定义不同位置的损伤，通过刚度折减的程度定义损伤严重程度)，定义装配设置分析步和场变量输出，施加载荷和边界条件，划分网格，提交作业进行分析
## brigeCutData.py
abaqus python 二次开发后处理，读取所有节点三维坐标，以隧道模型中点为坐标原点，归一化各节点坐标。读取不同损伤结果下的各节点位移以模拟传感器数据，每个节点上的位移数据储存在一个四维tensor中[x,y,z,3]
