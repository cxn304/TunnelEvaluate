# -*- coding: utf-8 -*-
# shift+Tab取消缩进
import os, os.path, sys
from odbAccess import *
from abaqus import *
from abaqusConstants import *
import csv
###################parameters#################################
for i in range(10):
    #Open odb
    # newname = 'DamageData-'+ str(i)+ '.csv' # 不论是csv还是txt都可以直接写
    elname = 'elDamageData-'+ str(i)+ '.txt'
    noname = 'noDamageData-'+ str(i)+ '.txt'
    eldatafile = open(elname,"a")
    nodatafile = open(noname,"a")
    #csvW = csv.writer(datafile)
    inpName = 'bridgeDamage-' + str(i)
    o3 = session.openOdb(name=inpName+'.odb')
    ao3 = o3.rootAssembly
    io3 = ao3.instances
    il = io3['LIANG-1']
    nl = il.nodes
    el = il.elements
    eleLabel1 = [ele.label for ele in el]
    noLabel1 = [nln.label for nln in nl]
    if ao3.elementSets.has_key('eleSet1'):
        eleSet1 = ao3.elementSets['eleSet1']
    else:
        eleSet1 = ao3.ElementSet(name='eleSet1', elements=(el,))
    if ao3.nodeSets.has_key('nodeSet1'):
        nodeSet1 = ao3.nodeSets['nodeSet1']
    else:
        nodeSet1 = ao3.NodeSet(name='nodeSet1', nodes=(nl,))
    points = []
    for k in range(9):
        points.append(((10, 10, 10*k+0.5),))
        points.append(((-10, 10, 10*k+0.5),))
        points.append(((-10, -10, 10*k+0.5),))
        points.append(((10, -10, 10*k+0.5),))
    print points
    frame = o3.steps['dianya'].frames[-1]
    # fopDIYS = frame.FieldOutput(name='DIYS'+str(i),description='stress triaxiality',
        # type=SCALAR) # 这个是写入结果数据对象
    # fopDIYU = frame.FieldOutput(name='DIYU'+str(i),description='displacement triaxiality',
        # type=VECTOR)
    fopS = frame.fieldOutputs['S']
    fopU = frame.fieldOutputs['U']
    fopSFromEle = fopS.getSubset(region=eleSet1).values
    fopUFromNode = fopU.getSubset(region=nodeSet1).values
    # wbfopSFromEle = []
    ST = [(SFromEle.press/SFromEle.mises if SFromEle.mises>1.0 else 0.0,) 
        for SFromEle in fopSFromEle]
    # fopDIYS.addData(position=CENTROID, instance=il, labels=eleLabel1,
        # data=ST)
    UU = [UFromNode.magnitude for UFromNode in fopUFromNode]
    # fopDIYU.addData(position=NODAL, instance=il, labels=noLabel1, data=UU) # 这个有毛病
    # datafile.write(str(wbfopSFromEle))
    for ll in range(len(fopSFromEle)):
        print >> eldatafile ,fopSFromEle[ll] # 把print输入到文件
        print >> eldatafile ,el[ll]
    eldatafile.close()
    for ll in range(len(fopUFromNode)):
        print >> nodatafile ,fopUFromNode[ll] # 把print输入到文件
        print >> nodatafile ,nl[ll]
    nodatafile.close()
    if i==0:
        break

j=1