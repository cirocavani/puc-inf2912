# -*- coding: utf-8 -*-
"""
Created on Tue Sep 22 15:24:25 2015

@author: marcuspoggi
"""
import numpy as np

import sys
import math
import random
from gurobipy import *

from bokeh.plotting import figure, show, output_file

# Callback - use lazy constraints to eliminate sub-tours

def subtourelim(model, where):
    if where == GRB.callback.MIPSOL:
        selected = []
        # make a list of edges selected in the solution
        for i in range(n):
            sol = model.cbGetSolution([model._vars[i,j] for j in range(n)])
            selected += [(i,j) for j in range(n) if sol[j] > 0.5]
        # find the shortest cycle in the selected edge list
        tour = subtour(selected)
        if len(tour) < n:
            # add a subtour elimination constraint
            expr = 0
            for i in range(len(tour)):
                for j in range(i+1, len(tour)):
                    expr += model._vars[tour[i], tour[j]]
            model.cbLazy(expr <= len(tour)-1)


# Euclidean distance between two points

def distance(points, i, j):
    dx = points[i][0] - points[j][0]
    dy = points[i][1] - points[j][1]
    return math.sqrt(dx*dx + dy*dy)


# Given a list of edges, finds the shortest subtour

def subtour(edges):
    visited = [False]*n
    cycles = []
    lengths = []
    selected = [[] for i in range(n)]
    for x,y in edges:
        selected[x].append(y)
    while True:
        current = visited.index(False)
        thiscycle = [current]
        while True:
            visited[current] = True
            neighbors = [x for x in selected[current] if not visited[x]]
            if len(neighbors) == 0:
                break
            current = neighbors[0]
            thiscycle.append(current)
        cycles.append(thiscycle)
        lengths.append(len(thiscycle))
        if sum(lengths) == n:
            break
    return cycles[lengths.index(min(lengths))]


# Parse argument

if len(sys.argv) < 3:
    print 'Usage: tsp.py npoints file_name'
    exit(1)
n = int(sys.argv[1])
file_name = str(sys.argv[2])

print " n", n
print " file: ", file_name

# Read File

try:
  # open file stream
  file = open(file_name, "w")
except IOError:
  print "There was an error writing to", file_name
  sys.exit()

#print "Enter '", file_finish,
#print "' When finished"
#while file_text != file_finish:
#  file_text = raw_input("Enter text: ")
#  if file_text == file_finish:
#    # close the file
#    file.close
#    break
#  file.write(file_text)
#  file.write("\n")

#file.close()


if len(file_name) == 0:
  print "Next time please enter something"
  sys.exit()
try:
  file = open(file_name, "w")
except IOError:
  print "There was an error reading file"
  sys.exit()

#file_text = file.read()
#file.close()
#print file_text


# Create n random points

random.seed(1)
points = []
coord_x = range(n)
coord_y = range(n)
for i in range(n):
    points.append((random.randint(0,100),random.randint(0,100)))
    coord_x[i]= points[i][0]
    coord_y[i] = points[i][1]

m = Model()

# Create variables

p = 6

print " p: ",p, " n:", n

vars = {}
for i in range(n):
    for j in range(n):
        vars[i,j] = m.addVar(obj=distance(points, i, j), vtype=GRB.CONTINUOUS,
                             name='x'+str(i)+'_'+str(j))
m.update()

# Add every point is associated to one center

for i in range(n):
    m.addConstr(quicksum(vars[i,j] for j in range(n)) == 1)
m.update()
# Capacity constraint
cap = n/p + 1
print 'cap = ', cap
 
for j in range(n):
    m.addConstr(quicksum(vars[i,j] for i in range(n)) <= cap)
m.update()


for i in range(n):
    for j in range(n):
        if i <> j : 
            m.addConstr(vars[i,j] - vars[j,j] <= 0)
m.update()

m.addConstr(quicksum(vars[i,i] for i in range(n)) <= p)
m.update()


# Optimize model
#m.write("formul.lp")

m._vars = vars
#m.params.LazyConstraints = 1
m.optimize()

solution = m.getAttr('x', vars)
selected = [(i,j) for i in range(n) for j in range(n) if i<>j and solution[i,j] > 0.99]
centers = [i for i in range(n) if solution[i,i] > 0.99]

#assert len(subtour(selected)) == n

print
for i in range(n):
    for j in range(n):
        if solution[i,j] > 0 : 
            print 's[', i, ',', j, ']:', solution[i,j]
print 'Optimal centers:', centers
print 'Optimal links:', selected
print 'Optimal cost:', m.objVal
print


file.write("\n Optimal Cost: %f \n" % float(m.objVal))

for edge in centers:
    print edge
    print "%d" % int(edge)
    file.write(" %s " % str(edge))

file.write("\n Optimal Cost: %f \n" % float(m.objVal))

file.close()

# Draw Solution
colormap = [
    "#444444", "#a6cee3", "#1f78b4", "#b2df8a", "#33a02c", "#fb9a99",
    "#e31a1c", "#fdbf6f", "#ff7f00", "#cab2d6", "#6a3d9a", "#ff00ff",
    "#445544", "#a655e3", "#1f55b4", "#b2558a", "#33552c", "#fb5599",
    "#e3551c", "#fd556f", "#ff5500", "#ca55d6", "#6a559a", "#00ffff",
    "#774444", "#77cee3", "#7778b4", "#00df8a", "#00a02c", "#449a99",
    "#771a1c", "#77bf6f", "#777f00", "#00b2d6", "#003d9a", "#4400ff",
    "#775544", "#7755e3", "#7755b4", "#00558a", "#00552c", "#445599",
    "#77551c", "#77556f", "#775500", "#0055d6", "#00559a", "#44ffff",
    "#775527", "#775527", "#775527", "#005527", "#005527", "#44ff27",
    "#771144", "#7711e3", "#1155b4", "#00228a", "#00222c", "#440099",
    "#77111c", "#77116f", "#115500", "#0022d6", "#44559a", "#4400ff",
    "#771127", "#771127", "#115527", "#002227", "#445527", "#440027"
]


output_file("FracSolution.html", title="pMedian.py example")

p = figure(title=" Objects in the plane ")

for i in range(n):
    if solution[i,i] > 0 : 
        p.scatter(coord_x[i],coord_y[i],radius=3.5, fill_color=colormap[i], line_color="white")

for i in range(n):
    jj = -1
    max = 0
    for j in range(n):
        if solution[i,j] > max:
            max = solution[i,j]
            jj = j   
    p.scatter(coord_x[i],coord_y[i],radius=2.0, fill_color=colormap[jj], line_color="green")
    jjj = -1
    max = 0
    for j in range(n):
        if j <> jj and solution[i,j] > max:
            max = solution[i,j]
            jjj = j
    if jjj >= 0:
        p.scatter(coord_x[i],coord_y[i],radius=1.0, fill_color=colormap[jjj], line_color="blue")





#p.scatter(coord_x,coord_y,radius=1.5, fill_color=colormap, line_color="black")


#p = figure(title="simple line example")
#p.scatter(x,y,marker="square", side=3.5, fill_color="red", line_color="black")

p.ygrid[0].ticker.desired_num_ticks = 20

show(p)


output_file("linear.html", title=" p-media solution")

p = figure(title=" Objects in the plane ")

for i in range(n):
    if solution[i,i] > 0 : 
        p.scatter(coord_x[i],coord_y[i],radius=3.5, fill_color=colormap[i], line_color="white")

p.scatter(coord_x,coord_y,radius=1.5, fill_color="red", line_color="black")


#p = figure(title="simple line example")
#p.scatter(x,y,marker="square", side=3.5, fill_color="red", line_color="black")

p.ygrid[0].ticker.desired_num_ticks = 20

show(p)
