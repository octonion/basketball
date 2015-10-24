#!/usr/bin/env python

import numpy
import csv

votes = numpy.array([250,199,156,119,88,63,43,28,17,11,8,7,6,5])
weights = votes/float(sum(votes))

s = weights.size

picks = numpy.zeros((s,s))

# Let the teams be seeded 0, ..., 13 with weights w_i
# The probability of picking seeds i, j, k for the top 3 picks:

#   w_i * w_j/(1-w_i) * w_k/(1-(w_i+w_j))

# All you have to remember is to renormalize the weights after
# each lottery pick.

for i,wi in enumerate(weights):
    for j,wj in enumerate(weights):
        if (j not in [i]):
            for k,wk in enumerate(weights):
                if (k not in [i,j]):
                    picks[i,0] += wi*wj/(1-wi)*wk/(1-(wi+wj))
                    picks[j,1] += wi*wj/(1-wi)*wk/(1-(wi+wj))
                    picks[k,2] += wi*wj/(1-wi)*wk/(1-(wi+wj))
                    for l,wl in enumerate(weights):
                        if (l not in [i,j,k]):
                            a = numpy.array([i,j,k])
                            shift = (a > l).sum()
                            picks[l,l+shift] += wi*wj/(1-wi)*wk/(1-(wi+wj))

#numpy.set_printoptions(precision=3,suppress=True)
#print(picks)

with open('picks.csv', 'wb') as csvfile:
    f = csv.writer(csvfile, delimiter=',')
    f.writerow(['seed\pick']+range(1,s+1))
    for i,row in enumerate(picks):
        frow = ["%.3f" % c for c in row]
        f.writerow([i+1]+frow)

#p = open("picks.csv","a")
#for i,row in enumerate(picks):
#    numpy.savetxt("picks.csv", row, delimiter=",", fmt="%.4f")
#p.close()
