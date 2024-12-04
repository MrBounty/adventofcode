from time import now
from collections import List
from collections.string import atol
from Sort import sort

fn main() raises:
    start = now()
    with open("day1/input", "r") as f:
        content = f.read()

    left = List[Int]()
    right = List[Int]()

    for line in content.split('\n')[0:-1]:
        left.append(atol(line[][0:5]))
        right.append(atol(line[][8:13]))


    print("Took ", (now() - start) / 1_000_000, "ms")

fn sort()
