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

class element:

    chars = []
    for i in range(20):
        chars.append(2)

listElements = []
listElements.append(element())

print 'List ', listElements[0].chars[1]

# Euclidean distance between two points
def distance(points, i, j):
    dx = points[i][0] - points[j][0]
    dy = points[i][1] - points[j][1]
    return math.sqrt(dx*dx + dy*dy)

# Generates n elements with c characteristics (features) from g groups
def point_generator_binary_charact(n, c, g, prob):
    global listElements

    # Defines the probabilites of occurence of characteristics in
    # each group. g1 has the first c/g rounded down characteristcs
    # probability prob and the remaining with probability 1-prob
    # g2 the second c/g, and so on.
    # The remaining c mod g characteristics will have probability 0.5 for all.

    random.seed(1607)    
    gen = 0     

    for j in range(g):
        for k in range(n//g + 1):

            listElements.append(element())
            en = c - c%g
            delta = c//g # get integer part of the division
            gen += 1

            for i in range(1,en+1):

                if ( i >= (j*delta) + 1) and ( i < (j+1)*delta + 1 ):
                    print ' el ', gen, j, i, ' prob ', prob 

                    if random.uniform(0,1) < prob:
                        listElements[gen].chars[i] = 1
                    else:
                        listElements[gen].chars[i] = 0

                else:
                    print ' el ', gen, j, i, ' 1 - prob ', 1 - prob 

                    if random.uniform(0,1) < 1 - prob:
                        listElements[gen].chars[i] = 1
                    else:
                        listElements[gen].chars[i] = 0    

            for i in range(en+1, c+1):

                print ' el ', gen, j, i, ' 0.5 ' 

                if random.uniform(0,1) < 0.5:
                    listElements[gen].chars[i] = 1
                else:
                    listElements[gen].chars[i] = 0

# Get a color map with n different colors
def get_colors(n):
    max_value = 16581375 #255*255*255
    interval = int(max_value / n)
    colors = [hex(I)[2:].zfill(6) for I in range(0, max_value, interval)]
    return [(int(i[:2], 16), int(i[2:4], 16), int(i[4:], 16)) for i in colors]

# P-center model
def create_model(p):
    m = Model()

    print " p: ", p, " n:", n
    
    # Create variables
    vars = {}

    for i in range(n):
        for j in range(n):
            vars[i,j] = m.addVar(obj=0, vtype=GRB.CONTINUOUS, name='x'+str(i)+'_'+str(j))

    z = m.addVar(obj=1, vtype=GRB.CONTINUOUS, name='z')
    m.update()

    # Add every point is associated to one center
    for i in range(n):
        m.addConstr(quicksum(vars[i,j] for j in range(n)) == 1)

    m.update()

    for i in range(n):
        for j in range(n):
            if i <> j : 
                m.addConstr(vars[i,j] - vars[j,j] <= 0)

    m.update()

    for i in range(n):
        for j in range(n):
            if i <> j : 
                m.addConstr(distance(points, i, j)*vars[i,j] - z <= 0)

    m.update()

    m.addConstr(quicksum(vars[i,i] for i in range(n)) <= p)
    m.update()

    # Optimize model
    m._vars = vars
    m.optimize()

    return m

# Create n random points
def create_points(points, coord_x, coord_y):
    for i in range(n):
        points.append((random.randint(0,100), random.randint(0,100)))
        coord_x[i]= points[i][0]
        coord_y[i] = points[i][1]

def draw_chart(file, page_title, assignments):
    output_file(file, page_title)
    p = figure(title=" Objects in the plane ")

    for i in range(n):
        if solution[i,i] > 0 : 
            p.scatter(coord_x[i], coord_y[i], radius=4.5, fill_color=colormap[i], line_color="white")

    r = 2.5
    a = [-1] * assignments

    for i in range(n):
        a[0] = -1
        max = 0
        for j in range(n):
            if solution[i,j] > max:
                max = solution[i,j]
                a[0] = j
        p.scatter(coord_x[i], coord_y[i], radius=r, fill_color=colormap[a[0]], line_color="black")
        
        for q in range(1, assignments):
            a[q] = -1
            max = 0
            for j in range(n):
                if j not in a and solution[i,j] > max:
                    max = solution[i,j]
                    a[q] = j
            if a[q] >= 0:
                p.scatter(coord_x[i], coord_y[i], radius=(assignments-q)*(r/assignments), fill_color=colormap[a[q]], line_color="black")
    
    p.ygrid[0].ticker.desired_num_ticks = 20
    show(p)

# Parse argument
if len(sys.argv) < 3:
    print 'Usage: script.py npoints file_name'
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

if len(file_name) == 0:
  print "Next time please enter something"
  sys.exit()

try:
  file = open(file_name, "w")

except IOError:
  print "There was an error reading file"
  sys.exit()

# Generates Elements
c = 10
g = 4
prob = 0.8

point_generator_binary_charact(n, c, g, prob)

for i in range(1, n+1):
    print 'el ', i

    for j in range(1, c+1):
        print j, listElements[i].chars[j]

random.seed(1)
points = []
coord_x = range(n)
coord_y = range(n)

create_points(points, coord_x, coord_y)
m = create_model(10)

solution = m.getAttr('x', m._vars)
selected = [(i,j) for i in range(n) for j in range(n) if i<>j and solution[i,j] > 0.99]
centers = [i for i in range(n) if solution[i,i] > 0.99]

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

colormap = get_colors(n)

# Draw solutions
draw_chart("frac-solution.html", "p-Center Frac", 2)
draw_chart("linear.html", "p-Center Linear", 1)