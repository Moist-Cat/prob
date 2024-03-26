a = [1,2,3,4,5]
n = 3

l = [0, 0, 0, 0, 0]
i = 0
r = [0, 0, 0, 0, 0]
j = 0
k = 0

while k < len(a):
    if a[k] < n:
        l[i] = a[k]
        i = i + 1
    if a[k] > n:
        r[j] = a[k]
        j = j + 1
    k = k + 1

print(l, r)
