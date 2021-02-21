# -*- coding: utf-8 -*-
# shift+Tab取消缩进
from math import *
from abaqus import *
from abaqusConstants import *
from caeModules import *
from driverUtils import executeOnCaeStartup
import regionToolset
###################parameters#################################
depths = 100.0
duanshu = depths/10
executeOnCaeStartup()
session.viewports['Viewport: 1'].partDisplay.geometryOptions.setValues(
    referenceRepresentation=ON)
Mdb()
session.viewports['Viewport: 1'].setValues(displayedObject=None)
s = mdb.models['Model-1'].ConstrainedSketch(name='__profile__', 
    sheetSize=200.0)
s.setPrimaryObject(option=STANDALONE)
s.rectangle(point1=(-10.0, -10.0), point2=(10.0, 10.0))
p = mdb.models['Model-1'].Part(name='liang', dimensionality=THREE_D, 
    type=DEFORMABLE_BODY)
p = mdb.models['Model-1'].parts['liang']
p.BaseSolidExtrude(sketch=s, depth=depths)
s.unsetPrimaryObject()
p = mdb.models['Model-1'].parts['liang']
session.viewports['Viewport: 1'].setValues(displayedObject=p)
# 寻找边
es = p.edges
e1 = es.findAt((10,10,10),)
e2 = es.findAt((-10,10,10),)
e3 = es.findAt((10,-10,10),)
e4 = es.findAt((-10,-10,10),)
i = 0
# 储存某条边上所有DatumPoint
pt11=[]
pt22=[]
pt33=[]
pt44=[]
# 循环，按parameter方法在边上布置DatumPoint
while i<0.9:
    i += 0.1
    pt1 = p.DatumPointByEdgeParam(edge=e1,parameter=i)
    pt2 = p.DatumPointByEdgeParam(edge=e2,parameter=i)
    pt3 = p.DatumPointByEdgeParam(edge=e3,parameter=i)
    pt4 = p.DatumPointByEdgeParam(edge=e4,parameter=i)
    pt11.append(pt1)
    pt22.append(pt1)
    pt33.append(pt1)
    pt44.append(pt1)
    if i == 0.9:
        break
d0 = p.datums
session.viewports['Viewport: 1'].view.setValues(nearPlane=174.209, 
    farPlane=284.553, width=81.8137, height=52.4119, cameraPosition=(54.7708, 
    138.784, 224.31), cameraUpVector=(-0.760582, 0.387909, -0.520617), 
    cameraTarget=(-1.32447, -3.04612, 54.3926))
pl11=[]
# 循环Datum Plane By Three Points
for i in range(duanshu):
    pl1 = p.DatumPlaneByThreePoints(point1=d0[4*i+2], 
        point2=d0[4*i+3], point3=d0[4*i+4])
    pl11.append(pl1) # 参考平面的集合
    if i==(duanshu-1):
        break
# 切割平面Partition Cell By Datum Plane
cs = p.cells
d0 = p.datums
for i in range(duanshu):
    print pl11[i].id
    p.PartitionCellByDatumPlane(cells=cs, datumPlane=d0[pl11[i].id]) # 运用参考面切割平面
    cs = p.cells # 切割平面会造成cell数量的增加，要在循环中更新 p.cells
    if i==(duanshu-2):
        break
#Property Material
mdb.models['Model-1'].Material(name='wanhao')
mdb.models['Model-1'].materials['wanhao'].Density(table=((100000.0, ), ))
mdb.models['Model-1'].materials['wanhao'].Elastic(table=((300000.0, 0.3), ))
mdb.models['Model-1'].Material(name='sunshang')
mdb.models['Model-1'].materials['sunshang'].Density(table=((100000.0, ), ))
mdb.models['Model-1'].materials['sunshang'].Elastic(table=((200000.0, 0.3), ))
mdb.models['Model-1'].HomogeneousSolidSection(name='haojiemian', 
    material='wanhao', thickness=None)
mdb.models['Model-1'].HomogeneousSolidSection(name='sjiemian', 
    material='sunshang', thickness=None)
session.viewports['Viewport: 1'].partDisplay.setValues(sectionAssignments=ON, 
    engineeringFeatures=ON)
session.viewports['Viewport: 1'].partDisplay.geometryOptions.setValues(
    referenceRepresentation=OFF)
# Circulation Damage to brige 循环布置损伤单元
for i in range(duanshu):
    points = []
    names = 'Set'+str(i)
    points.append(((0, 0, 10*i+5),))
    c11 = cs.findAt(*points) # *是为了解包，把一组坐标解包成坐标组，findAt相当于分别找出各个坐标所在的cell
    #region = p.Set(cells=myCarray[i], name=names)
    region1 = regionToolset.Region(cells=c11) # SectionAssignment方法要求的是几何序列，*解包出来的值是序列，不然用c11[i]表示就是cell而不是几何序列
    p.SectionAssignment(region=region1, sectionName='sjiemian', offset=0.0, 
        offsetType=MIDDLE_SURFACE, offsetField='', 
        thicknessAssignment=FROM_SECTION) # 循环布置损伤单元
    for j in range(duanshu):
        if j!=i: # 损伤单元只布置一个，其余的为非损伤单元
            points = []
            names = 'Set'+str(j) # 集合命名
            points.append(((0, 0, 10*j+5),))
            c11 = cs.findAt(*points)
            region = p.Set(cells=c11, name=names)
            p.SectionAssignment(region=region, sectionName='haojiemian', offset=0.0, 
                offsetType=MIDDLE_SURFACE, offsetField='', 
                thicknessAssignment=FROM_SECTION)
    #Assembly
    ass = mdb.models['Model-1'].rootAssembly
    session.viewports['Viewport: 1'].setValues(displayedObject=ass)
    session.viewports['Viewport: 1'].assemblyDisplay.setValues(
        optimizationTasks=OFF, geometricRestrictions=OFF, stopConditions=OFF)
    ass.DatumCsysByDefault(CARTESIAN)
    inst = ass.Instance(name='liang-1', part=p, dependent=ON)
    #step and Load-BC 设置场变量和历史变量的输出
    mdb.models['Model-1'].StaticStep(name='dianya', previous='Initial', 
        description='The load to bridge')
    mdb.models['Model-1'].fieldOutputRequests['F-Output-1'].setValues(variables=(
        'S', 'PE', 'PEEQ', 'PEMAG', 'U', 'RF', 'CF'))
    s1 = ass.instances['liang-1'].faces
    # load
    points = []
    points.append(((0,10,depths/2-5),))
    side1Faces1 = s1.findAt(*points) # load是加到面、点、线、体上
    region = ass.Surface(side1Faces=side1Faces1, name='Surf-yali') # rootAssembly层面和part层面的，才有Surface方法。faces层面的没有
    mdb.models['Model-1'].Pressure(name='xhz', createStepName='dianya', 
        region=region, distributionType=UNIFORM, field='', magnitude=3000.0, 
        amplitude=UNSET)
    # boundary Conditon
    points = []
    points.append(((0,0,0),))
    faces1 = s1.findAt(*points) # faces、cell、point、lines层面的用findAt
    region = ass.Set(faces=faces1, name='jz1') # 边界条件是加到集合层面
    mdb.models['Model-1'].PinnedBC(name='jianzhi', createStepName='dianya', 
        region=region, localCsys=None)
    points = []
    points.append(((0,0,depths),))
    faces1 = s1.findAt(*points)
    region = ass.Set(faces=faces1, name='jz-2') # rootAssembly层面和part层面的，才有set方法。faces层面的没有
    mdb.models['Model-1'].PinnedBC(name='jz2', createStepName='dianya', 
        region=region, localCsys=None)
    #Mesh
    p.seedPart(size=2.0, deviationFactor=0.1, minSizeFactor=0.1)
    elemType1 = mesh.ElemType(elemCode=C3D8R, elemLibrary=STANDARD, 
        kinematicSplit=AVERAGE_STRAIN, secondOrderAccuracy=OFF, 
        hourglassControl=DEFAULT, distortionControl=DEFAULT)
    elemType2 = mesh.ElemType(elemCode=C3D6, elemLibrary=STANDARD)
    elemType3 = mesh.ElemType(elemCode=C3D4, elemLibrary=STANDARD)
    pickedRegions =(cs, ) # 全部范围按此方式布种
    p.setElementType(regions=pickedRegions, elemTypes=(elemType1, elemType2, 
        elemType3)) # 如果有多个part，变量p也不同
    p.generateMesh()
    ass.regenerate() # assembly层面重生成
    session.viewports['Viewport: 1'].assemblyDisplay.setValues(mesh=ON)
    session.viewports['Viewport: 1'].assemblyDisplay.meshOptions.setValues(
        meshTechnique=ON)
    #Job and sumbit
    inpName = 'bridgeDamage-' + str(i)
    job = mdb.Job(name=inpName, model='Model-1', numCpus=6, numDomains=6)
    job.submit(consistencyChecking=ON)
    job.waitForCompletion()
    #Open odb
    o3 = session.openOdb(name=inpName+'.odb')
    session.viewports['Viewport: 1'].setValues(displayedObject=o3)
    if i==0:
        break

j=1




################################################################################
