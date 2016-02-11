# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

from __future__ import division

import numpy as np

import sys
import math
import random
from gurobipy import *

from bokeh.plotting import figure, show, output_file


def oc152_t_instance_generator(n, c, c_y, p, g, n_min, n_max):
    
    if c < g * c_y:
        print ' c_y too big '
        sys.exit(0)

    num_g = []
    sum = 0
    for i in range(g):
        num_g.append(random.uniform(n_min,n_max))
        sum += num_g[i]
        print 'gen ', i, num_g[i], sum
    correct = float(n)/sum
    sum = 0
    for i in range(g):
        nr = num_g[i]*correct
        num_g[i] = int(nr)
        sum += num_g[i]
        print sum
    if sum < n:
        num_g[g-1] += 1
        
    print 'nums: ', sum, num_g
    char_g = []
    for i in range(c):
        char_g.append(-1)
        
    index = 0
    for i in range(g):
        for j in range(c_y):
            char_g[index] = i
            index += 1
            
    print ' Chars: ', char_g
    
    file = open(file_name,"w")
    
    vect = range(c)
    for i in range(g):
        for j in range(num_g[i]):
            for k in range(c):
                if char_g[k] == i:
                    vect[k] = 0
                    if random.uniform(0,1) < p:
                        vect[k] = 1
                else:
                    if char_g[k] != -1:
                        vect[k] = 0
                        if random.uniform(0,1) < 1-p:
                            vect[k] = 1
                    else:
                        vect[k] = 0
                        if random.uniform(0,1) < 0.5:
                            vect[k] = 1
                print i, char_g
                print i, vect

###########
#file.write(vect)
#file.close()


        
if len(sys.argv) < 10:
    print 'Usage: oc-gener  n c c_y p g n_min n_max file_name'
    exit(1)
n = int(sys.argv[1])
c = int(sys.argv[2])
c_y = int(sys.argv[3])
p = float(sys.argv[4])
g = int(sys.argv[5])
n_min = int(sys.argv[6])
n_max = int(sys.argv[7])
file_name = str(sys.argv[8])


#==============================================================================
sum = 0
sum2 = 0
ss = []
ss.append(0)
ss.append(0)
ss.append(0)
ss.append(0)
q0 = 2000
s1 = 0
for j in range(q0):
    r = random.uniform(0,1)
    sum += r
    sum2 += r*r
    if s1 <= 0.5:
        if r <= 0.5:
            ss[0] += 1
        else:
            ss[1] += 1
    else:
        if r <= 0.5:
            ss[2] += 1
        else:
            ss[3] += 1
    s1 = r
             
variance = (sum2 - ((sum*sum)/q0))/q0
sd = math.sqrt(variance)                    
 
print ' Avg: ', sum/q0,' St Dev: ', sd, 1.0/math.sqrt(12)
print ' Hist: ', ss[0], ss[1], ss[2], ss[3] 


    
#==============================================================================

print  ' Params: ', n, c, c_y, p, g, n_min, n_max, file_name

input_var = input("Enter something: ")
print  " you entered ", input_var

oc152_t_instance_generator(n, c, c_y, p, g, n_min, n_max)

input_var = input("Enter something: ")
print  " you entered ", input_var





