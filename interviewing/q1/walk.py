#!/usr/bin/env python

import numpy as np

# Pick probabilites given seed

a = np.loadtxt("picks.csv", delimiter=",")
s = a.shape[0]

b = np.zeros((s, 30-s))
c = np.zeros((30-s, s))
d = np.identity(30-s)

picks = np.transpose(np.bmat([[a, b], [c, d]]))

# Build transition matrix

t = np.zeros((30, 30))

for i in range(0,30):
    j = max(0, i-2)
    k = min(29, i+3)
    t[j, i] = 0.40
    t[k, i] = 0.60

# Initial seed set to 5 (index 4)

x = np.zeros((30, 1))
x[4, 0] = 1.0

# 20 years

h0 = 0.0
h4 = 0.0
nh = 1.0

u = np.identity(30)
year = 0
while max(h0, h4)<0.50:
    p = np.dot(u,np.dot(picks,x))
    p0 = p[0, 0]
    p4 = p[4, 0]
    #print("{} {:.12f} {:.12f}".format(i, p0, p4))
    h0 = h0+p0*nh
    h4 = h4+p4*nh
    nh = nh*(1-(p0+p4))
    u = t.dot(u)
    year += 1

print
print("{} years".format(year))
print("Pr(pick 1)={:.12f}".format(h0))
print("Pr(pick 5)={:.12f}".format(h4))
