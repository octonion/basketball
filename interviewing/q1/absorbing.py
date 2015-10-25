#!/usr/bin/env python

import numpy as np
from numpy import linalg as la

# Pick probabilites given seed

a = np.loadtxt("picks.csv", delimiter=",")
s = a.shape[0]

b = np.zeros((s, 30-s))
c = np.zeros((30-s, s))
d = np.identity(30-s)

picks = np.bmat([[a, b], [c, d]])

# Build transition matrix

t = np.zeros((32, 32))
for i in range(0,30):
    
    # Seed i+1 gets pick 1
    
    p0 = np.longfloat(picks[i, 0])

    # Seed i+1 gets pick 5
    
    p4 = np.longfloat(picks[i, 4])

    #print(p0, p4)
    
    j = max(i-2, 0)
    k = min(i+3, 29)
    t[j, i] = np.longfloat(0.40*(1.0-(p0+p4)))
    t[k, i] = np.longfloat(0.60*(1.0-(p0+p4)))
    
    # Absorbing states
    
    t[30, i] = np.longfloat(p0)
    t[31, i] = np.longfloat(p4)

# Absorbing state for pick 1

t[30, 30] = np.longfloat(1.0)

# Absorbing state for pick 5

t[31, 31] = np.longfloat(1.0)

u = la.matrix_power(t, 1000000)

print("{:.12f} {:.12f}".format(u[30,4], u[31,4]))
